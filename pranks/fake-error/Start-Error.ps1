<#
.SYNOPSIS
    Fake Error Message Prank - Displays humorous fake error messages at random intervals.

.DESCRIPTION
    This PowerShell prank displays funny fake error messages at random intervals,
    creating the illusion of system issues while actually being completely harmless.
    Can be installed as a scheduled task or run directly.

.PARAMETER MinInterval
    Minimum interval in minutes between error messages.
    Default: 30

.PARAMETER MaxInterval
    Maximum interval in minutes between error messages.
    Default: 120

.PARAMETER TaskName
    Name for the scheduled task (when using -Install).
    Default: FakeErrorPrank

.PARAMETER Install
    Install the prank as a scheduled task to run at startup.

.PARAMETER Uninstall
    Remove the scheduled task created by the -Install parameter.

.PARAMETER Test
    Test the prank by displaying a single error message.

.PARAMETER Run
    Run the prank continuously.

.EXAMPLE
    .\Start-Error.ps1 -Test
    # Tests the prank by showing a single error message

.EXAMPLE
    .\Start-Error.ps1 -Install
    # Installs the prank as a scheduled task that runs at startup

.EXAMPLE
    .\Start-Error.ps1 -Run -MinInterval 10 -MaxInterval 60
    # Runs the prank with error messages appearing every 10-60 minutes

.EXAMPLE
    .\Start-Error.ps1 -Uninstall
    # Uninstalls the scheduled task created by -Install

#>

param (
    [Parameter()]
    [int]$MinInterval = 30,
    
    [Parameter()]
    [int]$MaxInterval = 120,
    
    [Parameter()]
    [string]$TaskName = "FakeErrorPrank",
    
    [Parameter()]
    [switch]$Install,
    
    [Parameter()]
    [switch]$Uninstall,
    
    [Parameter()]
    [switch]$Test,
    
    [Parameter()]
    [switch]$Run
)

$errorMessages = @(
    "Critical Error: Keyboard requires cleaning. Cookie crumbs detected.",
    "Critical Failure: Internet history requires deletion. Guests arriving soon.",
    "Critical Alert: Printer actually worked on first try. Reality checking required.",
    "Critical Error: Air conditioning temperature war detected in office.",
    "System Alert: Keyboard not detected. Press F1 to continue.",
    "System Alert: High levels of sarcasm detected in recent emails.",
    "System Notice: Your 'temporary' folder contains files from 2019.",
    "System Error: Monitor detects poor posture. Spinal recalibration recommended.",
    "System Alert: USB inserted correctly on first attempt. Physics violation detected.",
    "Error: User too awesome. System cannot compute.",
    "Error: Entropy levels increasing. Universe heat death imminent.",
    "Error: Mouse movement detected but no actual work being done.",
    "Error: Quantum fluctuation detected. Your files both exist and don't exist.",
    "Error: Illegal meme detected. Humor levels exceed workplace regulations.",
    "Error: Attempted to close Excel without saving 47 times in the last hour.",
    "Error: Meeting that could have been an email in progress. CPU throttling engaged.",
    "Error: 418 I'm a teapot. Cannot brew coffee.",
    "Error: 404 Motivation not found. Please try again tomorrow.",
    "Error: 1337 User attempting to look busy when manager walks by.",
    "Error: $($Env:UserName) Too many browser tabs open. RAM critically endangered.",
    "Error: 220 Outlook contains 10,483 unread emails. Recommend 'Mark All as Read'.",
    "Warning: Coffee levels critically low. Please refill immediately.",
    "Warning: User appears stressed. Initiating mandatory cat video protocol.",
    "Warning: System detects deadlines approaching but user is on YouTube.",
    "Warning: Excessive caffeine consumption. Recommend switch to decaf.",
    "Warning: Your desk chair has detected extended sitting periods. Please stand up.",
    "Warning: Lunch detected in keyboard. Please eat over appropriate surfaces.",
    "Warning: Caps lock has been on for 3 days. Are you intentionally shouting?",
    "Warning: Deadline approaching. Procrastination levels at maximum.",
    "Alert: Your phone battery is at 3%. This is completely unrelated to your computer."
)

function Show-FakeError {
    param($message)
    
    Add-Type -AssemblyName PresentationFramework
    [System.Windows.MessageBox]::Show($message, "System Error", "OK", "Error")
}

