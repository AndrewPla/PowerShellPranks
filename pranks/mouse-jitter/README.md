# 🖱️ Mouse Jitter Prank

A subtle but effective PowerShell prank that makes the mouse cursor move randomly at unpredictable intervals, creating the impression that the mouse is haunted or the computer has a mind of its own.

## 🎯 Features

- **Random mouse movements** in 8 possible directions
- **Configurable distance range** for subtle or more noticeable movements
- **Randomized intervals** between movements
- **Scheduled task option** - runs automatically at logon (Requires Admin)
- **Easy install/uninstall** with simple commands (Requires Admin)
- **Test mode** to try a single cursor movement
- **Run mode** to run without installing as a scheduled task

## 🚀 Quick Start

### Prerequisites
- Windows 10/11
- PowerShell 5.1 or later
- Administrator privileges (for scheduled task installation)

### Basic Usage

```powershell
# Run directly to output the help information
.\Start-MouseJitter.ps1

# Test with a single mouse movement
.\Start-MouseJitter.ps1 -Test

# Run with custom settings
.\Start-MouseJitter.ps1 -Run -MinDistance 2 -MaxDistance 5 -MinInterval 10 -MaxInterval 60
```

### Installation as Scheduled Task

```powershell
# Install as scheduled task (runs at logon)
.\Start-MouseJitter.ps1 -Install

# Uninstall the scheduled task
.\Start-MouseJitter.ps1 -Uninstall
```

### Testing

```powershell
# Test by moving the cursor once
.\Start-MouseJitter.ps1 -Test
```

## ⚙️ Parameters

| Parameter | Description | Default | Options |
|-----------|-------------|---------|---------|
| `-MinDistance` | Minimum distance in pixels for cursor movement | `5` | Any integer |
| `-MaxDistance` | Maximum distance in pixels for cursor movement | `10` | Any integer |
| `-MinInterval` | Minimum seconds between cursor movements | `5` | Any integer |
| `-MaxInterval` | Maximum seconds between cursor movements | `30` | Any integer |
| `-TaskName` | Scheduled task name | `MouseJitterPrank` | Any string |
| `-Install` | Install as scheduled task | - | Switch |
| `-Uninstall` | Remove scheduled task | - | Switch |
| `-Run` | Run the prank interactively | - | Switch |
| `-Test` | Test with a single cursor movement | - | Switch |

## 🔍 How It Works

1. **Movement Pattern**
   - Randomly selects one of 8 possible directions (N, NE, E, SE, S, SW, W, NW)
   - Moves cursor a random distance between the min and max distance settings
   - Creates unpredictable, natural-looking movement patterns

2. **Timing**
   - Waits a random interval between the min and max interval settings
   - Variable timing makes it harder to detect a pattern

3. **Scheduled Task**
   - When installed, creates a scheduled task that runs at user logon
   - Task runs in hidden mode automatically

## 🛡️ When the Prank is Running

- **No visible window** when run in hidden mode
- **Random timing** makes it hard to track the source
- **Subtle movements** can create confusion without being obvious

## 🔧 Troubleshooting

### Common Issues

**"Script must be run as Administrator"**
- Right-click PowerShell and select "Run as Administrator" when installing/uninstalling

**"Execution Policy" errors**
- The script uses `-ExecutionPolicy Bypass` when launching hidden

**Mouse not moving**
- Verify the script is running (check Task Manager for PowerShell processes)
- Some applications may block cursor movement in certain contexts

**Task not running at logon**
- Check Task Scheduler: `taskschd.msc` → Task Scheduler Library
- Verify task exists and is enabled

### Scheduled Task Management

**View the task:**
```powershell
Get-ScheduledTask -TaskName "MouseJitterPrank" | Format-List
```

**Run the task manually:**
```powershell
Start-ScheduledTask -TaskName "MouseJitterPrank"
```

## 🎨 Customization

### Subtle vs. Obvious Movement

For subtle movements that might be dismissed as user error:
```powershell
.\Start-MouseJitter.ps1 -Install -MinDistance 1 -MaxDistance 3 -MinInterval 30 -MaxInterval 120
```

For more obvious, irritating movements:
```powershell
.\Start-MouseJitter.ps1 -Install -MinDistance 10 -MaxDistance 25 -MinInterval 3 -MaxInterval 15
```

### Changing Task Name

If you want to make the task less obvious in the Task Scheduler:
```powershell
.\Start-MouseJitter.ps1 -Install -TaskName "SystemCursorManager"
```

## ⚠️ Disclaimer

This script is for entertainment purposes only. Please use responsibly:
- Don't use in professional environments without permission
- Consider accessibility impacts - this could be frustrating for users with motor control issues
- Some users may find random cursor movements disorienting
- Not recommended for use during critical work periods

## 🎭 Why This Prank Works

This prank exploits how people rely on precise cursor position and expect the cursor to remain stationary when not actively moving it. Small, occasional movements create doubt about whether the user accidentally bumped the mouse or if something is actually wrong with the hardware or system.

---

*Created with mischief in mind* 😈
