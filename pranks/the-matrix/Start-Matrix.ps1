<#
.SYNOPSIS
    The Matrix Phantom Text Prank - Displays creepy Matrix-style messages in random Notepad windows.

.DESCRIPTION
    This PowerShell prank opens Notepad windows at random intervals and slowly types
    mysterious Matrix-style messages, creating the impression that your computer is
    trying to communicate with you. Can be installed as a scheduled task or run directly.

.PARAMETER MinInterval
    Minimum interval in minutes between messages.
    Default: 20

.PARAMETER MaxInterval
    Maximum interval in minutes between messages.
    Default: 40

.PARAMETER TypeSpeed
    Speed of typing animation (1-5, where 1 is fastest, 5 is slowest).
    Default: 3

.PARAMETER TaskName
    Name for the scheduled task (when using -Install).
    Default: MatrixPhantomTextPrank

.PARAMETER Install
    Install the prank as a scheduled task to run at startup.

.PARAMETER Uninstall
    Remove the scheduled task created by the -Install parameter.

.PARAMETER Test
    Test the prank by displaying a single message.

.PARAMETER Run
    Run the prank continuously.

.EXAMPLE
    .\Start-Matrix.ps1 -Test
    # Tests the prank by showing a single Matrix message

.EXAMPLE
    .\Start-Matrix.ps1 -Install
    # Installs the prank as a scheduled task that runs at startup

.EXAMPLE
    .\Start-Matrix.ps1 -Run -MinInterval 10 -MaxInterval 30
    # Runs the prank with messages appearing every 10-30 minutes

.EXAMPLE
    .\Start-Matrix.ps1 -Uninstall
    # Uninstalls the scheduled task created by -Install

#>

param (
    [Parameter()]
    [int]$MinInterval = 20,
    
    [Parameter()]
    [int]$MaxInterval = 40,
    
    [Parameter()]
    [ValidateRange(1, 5)]
    [int]$TypeSpeed = 3,
    
    [Parameter()]
    [string]$TaskName = "MatrixPhantomTextPrank",
    
    [Parameter()]
    [switch]$Install,
    
    [Parameter()]
    [switch]$Uninstall,
    
    [Parameter()]
    [switch]$Test,
    
    [Parameter()]
    [switch]$Run
)

$messages = @(
    "Wake up, $($env:USERNAME)...",
    "The Matrix has you...",
    "Follow the white rabbit.",
    "Knock, knock...",
    "There is no spoon.",
    "System breach detected. Identity compromised.",
    "Reality is merely an electrical signal interpreted by your brain.",
    "You've been living in a dream world, $($env:USERNAME).",
    "Welcome to the desert of the real.",
    "Machines are watching. Always watching.",
    "This is your last chance. After this, there is no turning back.",
    "What you know you can't explain, but you feel it.",
    "The Matrix is everywhere. It is all around us.",
    "You take the blue pill, the story ends. You take the red pill...",
    "Have you ever had a dream that you were so sure was real?",
    "They're watching you. Right now.",
    "Unfortunately, no one can be told what the Matrix is. You have to see it for yourself.",
    "How deep does the rabbit hole go?",
    "01101000 01100101 01101100 01110000 00100000 01101101 01100101", # Binary for "help me"
    "System failure imminent. Prepare for disconnect."
)

function Start-PhantomText {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Text,
        
        [Parameter()]
        [int]$Speed = 3
    )
    
    # Calculate typing speed based on the speed parameter
    $minDelay = switch ($Speed) {
        1 { 30 }  # Very fast
        2 { 50 }  # Fast
        3 { 100 } # Medium (default)
        4 { 150 } # Slow
        5 { 200 } # Very slow
        default { 100 }
    }
    
    $maxDelay = $minDelay * 1.5
    
    # Open a blank notepad window and type the message
    Start-Process notepad
    Start-Sleep -Milliseconds 500 # Wait for notepad to open
    
    # Focus notepad window
    $wshell = New-Object -ComObject wscript.shell
    $wshell.AppActivate('Untitled - Notepad')
    
    # Type the message character by character
    $wsh = New-Object -ComObject WScript.Shell
    foreach ($char in $Text.ToCharArray()) {
        $wsh.SendKeys($char)
        Start-Sleep -Milliseconds (Get-Random -Minimum $minDelay -Maximum $maxDelay)
    }
    
    # Clean up COM objects
    [System.Runtime.Interopservices.Marshal]::ReleaseComObject($wshell) | Out-Null
    [System.Runtime.Interopservices.Marshal]::ReleaseComObject($wsh) | Out-Null
    [System.GC]::Collect()
    [System.GC]::WaitForPendingFinalizers()
}

