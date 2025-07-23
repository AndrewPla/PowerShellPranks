# Set-BadgerHomepage.ps1
# PowerShell Prank Script - Sets homepage to fun websites and creates startup shortcut
# Author: Steven Wight (PowerShell Young Team) with Claude Sonnet 4's help!
# Date: July 23, 2025
# Version: 2.0

<#
.SYNOPSIS
    Sets the user's browser homepage to fun prank websites and creates a startup shortcut.

.DESCRIPTION
    This harmless prank script performs the following actions:
    1. Sets the default homepage for common browsers (Chrome, Edge, Firefox) to a fun website
    2. Creates a shortcut in the user's Startup folder that opens the website on login
    3. Optionally opens the website immediately

    The script supports multiple prank websites:
    - Badger Badger Badger (classic Flash animation)
    - Nyan Cat YouTube video (10-hour version)

.PARAMETER TargetURL
    The URL to set as the homepage. If not specified, presents a menu to choose from available options.

.PARAMETER SiteChoice
    Pre-select a website option (1 for Badger, 2 for Nyan Cat) without showing the menu.

.PARAMETER SkipImmediate
    Skip opening the website immediately after setup.

.EXAMPLE
    .\Set-BadgerHomepage.ps1
    Runs the script with an interactive menu to choose the prank website.

.EXAMPLE
    .\Set-BadgerHomepage.ps1 -SiteChoice 1
    Sets up the Badger Badger Badger prank without showing the menu.

.EXAMPLE
    .\Set-BadgerHomepage.ps1 -TargetURL "https://example.com" -SkipImmediate
    Sets a custom URL without opening it immediately.

.NOTES
    - Creates backup files for easy restoration (JSON for Chrome/Firefox, .reg for Edge)
    - Works with current user profile (no admin rights needed for most features)
    - Harmless and reversible prank
    - Compatible with Windows PowerShell 5.1 and PowerShell 7+

.LINK
    https://github.com/PowerShellYoungTeam/PowerShellPranks
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $false, HelpMessage = "Custom URL to set as homepage")]
    [string]$TargetURL,

    [Parameter(Mandatory = $false, HelpMessage = "Pre-select website: 1=Badger, 2=Nyan Cat")]
    [ValidateRange(1, 2)]
    [int]$SiteChoice,

    [Parameter(Mandatory = $false, HelpMessage = "Skip opening the website immediately")]
    [switch]$SkipImmediate
)

# Website options
$WebsiteOptions = @{
    1 = @{
        Name        = "Badger Badger Badger"
        URL         = "https://www.badgerbadgerbadger.com"
        Description = "The classic badger animation that will loop forever"
    }
    2 = @{
        Name        = "Badger Badger Badger Youtube Video"
        URL         = "https://youtu.be/I-h-kdscGH8"
        Description = "Youtube Video of the legendary badger animation with Sound"
    }
}

# Determine target URL
if (-not $TargetURL) {
    if ($SiteChoice) {
        $SelectedSite = $WebsiteOptions[$SiteChoice]
        $TargetURL = $SelectedSite.URL
        Write-Host "Pre-selected: $($SelectedSite.Name)" -ForegroundColor Cyan
    }
    else {
        # Show interactive menu
        Write-Host "`n🎯 Choose Your Prank Website:" -ForegroundColor Yellow
        Write-Host "============================================" -ForegroundColor DarkGray

        foreach ($option in $WebsiteOptions.GetEnumerator() | Sort-Object Key) {
            Write-Host "$($option.Key). $($option.Value.Name)" -ForegroundColor White
            Write-Host "   $($option.Value.Description)" -ForegroundColor Gray
            Write-Host ""
        }

        do {
            $choice = Read-Host "Enter your choice (1-$($WebsiteOptions.Count))"
            $choiceInt = 0
            $validChoice = [int]::TryParse($choice, [ref]$choiceInt) -and $WebsiteOptions.ContainsKey($choiceInt)

            if (-not $validChoice) {
                Write-Host "Invalid choice. Please enter a number between 1 and $($WebsiteOptions.Count)." -ForegroundColor Red
            }
        } while (-not $validChoice)

        $SelectedSite = $WebsiteOptions[$choiceInt]
        $TargetURL = $SelectedSite.URL
        Write-Host "`nSelected: $($SelectedSite.Name)" -ForegroundColor Green
    }
}

