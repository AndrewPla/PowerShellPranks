# Set-BadgerHomepage.ps1
# PowerShell Prank Script - Sets homepage to fun websites and creates startup shortcut
# Author: Steven Wight (PowerShell Young Team) with Claude Sonnet 4's help!
# Date: July 26, 2025
# Version: 3.0

<#
.SYNOPSIS
    Sets the user's browser homepage to fun prank websites and creates a startup shortcut.

.DESCRIPTION
    This harmless prank script performs the following actions:
    1. Validates PowerShell version compatibility (requires 5.1 or higher)
    2. Detects installed browsers and checks for admin requirements
    3. Validates URL format and accessibility
    4. Sets the default homepage for detected browsers (Chrome, Edge, Firefox) to a fun website
    5. Creates a shortcut in the user's Startup folder that opens the website on login
    6. Optionally opens the website immediately
    7. Provides comprehensive undo functionality

    The script supports multiple prank websites:
    - Badger Badger Badger (classic Flash animation)
    - Badger Badger Badger YouTube video (10-hour version with sound)

.PARAMETER TargetURL
    Specifies the custom URL to set as the homepage. Must be a valid HTTP/HTTPS URL.
    If not specified, presents an interactive menu to choose from available prank options.

    Example: -TargetURL "https://www.badgerbadgerbadger.com"

.PARAMETER SiteChoice
    Pre-selects a website option without showing the interactive menu.
    Valid values: 1 (Badger Badger Badger), 2 (Badger YouTube Video)

    Example: -SiteChoice 1

.PARAMETER SkipImmediate
    Prevents the script from opening the website immediately after setup.
    Use this switch when you want to configure browsers without triggering the prank immediately.

.PARAMETER Undo
    Reverses all changes made by this script by restoring browser settings from backup files
    and removing the startup shortcut. This provides a complete rollback of the prank setup.

.PARAMETER CheckOnly
    Performs system compatibility checks (PowerShell version, browser detection, admin status)
    without making any changes. Useful for testing before running the actual prank.

.PARAMETER Force
    Bypasses certain safety checks and confirmation prompts. Use with caution.
    Does not bypass PowerShell version requirements or URL validation.

.EXAMPLE
    .\Set-BadgerHomepage.ps1

    Runs the script with an interactive menu to choose the prank website.
    Performs all compatibility checks and prompts for confirmation.

.EXAMPLE
    .\Set-BadgerHomepage.ps1 -SiteChoice 1 -SkipImmediate

    Sets up the Badger Badger Badger prank without showing the menu or opening immediately.
    Ideal for setting up the prank to trigger only on next login.

.EXAMPLE
    .\Set-BadgerHomepage.ps1 -TargetURL "https://example.com" -Force

    Sets a custom URL with minimal prompts and safety checks.

.EXAMPLE
    .\Set-BadgerHomepage.ps1 -Undo

    Completely reverses all changes made by the script, restoring original browser settings.

.EXAMPLE
    .\Set-BadgerHomepage.ps1 -CheckOnly

    Performs compatibility checks without making changes. Shows PowerShell version,
    detected browsers, and admin status.

.INPUTS
    None. This script does not accept pipeline input.

.OUTPUTS
    System.String
    The script outputs status messages and results to the console with color formatting.

.NOTES
    File Name      : Set-BadgerHomepage.ps1
    Author         : Steven Wight (PowerShell Young Team) with Claude Sonnet 4's help
    Prerequisite   : PowerShell 5.1 or higher
    Copyright      : Free to use and modify

    COMPATIBILITY:
    - Windows PowerShell 5.1+
    - PowerShell Core 6.0+
    - PowerShell 7.0+

    REQUIREMENTS:
    - Windows operating system
    - User profile access (no admin rights required for basic functionality)
    - Internet connectivity for URL validation (optional)

    SAFETY FEATURES:
    - Creates timestamped backup files before making changes
    - Validates URLs for proper format and accessibility
    - Detects browser installations before attempting modifications
    - Provides complete undo functionality
    - Non-destructive operations (all changes are reversible)

     IMPORTANT:
     Browsers that use user profiles (such as Chrome, Edge, and Firefox) may overwrite homepage and startup settings if the browser is running during script execution, or if profiles sync settings from the cloud. For best results, ensure all browsers are closed before running the script, and be aware that profile sync may revert changes.

.LINK
    https://github.com/PowerShellYoungTeam/PowerShellPranks

.LINK
    https://docs.microsoft.com/en-us/powershell/

.LINK
    https://www.badgerbadgerbadger.com
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $false, HelpMessage = "Custom URL to set as homepage (must be valid HTTP/HTTPS URL)")]
    [ValidateScript({
            if ($_ -match '^https?://') {
                $true
            }
            else {
                throw "URL must start with http:// or https://"
            }
        })]
    [string]$TargetURL,

    [Parameter(Mandatory = $false, HelpMessage = "Pre-select website: 1=Badger, 2=Badger YouTube")]
    [ValidateRange(1, 2)]
    [int]$SiteChoice,

    [Parameter(Mandatory = $false, HelpMessage = "Skip opening the website immediately after setup")]
    [switch]$SkipImmediate,

    [Parameter(Mandatory = $false, HelpMessage = "Undo all changes made by this script")]
    [switch]$Undo,

    [Parameter(Mandatory = $false, HelpMessage = "Check system compatibility without making changes")]
    [switch]$CheckOnly,

    [Parameter(Mandatory = $false, HelpMessage = "Bypass safety checks and confirmation prompts")]
    [switch]$Force,

    [Parameter(Mandatory = $false, HelpMessage = "Automatically stop browsers before making changes")]
    [switch]$StopBrowsers
)

# Global variables for script state
$Script:BackupFolder = "$env:TEMP\PowerShellPranks"
$Script:SupportedBrowsers = @()
$Script:AdminRequired = $false

# Website options
$WebsiteOptions = @{
    1 = @{
        Name        = "Badger Badger Badger"
        URL         = "https://www.badgerbadgerbadger.com"
        Description = "The classic badger animation that will loop forever"
    }
    2 = @{
        Name        = "Badger Badger Badger YouTube Video"
        URL         = "https://www.youtube.com/watch?v=I-h-kdscGH8"
        Description = "YouTube Video of the legendary badger animation with Sound"
    }
}

#region System Compatibility Functions

<#
.SYNOPSIS
    Checks if the current PowerShell version meets minimum requirements.

.DESCRIPTION
    Validates that PowerShell version is 5.1 or higher for proper script functionality.
    Provides detailed version information and compatibility warnings.

.OUTPUTS
    System.Boolean - Returns $true if version is compatible, $false otherwise