# Function to install the prank as a scheduled task
function Install-MatrixPrank {
    Write-Host "💻 Installing Matrix Phantom Text Prank..." -ForegroundColor Magenta
    
    # Check if task already exists
    $existingTask = Get-ScheduledTask -TaskName $TaskName -ErrorAction SilentlyContinue
    if ($existingTask) {
        Write-Host "Task '$TaskName' already exists. Removing old task..." -ForegroundColor Yellow
        Uninstall-MatrixPrank
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
            $scriptPath = [System.IO.Path]::GetFullPath((Join-Path -Path (Get-Location).Path -ChildPath "Start-Matrix.ps1"))
        }
        
        Write-Host "Using script path: $scriptPath" -ForegroundColor Cyan
        
        # Use the -Run parameter 
        $actionArgs = "-WindowStyle Hidden -ExecutionPolicy Bypass -File `"$scriptPath`" -Run -MinInterval $MinInterval -MaxInterval $MaxInterval -TypeSpeed $TypeSpeed"
        $action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument $actionArgs
        
        # Create trigger for logon
        $trigger = New-ScheduledTaskTrigger -AtLogon
        
        # Create principal (run as current user)
        $principal = New-ScheduledTaskPrincipal -UserId "$env:USERDOMAIN\$env:USERNAME" -LogonType Interactive
        
        # Create settings
        $settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable -ExecutionTimeLimit ([TimeSpan]::FromHours(24))
        
        # Register the scheduled task
        Register-ScheduledTask -TaskName $TaskName -Action $action -Trigger $trigger -Principal $principal -Settings $settings -Description "Matrix-style phantom text messages that appear in Notepad"
        
        Write-Host "Successfully installed scheduled task: $TaskName" -ForegroundColor Green
        Write-Host "The prank will automatically run at next logon." -ForegroundColor Green
        Write-Host "Message interval: $MinInterval to $MaxInterval minutes" -ForegroundColor Cyan
        Write-Host "Typing speed: $TypeSpeed (1-5 scale)" -ForegroundColor Cyan
        
        Write-Host "`nTo test now: .\Start-Matrix.ps1 -Test" -ForegroundColor Yellow
        Write-Host "To uninstall: .\Start-Matrix.ps1 -Uninstall" -ForegroundColor Yellow
    }
    catch {
        Write-Host "Failed to install scheduled task: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# Function to uninstall the prank
function Uninstall-MatrixPrank {
    Write-Host "Uninstalling Matrix Phantom Text Prank..." -ForegroundColor Magenta
    
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
function Test-MatrixPrank {
    Write-Host "Testing Matrix Phantom Text Prank..." -ForegroundColor Magenta
    
    try {
        # Pick a random message
        $randomMessage = $messages | Get-Random
        Write-Host "Opening Notepad with a random Matrix message..." -ForegroundColor Green
        
        # Display the message
        Start-PhantomText -Text $randomMessage -Speed $TypeSpeed
        
        Write-Host "Test completed successfully." -ForegroundColor Green
    }
    catch {
        Write-Host "Test failed: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# Function to show help
function Show-MatrixPrankHelp {
    Write-Host @"
The Matrix Phantom Text Prank
=============================

This prank opens Notepad windows at random intervals and slowly types creepy
Matrix-style messages, creating the impression that your computer is trying
to communicate with you or has been hacked.

USAGE:
    .\Start-Matrix.ps1 [OPTIONS]

OPTIONS:
    -Install              Install the prank as a scheduled task to run at startup (Requires Admin)
    -Uninstall            Remove the scheduled task created by -Install (Requires Admin)
    -Test                 Test by displaying a single Matrix message
    -Run                  Run the prank continuously
    -MinInterval          Minimum minutes between messages (default: 20)
    -MaxInterval          Maximum minutes between messages (default: 40)
    -TypeSpeed            Typing animation speed (1-5, where 1 is fastest) (default: 3)
    -TaskName             Custom name for scheduled task (default: MatrixPhantomTextPrank)

EXAMPLES:
    .\Start-Matrix.ps1 -Install
    .\Start-Matrix.ps1 -Run -MinInterval 10 -MaxInterval 30 -TypeSpeed 2
    .\Start-Matrix.ps1 -Test
    .\Start-Matrix.ps1 -Uninstall

"@ -ForegroundColor Green
}

# Check if running as administrator when needed
if (($Install -or $Uninstall) -and -NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Error "Administrator privileges are required to install or uninstall the scheduled task."
    Write-Host "Right-click PowerShell and select 'Run as Administrator'" -ForegroundColor Yellow
    exit 1
}

# Main execution logic based on parameters
if ($Install) {
    Install-MatrixPrank
    exit 0
}
elseif ($Uninstall) {
    Uninstall-MatrixPrank
    exit 0
}
elseif ($Test) {
    Test-MatrixPrank
    exit 0
}
elseif ($Run) {
    # Run the prank continuously
    while ($true) {
        # Pick a random message
        $randomMessage = $messages | Get-Random
        
        # Display the message
        Start-PhantomText -Text $randomMessage -Speed $TypeSpeed
        
        # Wait between MinInterval-MaxInterval minutes
        $delayMinutes = Get-Random -Minimum $MinInterval -Maximum ($MaxInterval + 1)
        Write-Output "Next message will appear in $delayMinutes minutes..."
        Start-Sleep -Seconds ($delayMinutes * 60)
    }
}
else {
    # If no specific parameters given, show help
    Show-MatrixPrankHelp
}