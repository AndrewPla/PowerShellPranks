# ⌨️ CapsLock Toggler Prank

A subtle yet effective PowerShell prank that randomly toggles the Caps Lock key at unpredictable intervals, causing confusion when the victim suddenly starts typing in the opposite case.

## 🎯 Features

- **Random Caps Lock toggling** at unpredictable intervals
- **No visible indication** of what's causing the change
- **Configurable timing** with randomized intervals
- **Scheduled task option** - runs automatically at logon (Requires Admin)
- **Easy install/uninstall** with simple commands (Requires Admin)
- **Test mode** to try a single Caps Lock toggle
- **Run mode** to run without installing as a scheduled task

## 🚀 Quick Start

### Prerequisites
- Windows 10/11
- PowerShell 5.1 or later
- Administrator privileges (for scheduled task installation)

### Basic Usage

```powershell
# Run directly to output the help information
.\SendCapsLock.ps1

# Test with a single Caps Lock toggle
.\SendCapsLock.ps1 -Test

# Run with custom settings
.\SendCapsLock.ps1 -Run -MinInterval 5 -MaxInterval 20
```

### Installation as Scheduled Task

```powershell
# Install as scheduled task (runs at logon)
.\SendCapsLock.ps1 -Install

# Uninstall the scheduled task
.\SendCapsLock.ps1 -Uninstall
```

### Testing

```powershell
# Test by toggling Caps Lock once
.\SendCapsLock.ps1 -Test
```

## ⚙️ Parameters

| Parameter | Description | Default | Options |
|-----------|-------------|---------|---------|
| `-MinInterval` | Minimum interval in minutes between toggles | `15` | Any integer |
| `-MaxInterval` | Maximum interval in minutes between toggles | `60` | Any integer |
| `-TaskName` | Scheduled task name | `CapsLockPrank` | Any string |
| `-Install` | Install as scheduled task | - | Switch |
| `-Uninstall` | Remove scheduled task | - | Switch |
| `-Run` | Run the prank interactively | - | Switch |
| `-Test` | Test with a single Caps Lock toggle | - | Switch |

## 🔍 How It Works

1. **Key Simulation**
   - Uses the WScript.Shell COM object to simulate pressing the Caps Lock key
   - Properly cleans up COM objects after use to prevent memory leaks

2. **Timing**
   - Waits a random interval between the min and max interval settings
   - Variable timing makes it harder to detect a pattern or source

3. **Stealth Operation**
   - No visible window when running as a scheduled task
   - No additional cursor movement or screen changes
   - Only indication is the keyboard's Caps Lock light changing

4. **Scheduled Task**
   - When installed, creates a scheduled task that runs at user logon
   - Task runs in hidden mode automatically

## 🛡️ When the Prank is Running

- **No visible window** when run in hidden mode
- **Random timing** makes it hard to track the source
- **Minimal system impact** - only toggles a keyboard state
- **Harmless operation** - no data or settings are changed permanently

## 🔧 Troubleshooting

### Common Issues

**"Script must be run as Administrator"**
- Right-click PowerShell and select "Run as Administrator" when installing/uninstalling

**"Execution Policy" errors**
- The script uses `-ExecutionPolicy Bypass` when launching hidden

**Caps Lock not toggling**
- Some applications may intercept or handle Caps Lock differently
- Verify the script is running (check Task Manager for PowerShell processes)

**Task not running at logon**
- Check Task Scheduler: `taskschd.msc` → Task Scheduler Library
- Verify task exists and is enabled

### Scheduled Task Management

**View the task:**
```powershell
Get-ScheduledTask -TaskName "CapsLockPrank" | Format-List
```

**Run the task manually:**
```powershell
Start-ScheduledTask -TaskName "CapsLockPrank"
```

## 🎨 Customization

### Changing Toggle Frequency

For more frequent toggles:
```powershell
.\SendCapsLock.ps1 -Install -MinInterval 2 -MaxInterval 10
```

For less frequent toggles:
```powershell
.\SendCapsLock.ps1 -Install -MinInterval 30 -MaxInterval 120
```

### Changing Task Name

If you want to make the task less obvious in the Task Scheduler:
```powershell
.\SendCapsLock.ps1 -Install -TaskName "KeyboardDriverService"
```

## ⚠️ Disclaimer

This script is for entertainment purposes only. Please use responsibly:
- Don't use in professional environments without permission
- Could be disruptive during important typing tasks or password entry
- Consider accessibility impacts - some users rely on consistent keyboard behavior
- Not recommended during critical work periods or when precision typing is required

## 🎭 Why This Prank Works

This prank exploits the reflexive nature of typing - most people type without constantly looking at their keyboard or screen. When text suddenly appears in the wrong case, it creates momentary confusion as the user tries to figure out what happened. The randomized timing makes it particularly effective, as the user may not connect cause and effect.

---

*Created with mischief in mind* 😈