# Function to install the prank as a scheduled task
function Install-ErrorPrank {
    Write-Host "⚠️ Installing Fake Error Message Prank..." -ForegroundColor Magenta
    
    # Check if task already exists
    $existingTask = Get-ScheduledTask -TaskName $TaskName -ErrorAction SilentlyContinue
    if ($existingTask) {
        Write-Host "Task '$TaskName' already exists. Removing old task..." -ForegroundColor Yellow
        Uninstall-ErrorPrank
    }

    try {
        # Ensure we have a full, absolute path to the script
        $currentScriptPath = $PSCommandPath
        if ([string]::IsNullOrEmpty($currentScriptPath)) {
            $currentScriptPath = $MyInvocation.MyCommand.Path
        }
        
        # Convert to absolute path if it's not already
        $scriptPath = $null
        if ([System.IO.Path]::IsPathRooted($currentScriptPath)) {
            $scriptPath = $currentScriptPath
        } else {
            $scriptPath = [System.IO.Path]::GetFullPath((Join-Path -Path (Get-Location).Path -ChildPath $currentScriptPath))
        }
        
        # Final fallback - use the current location and hardcoded filename
        if ([string]::IsNullOrEmpty($scriptPath) -or -not (Test-Path $scriptPath)) {
            $scriptPath = [System.IO.Path]::GetFullPath((Join-Path -Path (Get-Location).Path -ChildPath "Start-Error.ps1"))
        }
        
        Write-Host "Using script path: $scriptPath" -ForegroundColor Cyan
        
        # Use the -Run parameter 
        $actionArgs = "--headless powershell.exe -WindowStyle Hidden -NoProfile -NonInteractive -ExecutionPolicy Bypass -File `"$scriptPath`" -Run -MinInterval $MinInterval -MaxInterval $MaxInterval"
        $action = New-ScheduledTaskAction -Execute "conhost.exe" -Argument $actionArgs
        
        # Create trigger for logon
        $trigger = New-ScheduledTaskTrigger -AtLogon
        
        # Create principal (run as current user)
        $principal = New-ScheduledTaskPrincipal -UserId "$env:USERDOMAIN\$env:USERNAME" -LogonType Interactive
        
        # Create settings
        $settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable -ExecutionTimeLimit ([TimeSpan]::FromHours(24))
        
        # Register the scheduled task
        Register-ScheduledTask -TaskName $TaskName -Action $action -Trigger $trigger -Principal $principal -Settings $settings -Description "Displays fake error messages at random intervals"
        
        Write-Host "Successfully installed scheduled task: $TaskName" -ForegroundColor Green
        Write-Host "The prank will automatically run at next logon." -ForegroundColor Green
        Write-Host "Message interval: $MinInterval to $MaxInterval minutes" -ForegroundColor Cyan
        
        Write-Host "`nTo test now: .\Start-Error.ps1 -Test" -ForegroundColor Yellow
        Write-Host "To uninstall: .\Start-Error.ps1 -Uninstall" -ForegroundColor Yellow
    }
    catch {
        Write-Host "Failed to install scheduled task: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# Function to uninstall the prank
function Uninstall-ErrorPrank {
    Write-Host "Uninstalling Fake Error Message Prank..." -ForegroundColor Magenta
    
    # Remove scheduled task if it exists
    $existingTask = Get-ScheduledTask -TaskName $TaskName -ErrorAction SilentlyContinue
    if ($existingTask) {
        try {
            Unregister-ScheduledTask -TaskName $TaskName -Confirm:$false
            Write-Host "Successfully removed scheduled task: $TaskName" -ForegroundColor Green
        }
        catch {
            Write-Host "Failed to remove scheduled task: $($_.Exception.Message)" -ForegroundColor Red
        }
    }
    else {
        Write-Host "No scheduled task named '$TaskName' was found." -ForegroundColor Yellow
    }
}

# Function to test the prank by displaying a single message
function Test-ErrorPrank {
    Write-Host "Testing Fake Error Message Prank..." -ForegroundColor Magenta
    
    try {
        # Pick a random error message
        $randomError = $errorMessages | Get-Random
        Write-Host "Displaying a random fake error message..." -ForegroundColor Green
        
        # Display the error
        Show-FakeError -message $randomError
        
        Write-Host "Test completed successfully." -ForegroundColor Green
    }
    catch {
        Write-Host "Test failed: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# Function to show help
function Show-ErrorPrankHelp {
    Write-Host @"
Fake Error Message Prank
========================

This prank displays funny fake error messages at random intervals,
creating the illusion of system issues while being completely harmless.

USAGE:
    .\Start-Error.ps1 [OPTIONS]

OPTIONS:
    -Install              Install the prank as a scheduled task to run at startup (Requires Admin)
    -Uninstall            Remove the scheduled task created by -Install (Requires Admin)
    -Test                 Test by displaying a single error message
    -Run                  Run the prank continuously
    -MinInterval          Minimum minutes between messages (default: 30)
    -MaxInterval          Maximum minutes between messages (default: 120)
    -TaskName             Custom name for scheduled task (default: FakeErrorPrank)

EXAMPLES:
    .\Start-Error.ps1 -Install
    .\Start-Error.ps1 -Run -MinInterval 10 -MaxInterval 60
    .\Start-Error.ps1 -Test
    .\Start-Error.ps1 -Uninstall

"@ -ForegroundColor Yellow
}

# Check if running as administrator when needed
if (($Install -or $Uninstall) -and -NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Error "Administrator privileges are required to install or uninstall the scheduled task."
    Write-Host "Right-click PowerShell and select 'Run as Administrator'" -ForegroundColor Yellow
    exit 1
}

# Main execution logic based on parameters
if ($Install) {
    Install-ErrorPrank
    exit 0
}
elseif ($Uninstall) {
    Uninstall-ErrorPrank
    exit 0
}
elseif ($Test) {
    Test-ErrorPrank
    exit 0
}
elseif ($Run) {
    # Run the prank continuously
    while ($true) {
        # Show a random error
        $randomError = $errorMessages | Get-Random
        Show-FakeError -message $randomError
        
        # Wait between MinInterval-MaxInterval minutes
        $delayMinutes = Get-Random -Minimum $MinInterval -Maximum ($MaxInterval + 1)
        Write-Output "Next error will appear in $delayMinutes minutes..."
        Start-Sleep -Seconds ($delayMinutes * 60)
    }
}
else {
    # If no specific parameters given, show help
    Show-ErrorPrankHelp
}

