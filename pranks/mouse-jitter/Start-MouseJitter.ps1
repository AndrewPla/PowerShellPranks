<#
.SYNOPSIS
    Mouse Jitter Prank - Makes the mouse cursor move randomly at unpredictable intervals.

.DESCRIPTION
    This PowerShell prank makes the mouse cursor move slightly in random directions
    at unpredictable intervals, creating the impression that the mouse is haunted.
    Can be installed as a scheduled task or run directly.

.PARAMETER MinDistance
    Minimum distance in pixels for cursor movement.
    Default: 5

.PARAMETER MaxDistance
    Maximum distance in pixels for cursor movement.
    Default: 10

.PARAMETER MinInterval
    Minimum interval in seconds between cursor movements.
    Default: 5

.PARAMETER MaxInterval
    Maximum interval in seconds between cursor movements.
    Default: 30

.PARAMETER TaskName
    Name for the scheduled task (when using -Install).
    Default: MouseJitterPrank

.PARAMETER Install
    Install the prank as a scheduled task to run at startup.

.PARAMETER Uninstall
    Remove the scheduled task created by the -Install parameter.

.PARAMETER Test
    Test the prank by moving the cursor once.

.PARAMETER Run
    Run the prank continuously.

.EXAMPLE
    .\Start-MouseJitter.ps1 -Test
    # Tests the prank by moving the cursor once

.EXAMPLE
    .\Start-MouseJitter.ps1 -Install
    # Installs the prank as a scheduled task that runs at startup

.EXAMPLE
    .\Start-MouseJitter.ps1 -Run -MinDistance 2 -MaxDistance 5
    # Runs the prank with subtler movements

.EXAMPLE
    .\Start-MouseJitter.ps1 -Uninstall
    # Uninstalls the scheduled task created by -Install

#>

param (
    [Parameter()]
    [int]$MinDistance = 5,
    
    [Parameter()]
    [int]$MaxDistance = 10,
    
    [Parameter()]
    [int]$MinInterval = 5,
    
    [Parameter()]
    [int]$MaxInterval = 30,
    
    [Parameter()]
    [string]$TaskName = "MouseJitterPrank",
    
    [Parameter()]
    [switch]$Install,
    
    [Parameter()]
    [switch]$Uninstall,
    
    [Parameter()]
    [switch]$Test,
    
    [Parameter()]
    [switch]$Run
)

# Make sure we have the required assembly
Add-Type -AssemblyName System.Windows.Forms

function Move-MouseRandomly {
    param(
        [Parameter()]
        [int]$MinDist = 5,
        
        [Parameter()]
        [int]$MaxDist = 10
    )
    
    # Get current cursor position
    $cursor = [System.Windows.Forms.Cursor]::Position
    
    # Determine distance to move (random within range)
    $moveDistance = Get-Random -Minimum $MinDist -Maximum ($MaxDist + 1)
    
    # Move slightly in random direction
    $direction = Get-Random -Minimum 0 -Maximum 8
    $newX = $cursor.X
    $newY = $cursor.Y
    
    switch ($direction) {
        0 { $newX -= $moveDistance; $newY -= $moveDistance } # Northwest
        1 { $newY -= $moveDistance }                         # North
        2 { $newX += $moveDistance; $newY -= $moveDistance } # Northeast
        3 { $newX -= $moveDistance }                         # West
        4 { $newX += $moveDistance }                         # East
        5 { $newX -= $moveDistance; $newY += $moveDistance } # Southwest
        6 { $newY += $moveDistance }                         # South
        7 { $newX += $moveDistance; $newY += $moveDistance } # Southeast
    }
    
    # Set the new position
    [System.Windows.Forms.Cursor]::Position = New-Object System.Drawing.Point($newX, $newY)
    try {
        return $true
    }
    catch {
        return $false
    }
}