Write-Host "`n🚀 Starting Prank Setup..." -ForegroundColor Green
Write-Host "Target URL: $TargetURL" -ForegroundColor Yellow

# Function to set Chrome homepage
<#
.SYNOPSIS
    Sets the homepage for Google Chrome browser.

.DESCRIPTION
    Modifies Chrome's preferences.json file to set a custom homepage.
    Creates a backup of the original preferences before making changes.

.PARAMETER URL
    The URL to set as the Chrome homepage.
#>
function Set-ChromeHomepage {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$URL
    )

    try {
        Write-Host "Setting Chrome homepage..." -ForegroundColor Cyan

        $ChromePrefsPath = "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Preferences"

        if (Test-Path $ChromePrefsPath) {
            $BackupPath = "$ChromePrefsPath.backup.$(Get-Date -Format 'yyyyMMdd_HHmmss')"
            Copy-Item $ChromePrefsPath $BackupPath -ErrorAction SilentlyContinue
            Write-Host "Backup created: $BackupPath" -ForegroundColor Green

            $Prefs = Get-Content $ChromePrefsPath -Raw | ConvertFrom-Json

            if (-not $Prefs.homepage) {
                $Prefs | Add-Member -NotePropertyName "homepage" -NotePropertyValue $URL
            }
            else {
                $Prefs.homepage = $URL
            }

            if (-not $Prefs.homepage_is_newtabpage) {
                $Prefs | Add-Member -NotePropertyName "homepage_is_newtabpage" -NotePropertyValue $false -Force
            }
            else {
                $Prefs.homepage_is_newtabpage = $false
            }

            if (-not $Prefs.show_home_button) {
                $Prefs | Add-Member -NotePropertyName "show_home_button" -NotePropertyValue $true
            }
            else {
                $Prefs.show_home_button = $true
            }

            $Prefs | ConvertTo-Json -Depth 100 | Set-Content $ChromePrefsPath -Encoding UTF8
            Write-Host "Chrome homepage set successfully!" -ForegroundColor Green
        }
        else {
            Write-Host "Chrome not found or not configured" -ForegroundColor Yellow
        }
    }
    catch {
        Write-Host "Error setting Chrome homepage: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# Function to set Edge homepage
<#
.SYNOPSIS
    Sets the homepage for Microsoft Edge browser.

.DESCRIPTION
    Modifies registry settings to set a custom homepage for Edge/Internet Explorer.
    Works with the legacy IE engine that Edge sometimes uses.
    Creates a .reg file backup for easy restoration.

.PARAMETER URL
    The URL to set as the Edge homepage.
#>
function Set-EdgeHomepage {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$URL
    )

    try {
        Write-Host "Setting Microsoft Edge homepage..." -ForegroundColor Cyan

        $EdgeRegPath = "HKCU:\Software\Microsoft\Internet Explorer\Main"
        $BackupFolder = "$env:TEMP\PowerShellPranks"
        $RegBackupFile = "$BackupFolder\EdgeHomepage_Backup_$(Get-Date -Format 'yyyyMMdd_HHmmss').reg"

        # Create backup folder if it doesn't exist
        if (-not (Test-Path $BackupFolder)) {
            New-Item -Path $BackupFolder -ItemType Directory -Force | Out-Null
        }

        if (Test-Path $EdgeRegPath) {
            # Get current homepage values
            $CurrentStartPage = Get-ItemProperty -Path $EdgeRegPath -Name "Start Page" -ErrorAction SilentlyContinue
            $CurrentDefaultPage = Get-ItemProperty -Path $EdgeRegPath -Name "Default_Page_URL" -ErrorAction SilentlyContinue

            if ($CurrentStartPage) {
                Write-Host "Current homepage: $($CurrentStartPage.'Start Page')" -ForegroundColor Gray
            }

            # Create .reg file content for restoration
            $RegContent = @"
Windows Registry Editor Version 5.00

[HKEY_CURRENT_USER\Software\Microsoft\Internet Explorer\Main]
"@

            # Add Start Page to .reg file
            if ($CurrentStartPage) {
                $RegContent += "`n`"Start Page`"=`"$($CurrentStartPage.'Start Page')`""
            }
            else {
                $RegContent += "`n`"Start Page`"=-"
            }

            # Add Default_Page_URL to .reg file
            if ($CurrentDefaultPage) {
                $RegContent += "`n`"Default_Page_URL`"=`"$($CurrentDefaultPage.'Default_Page_URL')`""
            }
            else {
                $RegContent += "`n`"Default_Page_URL`"=-"
            }

            # Save the .reg file
            $RegContent | Set-Content $RegBackupFile -Encoding Unicode
            Write-Host "Registry backup created: $RegBackupFile" -ForegroundColor Green

            # Set new homepage values
            Set-ItemProperty -Path $EdgeRegPath -Name "Start Page" -Value $URL
            Set-ItemProperty -Path $EdgeRegPath -Name "Default_Page_URL" -Value $URL
            Write-Host "Edge homepage set successfully!" -ForegroundColor Green
            Write-Host "To restore: Double-click the .reg file or run: regedit /s `"$RegBackupFile`"" -ForegroundColor Yellow
        }
        else {
            Write-Host "Edge registry path not found" -ForegroundColor Yellow
        }
    }
    catch {
        Write-Host "Error setting Edge homepage: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# Function to set Firefox homepage
<#
.SYNOPSIS
    Sets the homepage for Mozilla Firefox browser.

.DESCRIPTION
    Modifies Firefox's prefs.js file in user profiles to set a custom homepage.
    Creates backups and handles multiple Firefox profiles if they exist.

.PARAMETER URL
    The URL to set as the Firefox homepage.
#>
function Set-FirefoxHomepage {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$URL
    )

    try {
        Write-Host "Setting Firefox homepage..." -ForegroundColor Cyan

        $FirefoxProfilesPath = "$env:APPDATA\Mozilla\Firefox\Profiles"

        if (Test-Path $FirefoxProfilesPath) {
            $ProfileDirs = Get-ChildItem $FirefoxProfilesPath -Directory | Where-Object { $_.Name -like "*.default*" }

            foreach ($ProfileDir in $ProfileDirs) {
                $PrefsFile = Join-Path $ProfileDir.FullName "prefs.js"

                if (Test-Path $PrefsFile) {
                    $BackupPath = "$PrefsFile.backup.$(Get-Date -Format 'yyyyMMdd_HHmmss')"
                    Copy-Item $PrefsFile $BackupPath -ErrorAction SilentlyContinue
                    Write-Host "Backup created: $BackupPath" -ForegroundColor Green

                    $PrefsContent = Get-Content $PrefsFile

                    $PrefsContent = $PrefsContent | Where-Object {
                        $_ -notmatch 'user_pref\("browser\.startup\.homepage"' -and
                        $_ -notmatch 'user_pref\("browser\.startup\.page"'
                    }

                    $PrefsContent += 'user_pref("browser.startup.homepage", "' + $URL + '");'
                    $PrefsContent += 'user_pref("browser.startup.page", 1);'

                    $PrefsContent | Set-Content $PrefsFile -Encoding UTF8
                    Write-Host "Firefox homepage set for profile: $($ProfileDir.Name)" -ForegroundColor Green
                }
            }
        }
        else {
            Write-Host "Firefox not found or not configured" -ForegroundColor Yellow
        }
    }
    catch {
        Write-Host "Error setting Firefox homepage: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# Function to create startup shortcut
<#
.SYNOPSIS
    Creates a shortcut in the Windows Startup folder.

.DESCRIPTION
    Creates a Windows shortcut (.lnk file) in the user's Startup folder that will
    open the specified URL when the user logs in. The shortcut runs hidden to
    avoid showing a command prompt window.

.PARAMETER URL
    The URL to open when the shortcut is executed.
#>
function New-StartupShortcut {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$URL
    )

    try {
        Write-Host "Creating startup shortcut..." -ForegroundColor Cyan

        $StartupFolder = [System.Environment]::GetFolderPath('Startup')
        $ShortcutPath = Join-Path $StartupFolder "PrankTime.lnk"

        Write-Host "Startup folder: $StartupFolder" -ForegroundColor Gray

        $WshShell = New-Object -ComObject WScript.Shell
        $Shortcut = $WshShell.CreateShortcut($ShortcutPath)

        $Shortcut.TargetPath = "powershell.exe"
        $Shortcut.Arguments = "-WindowStyle Hidden -Command ""Start-Process '$URL'"""
        $Shortcut.Description = "Prank Time - Opens the ultimate experience"
        $Shortcut.IconLocation = "shell32.dll,13"
        $Shortcut.WorkingDirectory = $env:USERPROFILE

        $Shortcut.Save()

        Write-Host "Startup shortcut created: $ShortcutPath" -ForegroundColor Green
        Write-Host "The fun will greet you on next login!" -ForegroundColor Magenta
    }
    catch {
        Write-Host "Error creating startup shortcut: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# Function to open the website immediately
<#
.SYNOPSIS
    Opens the specified URL in the default browser immediately.

.DESCRIPTION
    Launches the default web browser and navigates to the specified URL for
    immediate enjoyment of the prank website.

.PARAMETER URL
    The URL to open in the default browser.
#>
function Invoke-PrankTime {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$URL
    )

    try {
        Write-Host "Opening website for immediate enjoyment..." -ForegroundColor Magenta
        Start-Process $URL
        Write-Host "Enjoy the show!" -ForegroundColor Green
    }
    catch {
        Write-Host "Error opening website: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# Main execution
Write-Host ""
Write-Host "============================================================" -ForegroundColor DarkGray
Write-Host "PRANK HOMEPAGE SETUP INITIATED" -ForegroundColor Yellow
Write-Host "============================================================" -ForegroundColor DarkGray

# Execute the prank setup
Write-Host "`n🔧 Configuring browsers..." -ForegroundColor Cyan
Set-ChromeHomepage -URL $TargetURL
Set-EdgeHomepage -URL $TargetURL
Set-FirefoxHomepage -URL $TargetURL

Write-Host "`n🔗 Creating startup persistence..." -ForegroundColor Cyan
New-StartupShortcut -URL $TargetURL

# Open immediately unless skipped
if (-not $SkipImmediate) {
    Write-Host "`n🎉 Opening for immediate preview..." -ForegroundColor Cyan
    Invoke-PrankTime -URL $TargetURL
}

Write-Host ""
Write-Host "============================================================" -ForegroundColor DarkGray
Write-Host "PRANK SETUP COMPLETE!" -ForegroundColor Green
Write-Host "============================================================" -ForegroundColor DarkGray

Write-Host ""
Write-Host "Summary:" -ForegroundColor White
Write-Host "  - Target URL: $TargetURL" -ForegroundColor Cyan
Write-Host "  - Browser homepages configured" -ForegroundColor Green
Write-Host "  - Startup shortcut created" -ForegroundColor Green
Write-Host "  - Backup files created for safety" -ForegroundColor Yellow
Write-Host "  - Registry .reg file created for Edge restoration" -ForegroundColor Yellow
if (-not $SkipImmediate) {
    Write-Host "  - Website opened immediately" -ForegroundColor Magenta
}

Write-Host ""
Write-Host "To undo changes:" -ForegroundColor Cyan
Write-Host "  1. Restore browser preference backups" -ForegroundColor Gray
Write-Host "  2. Double-click Edge .reg backup file in $env:TEMP\PowerShellPranks\" -ForegroundColor Gray
Write-Host "  3. Delete startup shortcut: $([System.Environment]::GetFolderPath('Startup'))\PrankTime.lnk" -ForegroundColor Gray

Write-Host ""
Write-Host "Enjoy the fun! 🎉" -ForegroundColor Yellow