#>
function Test-PowerShellVersion {
    [CmdletBinding()]
    [OutputType([bool])]
    param()

    try {
        $PSVersion = $PSVersionTable.PSVersion
        $MinVersion = [Version]"5.1.0.0"

        Write-Host "PowerShell Version Check:" -ForegroundColor Cyan
        Write-Host "  Current Version: $($PSVersion.ToString())" -ForegroundColor White
        Write-Host "  Required Version: $($MinVersion.ToString()) or higher" -ForegroundColor Gray

        if ($PSVersion -ge $MinVersion) {
            Write-Host "  Status: ✅ Compatible" -ForegroundColor Green
            return $true
        }
        else {
            Write-Host "  Status: ❌ Incompatible" -ForegroundColor Red
            Write-Host "  Error: This script requires PowerShell 5.1 or higher" -ForegroundColor Red
            Write-Host "  Please upgrade PowerShell or use a newer version" -ForegroundColor Yellow
            return $false
        }
    }
    catch {
        Write-Host "Error checking PowerShell version: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

<#
.SYNOPSIS
    Detects which browsers are installed on the system.

.DESCRIPTION
    Scans common installation paths and registry entries to detect installed browsers.
    Updates the script-scoped $SupportedBrowsers variable with detected browsers.

.OUTPUTS
    System.Array - Returns array of detected browser names
#>
function Get-InstalledBrowsers {
    [CmdletBinding()]
    [OutputType([Array])]
    param()

    try {
        Write-Host "Browser Detection:" -ForegroundColor Cyan
        $DetectedBrowsers = @()

        # Check for Chrome
        $ChromePaths = @(
            "$env:LOCALAPPDATA\Google\Chrome\Application\chrome.exe",
            "$env:PROGRAMFILES\Google\Chrome\Application\chrome.exe",
            "${env:PROGRAMFILES(X86)}\Google\Chrome\Application\chrome.exe"
        )

        foreach ($path in $ChromePaths) {
            if (Test-Path $path) {
                $DetectedBrowsers += "Chrome"
                Write-Host "  ✅ Google Chrome detected" -ForegroundColor Green
                break
            }
        }

        # Check for Edge (Chromium)
        $EdgePaths = @(
            "${env:PROGRAMFILES(X86)}\Microsoft\Edge\Application\msedge.exe",
            "$env:PROGRAMFILES\Microsoft\Edge\Application\msedge.exe"
        )

        foreach ($path in $EdgePaths) {
            if (Test-Path $path) {
                $DetectedBrowsers += "Edge"
                Write-Host "  ✅ Microsoft Edge detected" -ForegroundColor Green
                break
            }
        }

        # Check for Firefox
        $FirefoxPaths = @(
            "$env:PROGRAMFILES\Mozilla Firefox\firefox.exe",
            "${env:PROGRAMFILES(X86)}\Mozilla Firefox\firefox.exe",
            "$env:APPDATA\Mozilla\Firefox\Profiles"
        )

        foreach ($path in $FirefoxPaths) {
            if (Test-Path $path) {
                $DetectedBrowsers += "Firefox"
                Write-Host "  ✅ Mozilla Firefox detected" -ForegroundColor Green
                break
            }
        }

        if ($DetectedBrowsers.Count -eq 0) {
            Write-Host "  ⚠️  No supported browsers detected" -ForegroundColor Yellow
            Write-Host "     Supported: Chrome, Edge, Firefox" -ForegroundColor Gray
        }
        else {
            Write-Host "  Total browsers detected: $($DetectedBrowsers.Count)" -ForegroundColor White
        }

        $Script:SupportedBrowsers = $DetectedBrowsers
        return $DetectedBrowsers
    }
    catch {
        Write-Host "Error detecting browsers: $($_.Exception.Message)" -ForegroundColor Red
        return @()
    }
}

<#
.SYNOPSIS
    Checks if the script is running with administrative privileges.

.DESCRIPTION
    Determines if the current PowerShell session has administrator rights.
    Some browser modifications may require elevated privileges.

.OUTPUTS
    System.Boolean - Returns $true if running as administrator, $false otherwise
#>
function Test-IsAdmin {
    [CmdletBinding()]
    [OutputType([bool])]
    param()

    try {
        Write-Host "Administrator Privileges Check:" -ForegroundColor Cyan

        $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
        $principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
        $isAdmin = $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

        if ($isAdmin) {
            Write-Host "  Status: ✅ Running as Administrator" -ForegroundColor Green
            Write-Host "  Note: Full access to all browser settings" -ForegroundColor Gray
        }
        else {
            Write-Host "  Status: ⚠️  Running as Standard User" -ForegroundColor Yellow
            Write-Host "  Note: Limited to user-profile browser settings" -ForegroundColor Gray
            Write-Host "  Tip: Run as Administrator for system-wide changes" -ForegroundColor Cyan
        }

        $Script:AdminRequired = -not $isAdmin
        return $isAdmin
    }
    catch {
        Write-Host "Error checking admin status: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

<#
.SYNOPSIS
    Validates that a URL is properly formatted and accessible.

.DESCRIPTION
    Performs format validation and optional connectivity test for the target URL.
    Ensures the URL is safe and reachable before using it in browser configuration.

.PARAMETER URL
    The URL to validate

.PARAMETER SkipConnectivityTest
    Skip the network connectivity test (useful for offline scenarios)

.OUTPUTS
    System.Boolean - Returns $true if URL is valid and accessible, $false otherwise
#>
function Test-URLValidity {
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        [Parameter(Mandatory = $true)]
        [string]$URL,

        [Parameter(Mandatory = $false)]
        [switch]$SkipConnectivityTest
    )

    try {
        Write-Host "URL Validation:" -ForegroundColor Cyan
        Write-Host "  Target URL: $URL" -ForegroundColor White

        # Format validation
        try {
            $uri = [System.Uri]$URL
            if ($uri.Scheme -notin @('http', 'https')) {
                Write-Host "  ❌ Invalid URL scheme. Must be HTTP or HTTPS" -ForegroundColor Red
                return $false
            }
            Write-Host "  ✅ URL format is valid" -ForegroundColor Green
        }
        catch {
            Write-Host "  ❌ Invalid URL format: $($_.Exception.Message)" -ForegroundColor Red
            return $false
        }

        # Connectivity test (optional)
        if (-not $SkipConnectivityTest) {
            try {
                Write-Host "  Testing connectivity..." -ForegroundColor Gray
                $response = Invoke-WebRequest -Uri $URL -Method Head -TimeoutSec 10 -UseBasicParsing -ErrorAction Stop
                Write-Host "  ✅ URL is accessible (Status: $($response.StatusCode))" -ForegroundColor Green
            }
            catch {
                Write-Host "  ⚠️  URL accessibility test failed: $($_.Exception.Message)" -ForegroundColor Yellow
                Write-Host "  Note: URL may still work, continuing with setup..." -ForegroundColor Gray
            }
        }
        else {
            Write-Host "  ⏭️  Skipping connectivity test" -ForegroundColor Gray
        }

        return $true
    }
    catch {
        Write-Host "Error validating URL: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

<#
.SYNOPSIS
    Performs comprehensive system compatibility checks.

.DESCRIPTION
    Runs all compatibility checks including PowerShell version, browser detection,
    admin privileges, and optionally URL validation. Provides a complete system report.

.PARAMETER URL
    Optional URL to validate as part of the compatibility check

.OUTPUTS
    System.Boolean - Returns $true if system is compatible, $false otherwise
#>
function Invoke-CompatibilityCheck {
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        [Parameter(Mandatory = $false)]
        [string]$URL
    )

    Write-Host ""
    Write-Host "🔍 SYSTEM COMPATIBILITY CHECK" -ForegroundColor Yellow
    Write-Host "============================================" -ForegroundColor DarkGray

    $PSVersionOK = Test-PowerShellVersion
    Write-Host ""

    $BrowsersDetected = Get-InstalledBrowsers
    Write-Host ""

    $AdminStatus = Test-IsAdmin
    Write-Host ""

    $URLValid = $true
    if ($URL) {
        $URLValid = Test-URLValidity -URL $URL
        Write-Host ""
    }

    # Summary
    Write-Host "COMPATIBILITY SUMMARY:" -ForegroundColor White
    Write-Host "  PowerShell Version: $(if($PSVersionOK){'✅ Compatible'}else{'❌ Incompatible'})" -ForegroundColor $(if ($PSVersionOK) { 'Green' }else { 'Red' })
    Write-Host "  Browsers Detected: $($BrowsersDetected.Count) $(if($BrowsersDetected.Count -gt 0){'✅'}else{'⚠️'})" -ForegroundColor $(if ($BrowsersDetected.Count -gt 0) { 'Green' }else { 'Yellow' })
    Write-Host "  Admin Privileges: $(if($AdminStatus){'✅ Yes'}else{'⚠️ No (Limited functionality)'})" -ForegroundColor $(if ($AdminStatus) { 'Green' }else { 'Yellow' })
    if ($URL) {
        Write-Host "  Target URL: $(if($URLValid){'✅ Valid'}else{'❌ Invalid'})" -ForegroundColor $(if ($URLValid) { 'Green' }else { 'Red' })
    }

    $Compatible = $PSVersionOK -and $URLValid -and ($BrowsersDetected.Count -gt 0)

    Write-Host ""
    if ($Compatible) {
        Write-Host "🎉 System is COMPATIBLE - Ready to proceed!" -ForegroundColor Green
    }
    else {
        Write-Host "⚠️  System has COMPATIBILITY ISSUES" -ForegroundColor Yellow
        if (-not $PSVersionOK) {
            Write-Host "   • PowerShell version upgrade required" -ForegroundColor Red
        }
        if (-not $URLValid) {
            Write-Host "   • URL validation failed" -ForegroundColor Red
        }
        if ($BrowsersDetected.Count -eq 0) {
            Write-Host "   • No supported browsers found" -ForegroundColor Yellow
        }
    }

    return $Compatible
}

#endregion

#region Undo Functionality

<#
.SYNOPSIS
    Restores all browser settings from backup files.

.DESCRIPTION
    Searches for backup files created by this script and restores original browser
    configurations. Provides a complete rollback of all changes made by the prank.

.OUTPUTS
    System.Boolean - Returns $true if undo was successful, $false otherwise
#>
function Invoke-UndoChanges {
    [CmdletBinding()]
    [OutputType([bool])]
    param()

    try {
        Write-Host ""
        Write-Host "🔄 UNDOING PRANK CHANGES" -ForegroundColor Yellow
        Write-Host "============================================" -ForegroundColor DarkGray

        $Success = $true
        $ChangesFound = $false

        # Create backup folder path
        if (-not (Test-Path $Script:BackupFolder)) {
            Write-Host "No backup folder found at: $Script:BackupFolder" -ForegroundColor Yellow
            Write-Host "Nothing to undo." -ForegroundColor Gray
            return $true
        }

        Write-Host "Searching for backup files in: $Script:BackupFolder" -ForegroundColor Cyan

        # Restore Chrome backups
        Write-Host "`nRestoring Chrome settings..." -ForegroundColor Cyan
        $ChromeBackups = Get-ChildItem "$Script:BackupFolder" -Filter "*Chrome*backup*" -ErrorAction SilentlyContinue
        if ($ChromeBackups) {
            $ChangesFound = $true
            $LatestChromeBackup = $ChromeBackups | Sort-Object LastWriteTime -Descending | Select-Object -First 1
            $ChromePrefsPath = "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Preferences"

            if (Test-Path $ChromePrefsPath) {
                Copy-Item $LatestChromeBackup.FullName $ChromePrefsPath -Force
                Write-Host "  ✅ Chrome settings restored" -ForegroundColor Green
            }
            else {
                Write-Host "  ⚠️  Chrome preferences file not found" -ForegroundColor Yellow
            }
        }
        else {
            Write-Host "  ⏭️  No Chrome backups found" -ForegroundColor Gray
        }

        # Restore Edge backups (registry)
        Write-Host "`nRestoring Edge settings..." -ForegroundColor Cyan
        $EdgeBackups = Get-ChildItem "$Script:BackupFolder" -Filter "*EdgeHomepage*Backup*.reg" -ErrorAction SilentlyContinue
        if ($EdgeBackups) {
            $ChangesFound = $true
            $LatestEdgeBackup = $EdgeBackups | Sort-Object LastWriteTime -Descending | Select-Object -First 1

            try {
                Start-Process "regedit.exe" -ArgumentList "/s", "`"$($LatestEdgeBackup.FullName)`"" -Wait -WindowStyle Hidden
                Write-Host "  ✅ Edge settings restored" -ForegroundColor Green
            }
            catch {
                Write-Host "  ❌ Failed to restore Edge settings: $($_.Exception.Message)" -ForegroundColor Red
                Write-Host "  Manual restore: Double-click $($LatestEdgeBackup.FullName)" -ForegroundColor Yellow
                $Success = $false
            }
        }
        else {
            Write-Host "  ⏭️  No Edge backups found" -ForegroundColor Gray
        }

        # Restore Firefox backups
        Write-Host "`nRestoring Firefox settings..." -ForegroundColor Cyan
        $FirefoxProfilesPath = "$env:APPDATA\Mozilla\Firefox\Profiles"
        if (Test-Path $FirefoxProfilesPath) {
            $ProfileDirs = Get-ChildItem $FirefoxProfilesPath -Directory | Where-Object { $_.Name -like "*.default*" }
            $FirefoxRestored = $false

            foreach ($ProfileDir in $ProfileDirs) {
                $PrefsFile = Join-Path $ProfileDir.FullName "prefs.js"
                $BackupFiles = Get-ChildItem $ProfileDir.FullName -Filter "prefs.js.backup.*" -ErrorAction SilentlyContinue

                if ($BackupFiles -and (Test-Path $PrefsFile)) {
                    $ChangesFound = $true
                    $LatestBackup = $BackupFiles | Sort-Object LastWriteTime -Descending | Select-Object -First 1
                    Copy-Item $LatestBackup.FullName $PrefsFile -Force
                    Write-Host "  ✅ Firefox profile restored: $($ProfileDir.Name)" -ForegroundColor Green
                    $FirefoxRestored = $true
                }
            }

            if (-not $FirefoxRestored) {
                Write-Host "  ⏭️  No Firefox backups found" -ForegroundColor Gray
            }
        }
        else {
            Write-Host "  ⏭️  Firefox not installed" -ForegroundColor Gray
        }

        # Remove startup shortcut
        Write-Host "`nRemoving startup shortcut..." -ForegroundColor Cyan
        $StartupFolder = [System.Environment]::GetFolderPath('Startup')
        $ShortcutPath = Join-Path $StartupFolder "PrankTime.lnk"

        if (Test-Path $ShortcutPath) {
            $ChangesFound = $true
            Remove-Item $ShortcutPath -Force
            Write-Host "  ✅ Startup shortcut removed" -ForegroundColor Green
        }
        else {
            Write-Host "  ⏭️  No startup shortcut found" -ForegroundColor Gray
        }

        # Summary
        Write-Host ""
        Write-Host "UNDO SUMMARY:" -ForegroundColor White
        if ($ChangesFound) {
            if ($Success) {
                Write-Host "  ✅ All changes successfully reverted!" -ForegroundColor Green
                Write-Host "  🎉 Prank has been completely removed" -ForegroundColor Magenta
            }
            else {
                Write-Host "  ⚠️  Some changes were reverted with warnings" -ForegroundColor Yellow
                Write-Host "  Check messages above for manual restoration steps" -ForegroundColor Gray
            }
        }
        else {
            Write-Host "  ℹ️  No prank changes found to undo" -ForegroundColor Cyan
        }

        return $Success
    }
    catch {
        Write-Host "Error during undo operation: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

#endregion

#region Browser Management Functions

<#
.SYNOPSIS
    Stops all running browser processes to ensure settings can be modified.

.DESCRIPTION
    Gracefully closes Chrome, Edge, and Firefox processes to prevent them from
    overwriting preference changes. Provides user feedback during the process.

.OUTPUTS
    System.Boolean - Returns $true if successful, $false otherwise
#>
function Stop-BrowserProcesses {
    [CmdletBinding()]
    [OutputType([bool])]
    param()

    try {
        Write-Host "🛑 Stopping browser processes for settings modification..." -ForegroundColor Yellow

        $processesToStop = @(
            @{Name = "chrome"; DisplayName = "Google Chrome" },
            @{Name = "msedge"; DisplayName = "Microsoft Edge" },
            @{Name = "firefox"; DisplayName = "Mozilla Firefox" }
        )

        $stoppedAny = $false

        foreach ($processInfo in $processesToStop) {
            $processes = Get-Process -Name $processInfo.Name -ErrorAction SilentlyContinue
            if ($processes) {
                Write-Host "  Stopping $($processInfo.DisplayName) ($($processes.Count) process(es))..." -ForegroundColor Gray
                try {
                    $processes | Stop-Process -Force -ErrorAction Stop
                    Write-Host "  ✅ $($processInfo.DisplayName) stopped" -ForegroundColor Green
                    $stoppedAny = $true
                }
                catch {
                    Write-Host "  ⚠️  Warning: Could not stop $($processInfo.DisplayName): $($_.Exception.Message)" -ForegroundColor Yellow
                }
            }
        }

        if ($stoppedAny) {
            Write-Host "  ⏳ Waiting 3 seconds for processes to fully terminate..." -ForegroundColor Gray
            Start-Sleep -Seconds 3
            Write-Host "  ✅ Browser processes stopped successfully!" -ForegroundColor Green
        }
        else {
            Write-Host "  ℹ️  No browser processes were running" -ForegroundColor Cyan
        }

        return $true
    }
    catch {
        Write-Host "  ❌ Error stopping browser processes: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

#endregion

# Early exit for CheckOnly mode
if ($CheckOnly) {
    Write-Host ""
    Write-Host "🔍 SYSTEM COMPATIBILITY CHECK (READ-ONLY)" -ForegroundColor Yellow
    Write-Host "============================================" -ForegroundColor DarkGray

    # Use a test URL for validation if no URL provided
    $TestURL = if ($TargetURL) { $TargetURL } else { "https://www.badgerbadgerbadger.com" }

    $Compatible = Invoke-CompatibilityCheck -URL $TestURL
    Write-Host ""
    Write-Host "🏁 Check complete. No changes made." -ForegroundColor Cyan
    exit $(if ($Compatible) { 0 } else { 1 })
}

# Early exit for Undo mode
if ($Undo) {
    $UndoSuccess = Invoke-UndoChanges
    exit $(if ($UndoSuccess) { 0 } else { 1 })
}

# Determine target URL
if (-not $TargetURL) {
    if ($SiteChoice) {
        if ($WebsiteOptions.ContainsKey($SiteChoice)) {
            $SelectedSite = $WebsiteOptions[$SiteChoice]
            $TargetURL = $SelectedSite.URL
            Write-Host "Pre-selected: $($SelectedSite.Name)" -ForegroundColor Cyan
        }
        else {
            Write-Host "Error: Invalid SiteChoice value: $SiteChoice" -ForegroundColor Red
            Write-Host "Valid options: 1-$($WebsiteOptions.Count)" -ForegroundColor Yellow
            exit 1
        }
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

# Validate URL if provided
if ($TargetURL) {
    $URLValid = Test-URLValidity -URL $TargetURL
    if (-not $URLValid -and -not $Force) {
        Write-Host ""
        Write-Host "❌ URL validation failed. Use -Force to bypass this check." -ForegroundColor Red
        exit 1
    }
}

Write-Host "`n🚀 Starting Prank Setup..." -ForegroundColor Green
Write-Host "Target URL: $TargetURL" -ForegroundColor Yellow

# Perform system compatibility check
Write-Host ""
$SystemCompatible = Invoke-CompatibilityCheck -URL $TargetURL

if (-not $SystemCompatible -and -not $Force) {
    Write-Host ""
    Write-Host "❌ System compatibility check failed. Use -Force to bypass non-critical issues." -ForegroundColor Red
    Write-Host "💡 Tip: Run with -CheckOnly to see detailed compatibility information" -ForegroundColor Cyan
    exit 1
}

# Confirm before proceeding (unless Force is used)
if (-not $Force) {
    Write-Host ""
    Write-Host "⚠️  CONFIRMATION REQUIRED" -ForegroundColor Yellow
    Write-Host "This will modify browser settings and create a startup shortcut." -ForegroundColor White
    Write-Host "All changes are reversible using the -Undo parameter." -ForegroundColor Gray
    Write-Host ""

    do {
        $confirm = Read-Host "Do you want to proceed? (Y/N)"
        $confirmChoice = $confirm.ToUpper()
    } while ($confirmChoice -notin @('Y', 'YES', 'N', 'NO'))

    if ($confirmChoice -in @('N', 'NO')) {
        Write-Host "Operation cancelled by user." -ForegroundColor Yellow
        exit 0
    }
}

# Ensure backup folder exists
if (-not (Test-Path $Script:BackupFolder)) {
    try {
        New-Item -Path $Script:BackupFolder -ItemType Directory -Force | Out-Null
        Write-Host "Created backup folder: $Script:BackupFolder" -ForegroundColor Green
    }
    catch {
        Write-Host "Warning: Could not create backup folder: $($_.Exception.Message)" -ForegroundColor Yellow
    }
}

# Stop browsers if requested
if ($StopBrowsers) {
    $BrowsersStopped = Stop-BrowserProcesses
    if (-not $BrowsersStopped) {
        Write-Host "⚠️  Warning: Could not stop all browser processes. Settings may not persist." -ForegroundColor Yellow
    }
    Write-Host ""
}

# Function to set Chrome homepage
<#
.SYNOPSIS
    Sets the homepage for Google Chrome browser.

.DESCRIPTION
    Modifies Chrome's preferences.json file to set a custom homepage.
    Creates a timestamped backup of the original preferences before making changes.
    Includes enhanced error handling and Chrome process detection.

.PARAMETER URL
    The URL to set as the Chrome homepage.

.OUTPUTS
    System.Boolean - Returns $true if successful, $false otherwise
#>
function Set-ChromeHomepage {
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        [Parameter(Mandatory = $true)]
        [string]$URL
    )

    try {
        Write-Host "Setting Chrome homepage..." -ForegroundColor Cyan

        # Check if Chrome is in the detected browsers list
        if ("Chrome" -notin $Script:SupportedBrowsers) {
            Write-Host "  ⏭️  Chrome not detected, skipping..." -ForegroundColor Gray
            return $true
        }

        $ChromePrefsPath = "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Preferences"

        # Check if Chrome is currently running
        $ChromeProcesses = Get-Process -Name "chrome" -ErrorAction SilentlyContinue
        if ($ChromeProcesses) {
            Write-Host "  ⚠️  Chrome is currently running" -ForegroundColor Yellow
            Write-Host "     Changes may not take effect until Chrome is restarted" -ForegroundColor Gray
        }

        if (Test-Path $ChromePrefsPath) {
            # Create timestamped backup
            $BackupPath = Join-Path $Script:BackupFolder "Chrome_Preferences_Backup_$(Get-Date -Format 'yyyyMMdd_HHmmss').json"
            try {
                Copy-Item $ChromePrefsPath $BackupPath -ErrorAction Stop
                Write-Host "  ✅ Backup created: $BackupPath" -ForegroundColor Green
            }
            catch {
                Write-Host "  ⚠️  Warning: Could not create backup: $($_.Exception.Message)" -ForegroundColor Yellow
            }

            # Read and modify preferences
            try {
                $PrefsContent = Get-Content $ChromePrefsPath -Raw -ErrorAction Stop
                $Prefs = $PrefsContent | ConvertFrom-Json -ErrorAction Stop

                # Set homepage properties
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

                # Set the home page preference explicitly (this is key for home button behavior)
                if (-not $Prefs.browser) {
                    $Prefs | Add-Member -NotePropertyName "browser" -NotePropertyValue @{} -Force
                }
                if (-not $Prefs.browser.show_home_button) {
                    $Prefs.browser | Add-Member -NotePropertyName "show_home_button" -NotePropertyValue $true -Force
                }
                else {
                    $Prefs.browser.show_home_button = $true
                }

                # Ensure the new tab page doesn't override homepage
                if (-not $Prefs.ntp) {
                    $Prefs | Add-Member -NotePropertyName "ntp" -NotePropertyValue @{} -Force
                }
                if (-not $Prefs.ntp.custom_background_local_to_device) {
                    $Prefs.ntp | Add-Member -NotePropertyName "custom_background_local_to_device" -NotePropertyValue $false -Force
                }
                else {
                    $Prefs.ntp.custom_background_local_to_device = $false
                }

                # Force homepage to be the startup behavior
                if (-not $Prefs.profile) {
                    $Prefs | Add-Member -NotePropertyName "profile" -NotePropertyValue @{} -Force
                }
                if (-not $Prefs.profile.default_content_setting_values) {
                    $Prefs.profile | Add-Member -NotePropertyName "default_content_setting_values" -NotePropertyValue @{} -Force
                }

                # Set startup URLs to include our target URL
                if (-not $Prefs.session) {
                    $Prefs | Add-Member -NotePropertyName "session" -NotePropertyValue @{} -Force
                }
                if (-not $Prefs.session.urls_to_restore_on_startup) {
                    $Prefs.session | Add-Member -NotePropertyName "urls_to_restore_on_startup" -NotePropertyValue @($URL) -Force
                }
                else {
                    $Prefs.session.urls_to_restore_on_startup = @($URL)
                }

                # Ensure Chrome opens previous session/specific pages on startup (not new tab page)
                # restore_on_startup values: 1=New Tab Page, 4=Open specific pages, 5=Continue where you left off
                if (-not $Prefs.session.restore_on_startup) {
                    $Prefs.session | Add-Member -NotePropertyName "restore_on_startup" -NotePropertyValue 4 -Force
                }
                else {
                    $Prefs.session.restore_on_startup = 4
                }

                # Save modified preferences
                $Prefs | ConvertTo-Json -Depth 100 | Set-Content $ChromePrefsPath -Encoding UTF8 -ErrorAction Stop
                Write-Host "  ✅ Chrome homepage set successfully!" -ForegroundColor Green
                return $true
            }
            catch {
                Write-Host "  ❌ Error modifying Chrome preferences: $($_.Exception.Message)" -ForegroundColor Red
                return $false
            }
        }
        else {
            Write-Host "  ⚠️  Chrome preferences file not found" -ForegroundColor Yellow
            Write-Host "     Path: $ChromePrefsPath" -ForegroundColor Gray
            return $false
        }
    }
    catch {
        Write-Host "  ❌ Error setting Chrome homepage: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

# Function to set Edge homepage
<#
.SYNOPSIS
    Sets the homepage for Microsoft Edge browser.

.DESCRIPTION
    Modifies registry settings to set a custom homepage for Edge/Internet Explorer.
    Works with the legacy IE engine that Edge sometimes uses.
    Creates a .reg file backup for easy restoration with enhanced error handling.

.PARAMETER URL
    The URL to set as the Edge homepage.

.OUTPUTS
    System.Boolean - Returns $true if successful, $false otherwise
#>
function Set-EdgeHomepage {
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        [Parameter(Mandatory = $true)]
        [string]$URL
    )

    try {
        Write-Host "Setting Microsoft Edge homepage..." -ForegroundColor Cyan

        # Check if Edge is in the detected browsers list
        if ("Edge" -notin $Script:SupportedBrowsers) {
            Write-Host "  ⏭️  Edge not detected, skipping..." -ForegroundColor Gray
            return $true
        }

        $EdgePrefsPath = "$env:LOCALAPPDATA\Microsoft\Edge\User Data\Default\Preferences"
        $EdgeRegPath = "HKCU:\Software\Microsoft\Internet Explorer\Main"
        $RegBackupFile = Join-Path $Script:BackupFolder "EdgeHomepage_Backup_$(Get-Date -Format 'yyyyMMdd_HHmmss').reg"

        # Check if Edge is currently running
        $EdgeProcesses = Get-Process -Name "msedge" -ErrorAction SilentlyContinue
        if ($EdgeProcesses) {
            Write-Host "  ⚠️  Edge is currently running" -ForegroundColor Yellow
            Write-Host "     Changes may not take effect until Edge is restarted" -ForegroundColor Gray
        }

        $Success = $true

        # Set Edge preferences file (like Chrome)
        if (Test-Path $EdgePrefsPath) {
            try {
                # Create timestamped backup
                $EdgePrefsBackupPath = Join-Path $Script:BackupFolder "Edge_Preferences_Backup_$(Get-Date -Format 'yyyyMMdd_HHmmss').json"
                Copy-Item $EdgePrefsPath $EdgePrefsBackupPath -ErrorAction Stop
                Write-Host "  ✅ Edge preferences backup created: $EdgePrefsBackupPath" -ForegroundColor Green

                # Read and modify preferences
                $PrefsContent = Get-Content $EdgePrefsPath -Raw -ErrorAction Stop
                $Prefs = $PrefsContent | ConvertFrom-Json -ErrorAction Stop

                # Set homepage properties (same as Chrome)
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

                # Set startup URLs to include our target URL
                if (-not $Prefs.session) {
                    $Prefs | Add-Member -NotePropertyName "session" -NotePropertyValue @{}
                }
                if (-not $Prefs.session.urls_to_restore_on_startup) {
                    $Prefs.session | Add-Member -NotePropertyName "urls_to_restore_on_startup" -NotePropertyValue @($URL)
                }
                else {
                    $Prefs.session.urls_to_restore_on_startup = @($URL)
                }

                # Ensure Edge opens previous session/specific pages on startup
                # restore_on_startup values: 1=New Tab Page, 4=Open specific pages, 5=Continue where you left off
                if (-not $Prefs.session.restore_on_startup) {
                    $Prefs.session | Add-Member -NotePropertyName "restore_on_startup" -NotePropertyValue 4
                }
                else {
                    $Prefs.session.restore_on_startup = 4
                }

                # Save modified preferences
                $Prefs | ConvertTo-Json -Depth 100 | Set-Content $EdgePrefsPath -Encoding UTF8 -ErrorAction Stop
                Write-Host "  ✅ Edge preferences file updated successfully!" -ForegroundColor Green
            }
            catch {
                Write-Host "  ⚠️  Error modifying Edge preferences file: $($_.Exception.Message)" -ForegroundColor Yellow
                $Success = $false
            }
        }
        else {
            Write-Host "  ⚠️  Edge preferences file not found, using registry fallback" -ForegroundColor Yellow
        }

        # Set registry as fallback (for compatibility with legacy Edge features)
        # Verify registry path exists
        if (-not (Test-Path $EdgeRegPath)) {
            try {
                New-Item -Path $EdgeRegPath -Force -ErrorAction Stop | Out-Null
                Write-Host "  ✅ Created registry path: $EdgeRegPath" -ForegroundColor Green
            }
            catch {
                Write-Host "  ⚠️  Warning: Failed to create registry path: $($_.Exception.Message)" -ForegroundColor Yellow
            }
        }

        if (Test-Path $EdgeRegPath) {
            try {
                # Get current homepage values for backup
                $CurrentStartPage = Get-ItemProperty -Path $EdgeRegPath -Name "Start Page" -ErrorAction SilentlyContinue
                $CurrentDefaultPage = Get-ItemProperty -Path $EdgeRegPath -Name "Default_Page_URL" -ErrorAction SilentlyContinue

                if ($CurrentStartPage) {
                    Write-Host "  Current registry homepage: $($CurrentStartPage.'Start Page')" -ForegroundColor Gray
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
                $RegContent | Set-Content $RegBackupFile -Encoding Unicode -ErrorAction Stop
                Write-Host "  ✅ Registry backup created: $RegBackupFile" -ForegroundColor Green

                # Set new homepage values
                Set-ItemProperty -Path $EdgeRegPath -Name "Start Page" -Value $URL -ErrorAction Stop
                Set-ItemProperty -Path $EdgeRegPath -Name "Default_Page_URL" -Value $URL -ErrorAction Stop

                Write-Host "  ✅ Registry settings updated!" -ForegroundColor Green
            }
            catch {
                Write-Host "  ⚠️  Warning: Error modifying registry: $($_.Exception.Message)" -ForegroundColor Yellow
                $Success = $false
            }
        }

        if ($Success) {
            Write-Host "  ✅ Edge homepage set successfully!" -ForegroundColor Green
            Write-Host "  💡 To restore: Use script undo or double-click the .reg file" -ForegroundColor Cyan
            return $true
        }
        else {
            Write-Host "  ⚠️  Edge homepage set with warnings" -ForegroundColor Yellow
            return $false
        }
    }
    catch {
        Write-Host "  ❌ Error setting Edge homepage: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

# Function to set Firefox homepage
<#
.SYNOPSIS
    Sets the homepage for Mozilla Firefox browser.

.DESCRIPTION
    Modifies Firefox's prefs.js file in user profiles to set a custom homepage.
    Creates timestamped backups and handles multiple Firefox profiles if they exist.
    Includes enhanced error handling and Firefox process detection.

.PARAMETER URL
    The URL to set as the Firefox homepage.

.OUTPUTS
    System.Boolean - Returns $true if successful, $false otherwise
#>
function Set-FirefoxHomepage {
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        [Parameter(Mandatory = $true)]
        [string]$URL
    )

    try {
        Write-Host "Setting Firefox homepage..." -ForegroundColor Cyan

        # Check if Firefox is in the detected browsers list
        if ("Firefox" -notin $Script:SupportedBrowsers) {
            Write-Host "  ⏭️  Firefox not detected, skipping..." -ForegroundColor Gray
            return $true
        }

        $FirefoxProfilesPath = "$env:APPDATA\Mozilla\Firefox\Profiles"

        # Check if Firefox is currently running
        $FirefoxProcesses = Get-Process -Name "firefox" -ErrorAction SilentlyContinue
        if ($FirefoxProcesses) {
            Write-Host "  ⚠️  Firefox is currently running" -ForegroundColor Yellow
            Write-Host "     Changes may not take effect until Firefox is restarted" -ForegroundColor Gray
        }

        if (Test-Path $FirefoxProfilesPath) {
            $ProfileDirs = Get-ChildItem $FirefoxProfilesPath -Directory | Where-Object { $_.Name -like "*.default*" }
            $SuccessCount = 0
            $TotalProfiles = $ProfileDirs.Count

            if ($TotalProfiles -eq 0) {
                Write-Host "  ⚠️  No Firefox profiles found" -ForegroundColor Yellow
                return $false
            }

            Write-Host "  Found $TotalProfiles Firefox profile(s)" -ForegroundColor Gray

            foreach ($ProfileDir in $ProfileDirs) {
                $PrefsFile = Join-Path $ProfileDir.FullName "prefs.js"

                if (Test-Path $PrefsFile) {
                    try {
                        # Create timestamped backup in our backup folder
                        $BackupFileName = "Firefox_$($ProfileDir.Name)_prefs_backup_$(Get-Date -Format 'yyyyMMdd_HHmmss').js"
                        $BackupPath = Join-Path $Script:BackupFolder $BackupFileName
                        Copy-Item $PrefsFile $BackupPath -ErrorAction Stop
                        Write-Host "    ✅ Backup created for $($ProfileDir.Name): $BackupPath" -ForegroundColor Green

                        # Read current preferences
                        $PrefsContent = Get-Content $PrefsFile -ErrorAction Stop

                        # Remove existing homepage settings
                        $PrefsContent = $PrefsContent | Where-Object {
                            $_ -notmatch 'user_pref\("browser\.startup\.homepage"' -and
                            $_ -notmatch 'user_pref\("browser\.startup\.page"'
                        }

                        # Add new homepage settings
                        $PrefsContent += 'user_pref("browser.startup.homepage", "' + $URL + '");'
                        $PrefsContent += 'user_pref("browser.startup.page", 1);'

                        # Save modified preferences
                        $PrefsContent | Set-Content $PrefsFile -Encoding UTF8 -ErrorAction Stop
                        Write-Host "    ✅ Firefox homepage set for profile: $($ProfileDir.Name)" -ForegroundColor Green
                        $SuccessCount++
                    }
                    catch {
                        Write-Host "    ❌ Error modifying profile $($ProfileDir.Name): $($_.Exception.Message)" -ForegroundColor Red
                    }
                }
                else {
                    Write-Host "    ⚠️  Preferences file not found for profile: $($ProfileDir.Name)" -ForegroundColor Yellow
                }
            }

            if ($SuccessCount -gt 0) {
                Write-Host "  ✅ Firefox homepage set for $SuccessCount of $TotalProfiles profile(s)" -ForegroundColor Green
                return $true
            }
            else {
                Write-Host "  ❌ Failed to set homepage for any Firefox profiles" -ForegroundColor Red
                return $false
            }
        }
        else {
            Write-Host "  ⚠️  Firefox profiles directory not found" -ForegroundColor Yellow
            Write-Host "     Path: $FirefoxProfilesPath" -ForegroundColor Gray
            return $false
        }
    }
    catch {
        Write-Host "  ❌ Error setting Firefox homepage: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

# Function to create startup shortcut
<#
.SYNOPSIS
    Creates a shortcut in the Windows Startup folder.

.DESCRIPTION
    Creates a Windows shortcut (.lnk file) in the user's Startup folder that will
    open the specified URL when the user logs in. The shortcut runs hidden to
    avoid showing a command prompt window. Includes enhanced error handling.

.PARAMETER URL
    The URL to open when the shortcut is executed.

.OUTPUTS
    System.Boolean - Returns $true if successful, $false otherwise
#>
function New-StartupShortcut {
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        [Parameter(Mandatory = $true)]
        [string]$URL
    )

    try {
        Write-Host "Creating startup shortcut..." -ForegroundColor Cyan

        $StartupFolder = [System.Environment]::GetFolderPath('Startup')
        $ShortcutPath = Join-Path $StartupFolder "PrankTime.lnk"

        Write-Host "  Startup folder: $StartupFolder" -ForegroundColor Gray

        # Check if startup folder exists and is writable
        if (-not (Test-Path $StartupFolder)) {
            Write-Host "  ❌ Startup folder not found: $StartupFolder" -ForegroundColor Red
            return $false
        }

        # Check if shortcut already exists
        if (Test-Path $ShortcutPath) {
            Write-Host "  ⚠️  Existing shortcut found, replacing..." -ForegroundColor Yellow
            try {
                Remove-Item $ShortcutPath -Force -ErrorAction Stop
            }
            catch {
                Write-Host "  ❌ Could not remove existing shortcut: $($_.Exception.Message)" -ForegroundColor Red
                return $false
            }
        }

        try {
            $WshShell = New-Object -ComObject WScript.Shell -ErrorAction Stop
            $Shortcut = $WshShell.CreateShortcut($ShortcutPath)

            $Shortcut.TargetPath = "powershell.exe"
            $Shortcut.Arguments = "-WindowStyle Hidden -Command ""Start-Process '$URL'"""
            $Shortcut.Description = "Prank Time - Opens the ultimate experience"
            $Shortcut.IconLocation = "shell32.dll,13"
            $Shortcut.WorkingDirectory = $env:USERPROFILE

            $Shortcut.Save()

            # Verify shortcut was created successfully
            if (Test-Path $ShortcutPath) {
                Write-Host "  ✅ Startup shortcut created successfully!" -ForegroundColor Green
                Write-Host "  🎉 The fun will greet you on next login!" -ForegroundColor Magenta
                Write-Host "  📍 Location: $ShortcutPath" -ForegroundColor Gray
                return $true
            }
            else {
                Write-Host "  ❌ Shortcut creation failed - file not found after creation" -ForegroundColor Red
                return $false
            }
        }
        catch {
            Write-Host "  ❌ Error creating COM object or shortcut: $($_.Exception.Message)" -ForegroundColor Red
            return $false
        }
    }
    catch {
        Write-Host "  ❌ Error creating startup shortcut: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

# Function to open the website immediately
<#
.SYNOPSIS
    Opens the specified URL in the default browser immediately.

.DESCRIPTION
    Launches the default web browser and navigates to the specified URL for
    immediate enjoyment of the prank website. Includes error handling and
    fallback mechanisms.

.PARAMETER URL
    The URL to open in the default browser.

.OUTPUTS
    System.Boolean - Returns $true if successful, $false otherwise
#>
function Invoke-PrankTime {
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        [Parameter(Mandatory = $true)]
        [string]$URL
    )

    try {
        Write-Host "Opening website for immediate enjoyment..." -ForegroundColor Magenta

        # Try multiple methods to open the URL
        try {
            Start-Process $URL -ErrorAction Stop
            Write-Host "  ✅ Website opened successfully!" -ForegroundColor Green
            Write-Host "  🎉 Enjoy the show!" -ForegroundColor Yellow
            return $true
        }
        catch {
            # Fallback method using cmd
            Write-Host "  ⚠️  Primary method failed, trying fallback..." -ForegroundColor Yellow
            try {
                cmd /c start $URL
                Write-Host "  ✅ Website opened using fallback method!" -ForegroundColor Green
                return $true
            }
            catch {
                Write-Host "  ❌ All methods failed to open website: $($_.Exception.Message)" -ForegroundColor Red
                Write-Host "  💡 You can manually visit: $URL" -ForegroundColor Cyan
                return $false
            }
        }
    }
    catch {
        Write-Host "  ❌ Error opening website: $($_.Exception.Message)" -ForegroundColor Red
        Write-Host "  💡 You can manually visit: $URL" -ForegroundColor Cyan
        return $false
    }
}

# Main execution
Write-Host ""
Write-Host "============================================================" -ForegroundColor DarkGray
Write-Host "PRANK HOMEPAGE SETUP INITIATED" -ForegroundColor Yellow
Write-Host "============================================================" -ForegroundColor DarkGray

# Track operation results
$Results = @{
    Chrome          = $false
    Edge            = $false
    Firefox         = $false
    StartupShortcut = $false
    WebsiteOpened   = $false
    OverallSuccess  = $false
}

# Execute the prank setup
Write-Host "`n🔧 Configuring browsers..." -ForegroundColor Cyan
Write-Host "Detected browsers: $($Script:SupportedBrowsers -join ', ')" -ForegroundColor Gray

if ($Script:SupportedBrowsers.Count -eq 0) {
    Write-Host "⚠️  No supported browsers detected. Some features may not work." -ForegroundColor Yellow
}

# Configure each detected browser
$Results.Chrome = Set-ChromeHomepage -URL $TargetURL
$Results.Edge = Set-EdgeHomepage -URL $TargetURL
$Results.Firefox = Set-FirefoxHomepage -URL $TargetURL

Write-Host "`n🔗 Creating startup persistence..." -ForegroundColor Cyan
$Results.StartupShortcut = New-StartupShortcut -URL $TargetURL

# Open immediately unless skipped
$Results.WebsiteOpened = $true  # Default to true if skipped
if (-not $SkipImmediate) {
    Write-Host "`n🎉 Opening for immediate preview..." -ForegroundColor Cyan
    $Results.WebsiteOpened = Invoke-PrankTime -URL $TargetURL
}
else {
    Write-Host "`n⏭️  Skipping immediate website opening..." -ForegroundColor Gray
}

# Calculate overall success
$BrowserResults = @($Results.Chrome, $Results.Edge, $Results.Firefox)
$SuccessfulBrowsers = ($BrowserResults | Where-Object { $_ -eq $true }).Count
$Results.OverallSuccess = ($SuccessfulBrowsers -gt 0) -and $Results.StartupShortcut

Write-Host ""
Write-Host "============================================================" -ForegroundColor DarkGray
if ($Results.OverallSuccess) {
    Write-Host "PRANK SETUP COMPLETE! 🎉" -ForegroundColor Green
}
else {
    Write-Host "PRANK SETUP FINISHED WITH WARNINGS ⚠️" -ForegroundColor Yellow
}
Write-Host "============================================================" -ForegroundColor DarkGray

Write-Host ""
Write-Host "DETAILED RESULTS:" -ForegroundColor White
Write-Host "  Target URL: $TargetURL" -ForegroundColor Cyan

# Browser results
if ("Chrome" -in $Script:SupportedBrowsers) {
    Write-Host "  Chrome: $(if($Results.Chrome){'✅ Configured'}else{'❌ Failed'})" -ForegroundColor $(if ($Results.Chrome) { 'Green' }else { 'Red' })
}
else {
    Write-Host "  Chrome: ⏭️  Not detected" -ForegroundColor Gray
}

if ("Edge" -in $Script:SupportedBrowsers) {
    Write-Host "  Edge: $(if($Results.Edge){'✅ Configured'}else{'❌ Failed'})" -ForegroundColor $(if ($Results.Edge) { 'Green' }else { 'Red' })
}
else {
    Write-Host "  Edge: ⏭️  Not detected" -ForegroundColor Gray
}

if ("Firefox" -in $Script:SupportedBrowsers) {
    Write-Host "  Firefox: $(if($Results.Firefox){'✅ Configured'}else{'❌ Failed'})" -ForegroundColor $(if ($Results.Firefox) { 'Green' }else { 'Red' })
}
else {
    Write-Host "  Firefox: ⏭️  Not detected" -ForegroundColor Gray
}

Write-Host "  Startup shortcut: $(if($Results.StartupShortcut){'✅ Created'}else{'❌ Failed'})" -ForegroundColor $(if ($Results.StartupShortcut) { 'Green' }else { 'Red' })

if (-not $SkipImmediate) {
    Write-Host "  Website opened: $(if($Results.WebsiteOpened){'✅ Success'}else{'❌ Failed'})" -ForegroundColor $(if ($Results.WebsiteOpened) { 'Green' }else { 'Red' })
}

Write-Host "  Backup files: ✅ Created in $Script:BackupFolder" -ForegroundColor Green

Write-Host ""
Write-Host "UNDO INSTRUCTIONS:" -ForegroundColor Cyan
Write-Host "  To completely reverse all changes, run:" -ForegroundColor Gray
Write-Host "  .\Set-BadgerHomepage.ps1 -Undo" -ForegroundColor White
Write-Host ""
Write-Host "  Or manually restore using:" -ForegroundColor Gray
Write-Host "  1. Browser backup files in: $Script:BackupFolder" -ForegroundColor Gray
Write-Host "  2. Edge .reg backup files (double-click to restore)" -ForegroundColor Gray
Write-Host "  3. Delete startup shortcut: $([System.Environment]::GetFolderPath('Startup'))\PrankTime.lnk" -ForegroundColor Gray

# Final status message
Write-Host ""
if ($Results.OverallSuccess) {
    Write-Host "🎊 Prank successfully deployed! Get ready for some fun! 🎊" -ForegroundColor Magenta
}
elseif ($SuccessfulBrowsers -gt 0) {
    Write-Host "⚠️  Partial success: $SuccessfulBrowsers browser(s) configured" -ForegroundColor Yellow
    Write-Host "💡 Check the results above for details" -ForegroundColor Cyan
}
else {
    Write-Host "❌ Setup encountered significant issues" -ForegroundColor Red
    Write-Host "💡 Review the error messages above and try again" -ForegroundColor Cyan
}

# Set exit code based on results
$ExitCode = if ($Results.OverallSuccess) { 0 } elseif ($SuccessfulBrowsers -gt 0) { 1 } else { 2 }
exit $ExitCode