# Function to install the prank as a scheduled task
function Install-MouseJitterPrank {
    Write-Host "🖱️ Installing Mouse Jitter Prank..." -ForegroundColor Magenta
    
    # Check if task already exists
    $existingTask = Get-ScheduledTask -TaskName $TaskName -ErrorAction SilentlyContinue
    if ($existingTask) {
        Write-Host "Task '$TaskName' already exists. Removing old task..." -ForegroundColor Yellow
        Uninstall-MouseJitterPrank
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
            $scriptPath = [System.IO.Path]::GetFullPath((Join-Path -Path (Get-Location).Path -ChildPath "Start-MouseJitter.ps1"))
        }
        
        Write-Host "Using script path: $scriptPath" -ForegroundColor Cyan
        
        # Use the -Run parameter 
        $actionArgs = "--headless powershell.exe -WindowStyle Hidden -NoProfile -NonInteractive -ExecutionPolicy Bypass -File `"$scriptPath`" -Run -MinDistance $MinDistance -MaxDistance $MaxDistance -MinInterval $MinInterval -MaxInterval $MaxInterval"
        $action = New-ScheduledTaskAction -Execute "conhost.exe" -Argument $actionArgs
        
        # Create trigger for logon
        $trigger = New-ScheduledTaskTrigger -AtLogon
        
        # Create principal (run as current user)
        $principal = New-ScheduledTaskPrincipal -UserId "$env:USERDOMAIN\$env:USERNAME" -LogonType Interactive
        
        # Create settings
        $settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable -ExecutionTimeLimit ([TimeSpan]::FromHours(24))
        
        # Register the scheduled task
        Register-ScheduledTask -TaskName $TaskName -Action $action -Trigger $trigger -Principal $principal -Settings $settings -Description "Makes the mouse cursor move randomly at unpredictable intervals"
        
        Write-Host "Successfully installed scheduled task: $TaskName" -ForegroundColor Green
        Write-Host "The prank will automatically run at next logon." -ForegroundColor Green
        Write-Host "Mouse movement distance: $MinDistance to $MaxDistance pixels" -ForegroundColor Cyan
        Write-Host "Movement interval: $MinInterval to $MaxInterval seconds" -ForegroundColor Cyan
        
        Write-Host "`nTo test now: .\Start-MouseJitter.ps1 -Test" -ForegroundColor Yellow
        Write-Host "To uninstall: .\Start-MouseJitter.ps1 -Uninstall" -ForegroundColor Yellow
    }
    catch {
        Write-Host "Failed to install scheduled task: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# Function to uninstall the prank
function Uninstall-MouseJitterPrank {
    Write-Host "Uninstalling Mouse Jitter Prank..." -ForegroundColor Magenta
    
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

# Function to test the prank by moving cursor once
function Test-MouseJitterPrank {
    Write-Host "Testing Mouse Jitter Prank..." -ForegroundColor Magenta
    
    try {
        Write-Host "Moving cursor once..." -ForegroundColor Green
        
        # Move the cursor
        $result = Move-MouseRandomly -MinDist $MinDistance -MaxDist $MaxDistance
        
        if ($result) {
            Write-Host "Test completed successfully. Mouse was moved." -ForegroundColor Green
        } else {
            Write-Host "Failed to move mouse cursor." -ForegroundColor Red
        }
    }
    catch {
        Write-Host "Test failed: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# Function to show help
function Show-MouseJitterPrankHelp {
    Write-Host @"
Mouse Jitter Prank
=================

This prank makes the mouse cursor move slightly in random directions at
unpredictable intervals, creating the impression that the mouse is haunted.

USAGE:
    .\Start-MouseJitter.ps1 [OPTIONS]

OPTIONS:
    -Install              Install the prank as a scheduled task to run at startup (Requires Admin)
    -Uninstall            Remove the scheduled task created by -Install (Requires Admin)
    -Test                 Test by moving the cursor once
    -Run                  Run the prank continuously
    -MinDistance          Minimum movement distance in pixels (default: 5)
    -MaxDistance          Maximum movement distance in pixels (default: 10)
    -MinInterval          Minimum seconds between movements (default: 5)
    -MaxInterval          Maximum seconds between movements (default: 30)
    -TaskName             Custom name for scheduled task (default: MouseJitterPrank)

EXAMPLES:
    .\Start-MouseJitter.ps1 -Install
    .\Start-MouseJitter.ps1 -Run -MinDistance 2 -MaxDistance 5
    .\Start-MouseJitter.ps1 -Test
    .\Start-MouseJitter.ps1 -Uninstall

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
    Install-MouseJitterPrank
    exit 0
}
elseif ($Uninstall) {
    Uninstall-MouseJitterPrank
    exit 0
}
elseif ($Test) {
    Test-MouseJitterPrank
    exit 0
}
elseif ($Run) {
    # Run the prank continuously
    while ($true) {
        # Move the cursor
        Move-MouseRandomly -MinDist $MinDistance -MaxDist $MaxDistance
        
        # Wait between MinInterval-MaxInterval seconds
        $delaySeconds = Get-Random -Minimum $MinInterval -Maximum ($MaxInterval + 1)
        Start-Sleep -Seconds $delaySeconds
    }
}
else {
    # If no specific parameters given, show help
    Show-MouseJitterPrankHelp
}