<#
.SYNOPSIS
    CapsLock Toggler Prank - Randomly toggles the Caps Lock key at random intervals.

.DESCRIPTION
    This PowerShell prank randomly toggles the Caps Lock key at unpredictable intervals,
    causing confusion when the user suddenly starts typing in the opposite case.
    Can be installed as a scheduled task or run directly.

.PARAMETER MinInterval
    Minimum interval in minutes between toggles.
    Default: 15

.PARAMETER MaxInterval
    Maximum interval in minutes between toggles.
    Default: 60

.PARAMETER TaskName
    Name for the scheduled task (when using -Install).
    Default: CapsLockPrank

.PARAMETER Install
    Install the prank as a scheduled task to run at startup.

.PARAMETER Uninstall
    Remove the scheduled task created by the -Install parameter.

.PARAMETER Test
    Test the prank by toggling Caps Lock once.

.PARAMETER Run
    Run the prank continuously.

.EXAMPLE
    .\SendCapsLock.ps1 -Test
    # Tests the prank by toggling Caps Lock once

.EXAMPLE
    .\SendCapsLock.ps1 -Install
    # Installs the prank as a scheduled task that runs at startup

.EXAMPLE
    .\SendCapsLock.ps1 -Run -MinInterval 5 -MaxInterval 20
    # Runs the prank with Caps Lock toggling every 5-20 minutes

.EXAMPLE
    .\SendCapsLock.ps1 -Uninstall
    # Uninstalls the scheduled task created by -Install
#>

param (
    [Parameter()]
    [int]$MinInterval = 15,
    
    [Parameter()]
    [int]$MaxInterval = 60,
    
    [Parameter()]
    [string]$TaskName = "CapsLockPrank",
    
    [Parameter()]
    [switch]$Install,
    
    [Parameter()]
    [switch]$Uninstall,
    
    [Parameter()]
    [switch]$Test,
    
    [Parameter()]
    [switch]$Run
)

function Toggle-CapsLock {
    # Toggle Caps Lock state
    $wsh = New-Object -ComObject WScript.Shell
    $wsh.SendKeys("{CAPSLOCK}")
    
    # Clean up COM object
    [System.Runtime.Interopservices.Marshal]::ReleaseComObject($wsh) | Out-Null
    [System.GC]::Collect()
    [System.GC]::WaitForPendingFinalizers()
    
    return $true
}

# Function to install the prank as a scheduled task
function Install-CapsLockPrank {
    Write-Host "⌨️ Installing CapsLock Toggler Prank..." -ForegroundColor Magenta
    
    # Check if task already exists
    $existingTask = Get-ScheduledTask -TaskName $TaskName -ErrorAction SilentlyContinue
    if ($existingTask) {
        Write-Host "Task '$TaskName' already exists. Removing old task..." -ForegroundColor Yellow
        Uninstall-CapsLockPrank
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
            $scriptPath = [System.IO.Path]::GetFullPath((Join-Path -Path (Get-Location).Path -ChildPath "SendCapsLock.ps1"))
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
        Register-ScheduledTask -TaskName $TaskName -Action $action -Trigger $trigger -Principal $principal -Settings $settings -Description "Randomly toggles Caps Lock key at unpredictable intervals"
        
        Write-Host "Successfully installed scheduled task: $TaskName" -ForegroundColor Green
        Write-Host "The prank will automatically run at next logon." -ForegroundColor Green
        Write-Host "Toggle interval: $MinInterval to $MaxInterval minutes" -ForegroundColor Cyan
        
        Write-Host "`nTo test now: .\SendCapsLock.ps1 -Test" -ForegroundColor Yellow
        Write-Host "To uninstall: .\SendCapsLock.ps1 -Uninstall" -ForegroundColor Yellow
    }
    catch {
        Write-Host "Failed to install scheduled task: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# Function to uninstall the prank
function Uninstall-CapsLockPrank {
    Write-Host "Uninstalling CapsLock Toggler Prank..." -ForegroundColor Magenta
    
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

# Function to test the prank by toggling once
function Test-CapsLockPrank {
    Write-Host "Testing CapsLock Toggler Prank..." -ForegroundColor Magenta
    
    try {
        Write-Host "Toggling Caps Lock key once..." -ForegroundColor Green
        
        # Toggle caps lock
        $result = Toggle-CapsLock
        
        if ($result) {
            Write-Host "Test completed successfully. Caps Lock was toggled." -ForegroundColor Green
            Write-Host "Check if your keyboard's Caps Lock light changed state." -ForegroundColor Cyan
        }
    }
    catch {
        Write-Host "Test failed: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# Function to show help
function Show-CapsLockPrankHelp {
    Write-Host @"
CapsLock Toggler Prank
======================

This prank randomly toggles the Caps Lock key at unpredictable intervals,
causing confusion when the user suddenly starts typing in the opposite case.

USAGE:
    .\SendCapsLock.ps1 [OPTIONS]

OPTIONS:
    -Install              Install the prank as a scheduled task to run at startup (Requires Admin)
    -Uninstall            Remove the scheduled task created by -Install (Requires Admin)
    -Test                 Test by toggling Caps Lock once
    -Run                  Run the prank continuously
    -MinInterval          Minimum minutes between toggles (default: 15)
    -MaxInterval          Maximum minutes between toggles (default: 60)
    -TaskName             Custom name for scheduled task (default: CapsLockPrank)

EXAMPLES:
    .\SendCapsLock.ps1 -Install
    .\SendCapsLock.ps1 -Run -MinInterval 5 -MaxInterval 20
    .\SendCapsLock.ps1 -Test
    .\SendCapsLock.ps1 -Uninstall

"@ -ForegroundColor Cyan
}

# Check if running as administrator when needed
if (($Install -or $Uninstall) -and -NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Error "Administrator privileges are required to install or uninstall the scheduled task."
    Write-Host "Right-click PowerShell and select 'Run as Administrator'" -ForegroundColor Yellow
    exit 1
}

# Main execution logic based on parameters
if ($Install) {
    Install-CapsLockPrank
    exit 0
}
elseif ($Uninstall) {
    Uninstall-CapsLockPrank
    exit 0
}
elseif ($Test) {
    Test-CapsLockPrank
    exit 0
}
elseif ($Run) {
    # Run the prank continuously
    while ($true) {
        # Toggle caps lock
        Toggle-CapsLock
        
        # Wait between MinInterval-MaxInterval minutes
        $delayMinutes = Get-Random -Minimum $MinInterval -Maximum ($MaxInterval + 1)
        Write-Output "Caps Lock toggled. Next toggle in $delayMinutes minutes..."
        Start-Sleep -Seconds ($delayMinutes * 60)
    }
}
else {
    # If no specific parameters given, show help
    Show-CapsLockPrankHelp
}