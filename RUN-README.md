# Running the toolkit
## Start the toolkit
Extract all files into a new folder, then double-click **Brave Diagnostic and Repair Toolkit.bat**. The title bar shows **Version 1.0.0**. Keep the BAT, Launch-Toolkit.vbs, both PS1 files and READMEs together. The graphical window stays open and PowerShell is launched hidden. Administrator access is not required.

## If Windows blocks the download
Right-click the downloaded ZIP, choose **Properties**, check **Unblock** if shown, click **Apply**, then extract again. If an individual extracted file is blocked, the same Properties > Unblock step may be available. Unblock does not override Smart App Control or organizational restrictions. If Windows still refuses to run the files, follow its message or contact your administrator.

## Choose the right profile
Use the Profile dropdown at the top. If you are unsure which profile is yours, type brave://version in Brave and match Profile Path to the dropdown. Close Brave completely before backup or repair. Browse custom... is for a profile folder containing Preferences.

## Hidden-console launcher
The BAT starts Launch-Toolkit.vbs using Windows Script Host, which launches Windows PowerShell hidden. Launch-Toolkit.vbs can also be double-clicked directly. Running a PS1 directly can show a console. If Windows Script Host is disabled by policy, the hidden launcher cannot run.

## Button order
Profile & Folders → Backup & Restore → Diagnostics → Repair & Troubleshoot → Other Tools → Detailed Options Guide → Optional Support → Exit Toolkit.

## Guide and Exit
Detailed Options Guide is yellow and directly below Other Tools. The blue Optional Support button is evenly spaced between the guide and Exit Toolkit. Click the red Exit Toolkit button when finished. During an action, wait until it returns; do not force-close while copying files.

## Optional support

## Optional Ko-fi support

Optional Support asks before opening [https://ko-fi.com/rebeltortuga](https://ko-fi.com/rebeltortuga) in your browser. All features remain free, and no payment information is collected by the toolkit.
