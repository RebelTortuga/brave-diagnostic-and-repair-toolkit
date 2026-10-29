# Detailed Menu Options Guide
## 1 — Choose Brave profile
Choose the profile you normally use in the Profile dropdown at the top. Standard initialized Brave Stable profiles are detected, with profile names from Local State when available. If unsure, open Brave and type brave://version in its address bar; compare Profile Path with the dropdown entries, then close Brave. Browse custom... selects the folder containing Preferences, not the parent User Data folder. The choice is remembered for your Windows account. Back up each profile separately.

## 2 / 3 — Open profile / Saved Logs
Open the selected profile or toolkit log directory in Explorer. Opening a folder changes no browser files. Avoid manually deleting unfamiliar data. Logs can include personal paths.

## 4 — Save a backup
Close Brave completely, including background processes. Choose Bookmarks, Passwords, Extensions, Settings or Select all. The selected profile comes from the main window. Choose a destination outside the live User Data folder. The timestamped backup includes category metadata and SHA-256 hashes. Unsupported linked files/folders are rejected. A copy failure leaves incomplete data for inspection. A completed backup is verified before the completion message.

Bookmarks copies the current bookmark files, rather than a Firefox-style automatic snapshot. Passwords copies available login databases and journal files plus Local State; Windows/Brave protection can prevent recovery on another account, PC or Windows installation. Extensions also copies supporting preferences, so restoring extensions can roll back unrelated settings. All means four supported categories for one profile; it excludes history, cookies, website storage, open tabs, cache, autofill and downloads. Export important extension data separately when necessary.

## 5 — Restore a backup
Close Brave. Select a completed BraveToolkit2 backup created by this toolkit. Hash verification happens before restore. Confirm the warning, then the utility stages current User Data, overlays saved profile files and preserves the original before swapping folders. Failed final swaps attempt rollback. Recovery and staging folders can remain after failures; retain them for inspection. The included categories are restored together without a second selection picker.

Preferences and bookmarks overwrite current files. Additional extensions can remain. Password restore replaces shared Local State and can affect other profiles; save backups first and prefer the original profile and Windows account. No promise of password decryption or complete session/pinned-tab recovery is made. Earlier BraveBackupEssentials1 backups are unsupported here; retain the earlier utility to use those. Check Brave before deleting recovery folders.

## 6 — Diagnostics Center
Quick health check inspects the selected profile, supported files, Brave processes, parent Local State availability and disk space. Full local scan adds JSON parsing of Preferences, Secure Preferences and Bookmarks, and a root-file count. No secret fields are printed. Findings do not establish database integrity. Export the last report as TXT or Markdown; cancel leaves no export. Scans do not modify Brave data, though the toolkit writes its own session log.

## 7 — Launch with extensions disabled
Close Brave, confirm the diagnostic launch, and the toolkit launches the selected profile with --disable-extensions. This is a temporary comparison, not a guaranteed equivalent of Firefox Troubleshoot Mode. Brave can write normal profile data during the launch. Exit Brave before using another repair or backup action. A different result suggests extensions may contribute; it does not prove which extension is responsible.

## 8 — Clear browser cache
Close Brave. Confirm moving Cache, Code Cache and GPUCache to a timestamped recovery folder. Linked cache data is rejected. Brave can regenerate these caches; initial page loads may be slower. The action does not move bookmarks, login databases, Preferences or Sessions. No pinned-tab removal is performed by this cache action. If a move fails, review the recovery directory because earlier cache folders may already have moved.

## 9 — Reset Brave settings (guided)
Save a backup and record important pinned tabs first. The toolkit warns and opens brave://settings/reset for the selected profile. You must initiate and confirm the reset in Brave. Reset affects pinned tabs, startup/home/new-tab settings, extensions/themes, content permissions and cookies/site data. Brave's official guidance says bookmarks, browsing history and saved passwords are retained. Opening the page does not complete a reset; read Brave's confirmation before acting. Official reference: https://support.brave.com/hc/en-us/articles/360017903152-How-do-I-reset-Brave-settings-to-default

## 10 — Create a clean test profile (guided)
The toolkit displays instructions and opens profile settings. Use Brave's profile icon and Add profile to create a new test profile; keep your original. The toolkit does not create or delete profiles automatically. After initializing the new profile, restart the toolkit to detect it, or select its Preferences folder with Browse custom.... Comparing a fresh profile can narrow the problem without proving a specific cause.

## 11 — brave://version
Close Brave first. Opens browser version information for the selected profile. Profile Path helps identify which profile you use. Version information is separate from the toolkit's own diagnostics.

## 12 — Verify a backup
Select a completed BraveToolkit2 backup. Verify stored SHA-256 hashes and the file count without restoring anything. The success dialog lists included categories. Verification does not prove password usability or authenticate an untrusted backup. Cancellation is not successful verification.

## 13 / 14 — Feedback / Brave guidance
13 displays feedback instructions and author information. Use Issues in the repository for bugs, cleanup, new options and improvement requests. Never share passwords, profiles or backups. Author: https://github.com/RebelTortuga. 14 opens official desktop help in your default browser: https://support.brave.com/hc/en-us/categories/360001053032-Desktop-Browser

## Detailed Options Guide — Yellow button
Opens this guide. It sits directly below Other Tools; the H shortcut also opens it.

## 15 — Optional Ko-fi support — Blue button

## Navigation and Exit — Red button
Button order: Profile & Folders, Backup & Restore, Diagnostics, Repair & Troubleshoot, Other Tools, Detailed Options Guide, Optional Support, Exit Toolkit. Choose sections with the left buttons. Diagnostics is green. Detailed Options Guide is yellow and directly below Other Tools; Optional Support is blue and has equal spacer rows between the guide and Exit. The results caption sits above its box. Exit Toolkit is red and highlighted at the bottom left; window Close also works. Exit is disabled during an operation. Wait for the actual completion message; cancellation does not mean a successful operation.

## Optional Ko-fi support

Optional Support asks before opening <img src="https://cdn.simpleicons.org/kofi/FF5E5B" width="17" height="17" alt="Ko-fi"> [https://ko-fi.com/rebeltortuga](https://ko-fi.com/rebeltortuga) in your browser. All features remain free, and no payment information is collected by the toolkit.
