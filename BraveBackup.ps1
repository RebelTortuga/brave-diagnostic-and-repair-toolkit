param([ValidateSet('Backup','Restore','Verify')][string]$Action='Backup',[string]$ProfilePath)
$ErrorActionPreference='Stop'
Add-Type -AssemblyName System.Windows.Forms
function AssertClosed { if(Get-Process brave -ErrorAction SilentlyContinue){throw 'Close all Brave windows and background processes first.'} }
function SelectFolder($title){$d=New-Object System.Windows.Forms.FolderBrowserDialog;$d.Description=$title;try{if($d.ShowDialog() -eq 'OK'){return $d.SelectedPath}}finally{$d.Dispose()}}
function SafeTree($path){
    $all=@(Get-Item -LiteralPath $path -Force)+@(Get-ChildItem -LiteralPath $path -Recurse -Force)
    if(@($all|Where-Object{$_.Attributes -band [IO.FileAttributes]::ReparsePoint}).Count){throw 'Linked files or folders are not supported.'}
}
function PickCategories {
    $d=New-Object System.Windows.Forms.Form;$d.Text='Choose Brave backup categories';$d.Width=460;$d.Height=280;$d.StartPosition='CenterScreen'
    $list=New-Object System.Windows.Forms.CheckedListBox;$list.Dock='Top';$list.Height=150
    foreach($name in @('Bookmarks','Passwords','Extensions','Settings')){$null=$list.Items.Add($name,$true)}
    $all=New-Object System.Windows.Forms.Button;$all.Text='Select all';$all.Dock='Top';$all.Add_Click({for($i=0;$i -lt $list.Items.Count;$i++){$list.SetItemChecked($i,$true)}})
    $ok=New-Object System.Windows.Forms.Button;$ok.Text='Continue';$ok.Dock='Bottom';$ok.DialogResult='OK';$d.AcceptButton=$ok
    $d.Controls.Add($list);$d.Controls.Add($all);$d.Controls.Add($ok)
    try{if($d.ShowDialog() -eq 'OK'){return @($list.CheckedItems|ForEach-Object{[string]$_})}}finally{$d.Dispose()}
}
function VerifyBackup($backup){
    $marker=Join-Path $backup 'Backup Complete.json'
    if(!(Test-Path -LiteralPath $marker)){throw 'No completion marker found.'}
    SafeTree $backup
    $meta=Get-Content -LiteralPath $marker -Raw -Encoding UTF8|ConvertFrom-Json
    if($meta.Format -ne 'BraveToolkit2'){throw 'This toolkit restores only BraveToolkit2 backups. Keep older backups separately.'}
    if($meta.ProfileName -notmatch '^[^\\/:*?"<>|.][^\\/:*?"<>|]*$'){throw 'Invalid stored profile folder name.'}
    if(!$meta.Hashes -or !$meta.Categories){throw 'Backup manifest is incomplete.'}
    foreach($category in $meta.Categories){if($category -notin @('Bookmarks','Passwords','Extensions','Settings')){throw 'Unsupported backup category.'}}
    if(!(Test-Path -LiteralPath (Join-Path (Join-Path $backup 'User Data') $meta.ProfileName) -PathType Container)){throw 'Saved profile folder is missing.'}
    if($meta.Categories -contains 'Passwords' -and !(Test-Path -LiteralPath (Join-Path (Join-Path $backup 'User Data') 'Local State'))){throw 'Saved Local State is missing.'}
    $data=Join-Path $backup 'User Data'
    foreach($record in $meta.Hashes){
        $base=[IO.Path]::GetFullPath($data).TrimEnd('\')+'\'
        $path=[IO.Path]::GetFullPath((Join-Path $data $record.Path))
        if(!$path.StartsWith($base,[StringComparison]::OrdinalIgnoreCase)){throw 'Unsafe backup path.'}
        if(!(Test-Path -LiteralPath $path -PathType Leaf) -or (Get-FileHash -LiteralPath $path -Algorithm SHA256).Hash -ne $record.Hash){throw "Verification failed: $($record.Path)"}
    }
    if(@(Get-ChildItem -LiteralPath $data -File -Recurse -Force).Count -ne @($meta.Hashes).Count){throw 'Backup file count differs from its manifest.'}
    return $meta
}
function CopyTree($from, $to, $log) {
    & robocopy.exe $from $to /E /XJ /R:1 /W:1 /COPY:DAT /DCOPY:DAT /NP "/LOG+:$log" | Out-Null
    if ($LASTEXITCODE -ge 8) { throw "Copy failed. See $log. Incomplete data was retained for inspection." }
}

function CopySelected($from, $to, $log) {
    New-Item -ItemType Directory -Path $to -Force | Out-Null
    if($script:Categories -contains 'Passwords'){ Copy-Item -LiteralPath (Join-Path $from 'Local State') -Destination $to }
    $profiles = @(Get-Item -LiteralPath (Join-Path $from $script:ProfileName))
    foreach ($profile in $profiles) {
        $target = Join-Path $to $profile.Name
        New-Item -ItemType Directory -Path $target -Force | Out-Null
        $installed = @{}
        if($script:Categories -contains 'Extensions'){
        foreach ($prefName in @('Preferences', 'Secure Preferences')) {
            $prefPath = Join-Path $profile.FullName $prefName
            if (Test-Path -LiteralPath $prefPath) {
                $prefs = Get-Content -LiteralPath $prefPath -Raw -Encoding UTF8 | ConvertFrom-Json
                if ($prefs.extensions -and $prefs.extensions.settings) {
                    foreach ($entry in $prefs.extensions.settings.PSObject.Properties) {
                        $record = $entry.Value
                        if ($record.location -in @(1, 4) -and !$record.was_installed_by_default -and !$record.was_installed_by_oem) {
                            $installed[$entry.Name] = $true
                        }
                    }
                }
            }
        }
        }
        foreach ($name in @('Bookmarks', 'Bookmarks.bak', 'Login Data', 'Login Data-journal', 'Login Data For Account', 'Login Data For Account-journal', 'Preferences', 'Secure Preferences')) {
            $item = Join-Path $profile.FullName $name
            $category = if($name -like 'Bookmarks*'){'Bookmarks'}elseif($name -like 'Login Data*'){'Passwords'}else{'Settings'}
            if(($script:Categories -contains $category -or ($category -eq 'Settings' -and $script:Categories -contains 'Extensions')) -and (Test-Path -LiteralPath $item -PathType Leaf)){Copy-Item -LiteralPath $item -Destination $target}
        }
        if($script:Categories -contains 'Extensions'){
        foreach ($name in @('Extensions', 'Local Extension Settings', 'Sync Extension Settings', 'Managed Extension Settings', 'Extension Rules', 'Extension Scripts')) {
            $item = Join-Path $profile.FullName $name
            if (Test-Path -LiteralPath $item -PathType Container) {
                foreach ($id in $installed.Keys) {
                    $ext = Join-Path $item $id
                    if (Test-Path -LiteralPath $ext -PathType Container) { CopyTree $ext (Join-Path (Join-Path $target $name) $id) $log }
                }
            }
        }
        $db = Join-Path $profile.FullName 'IndexedDB'
        if (Test-Path -LiteralPath $db) {
            foreach ($item in (Get-ChildItem -LiteralPath $db -Directory -Filter 'chrome-extension_*')) {
                foreach ($id in $installed.Keys) {
                    if ($item.Name.StartsWith('chrome-extension_' + $id + '_')) {
                        CopyTree $item.FullName (Join-Path (Join-Path $target 'IndexedDB') $item.Name) $log
                    }
                }
            }
        }
        $extStorage = Join-Path $profile.FullName 'Storage\ext'
        if (Test-Path -LiteralPath $extStorage) {
            foreach ($id in $installed.Keys) {
                $ext = Join-Path $extStorage $id
                if (Test-Path -LiteralPath $ext) { CopyTree $ext (Join-Path (Join-Path $target 'Storage\ext') $id) $log }
            }
        }
        $installed.Keys | Sort-Object | Set-Content -LiteralPath (Join-Path $target 'User Installed Extensions.txt') -Encoding UTF8
        }
    }
}

try {
    if($Action -eq 'Verify'){
        $backup=SelectFolder 'Select the completed Brave toolkit backup';if(!$backup){exit 2}
        $meta=VerifyBackup $backup
        [System.Windows.Forms.MessageBox]::Show("Hashes verified. Categories: $($meta.Categories -join ', '). Password usability is not tested.",'Brave backup verification')|Out-Null;exit 0
    }
    AssertClosed
    if(!$ProfilePath -or !(Test-Path -LiteralPath (Join-Path $ProfilePath 'Preferences'))){throw 'Choose an initialized Brave profile first.'}
    $ProfilePath=[IO.Path]::GetFullPath($ProfilePath).TrimEnd('\')
    $source=Split-Path $ProfilePath -Parent;$script:ProfileName=Split-Path $ProfilePath -Leaf
    SafeTree $source
    $stamp=Get-Date -Format 'yyyy-MM-dd_HH-mm-ss-fff'
    if($Action -eq 'Backup'){
        $script:Categories=@(PickCategories);if(!$script:Categories.Count){exit 2}
        if($script:Categories -contains 'Passwords' -and !(Test-Path -LiteralPath (Join-Path $source 'Local State'))){throw 'Password backup requires Local State in the parent folder.'}
        $parent=SelectFolder 'Choose a backup destination outside Brave User Data';if(!$parent){exit 2}
        $parent=[IO.Path]::GetFullPath($parent).TrimEnd('\')
        if($parent -eq $source -or $parent.StartsWith($source+'\',[StringComparison]::OrdinalIgnoreCase)){throw 'Choose a destination outside the live User Data folder.'}
        $backup=Join-Path $parent ('Brave Backup '+$stamp);New-Item -ItemType Directory -Path $backup|Out-Null
        $data=Join-Path $backup 'User Data'
        CopySelected $source $data (Join-Path $backup 'Copy Log.txt');AssertClosed
        $hashes=@(Get-ChildItem -LiteralPath $data -File -Recurse -Force|ForEach-Object{@{Path=$_.FullName.Substring($data.Length+1);Hash=(Get-FileHash -LiteralPath $_.FullName -Algorithm SHA256).Hash}})
        if(!$hashes.Count){throw 'No supported files were copied; backup is incomplete.'}
        @{Format='BraveToolkit2';Created=(Get-Date).ToString('o');ProfileName=$script:ProfileName;Categories=$script:Categories;Hashes=$hashes}|ConvertTo-Json -Depth 6|Set-Content -LiteralPath (Join-Path $backup 'Backup Complete.json') -Encoding UTF8
        $null=VerifyBackup $backup
        [System.Windows.Forms.MessageBox]::Show("Backup verified.`n$backup`nPasswords may work only on this Windows installation and account.",'Brave Backup')|Out-Null
    }else{
        $backup=SelectFolder 'Select a completed Brave toolkit backup';if(!$backup){exit 2}
        $backup=[IO.Path]::GetFullPath($backup).TrimEnd('\')
        if($backup -eq $source -or $backup.StartsWith($source+'\',[StringComparison]::OrdinalIgnoreCase)){throw 'Move the backup outside the live User Data folder first.'}
        $meta=VerifyBackup $backup
        if([System.Windows.Forms.MessageBox]::Show('Restore the included categories? Preferences can roll back unrelated settings. Current User Data will be preserved in a recovery folder. Password usability cannot be guaranteed. Password restore also replaces shared Local State and can affect other profiles; back up each profile first.','Confirm Brave restore','YesNo','Warning') -ne 'Yes'){exit 2}
        $saved=Join-Path $backup 'User Data';$stage=Join-Path (Split-Path $source -Parent) ('Restore Staging '+$stamp)
        $log=Join-Path (Split-Path $source -Parent) ('Restore Log '+$stamp+'.txt')
        CopyTree $source $stage $log
        $fromProfile=Join-Path $saved $meta.ProfileName;$toProfile=Join-Path $stage $script:ProfileName
        CopyTree $fromProfile $toProfile $log
        # Do not replace shared Local State for a bookmarks/settings/extensions-only restore.
        if($meta.Categories -contains 'Passwords'){Copy-Item -LiteralPath (Join-Path $saved 'Local State') -Destination $stage -Force}
        AssertClosed
        $recovery=Join-Path (Split-Path $source -Parent) ('User Data before restore '+$stamp)
        Move-Item -LiteralPath $source -Destination $recovery
        try{Move-Item -LiteralPath $stage -Destination $source}catch{if(!(Test-Path -LiteralPath $source)){Move-Item -LiteralPath $recovery -Destination $source};throw}
        [System.Windows.Forms.MessageBox]::Show("Restore completed. Verify Brave before deleting recovery data.`n$recovery",'Brave Restore')|Out-Null
    }
}catch{[System.Windows.Forms.MessageBox]::Show($_.Exception.Message,'Brave Toolkit - Operation Failed','OK','Error')|Out-Null;exit 1}
