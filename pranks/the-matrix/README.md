# 💻 The Matrix Phantom Text Prank

A creepy PowerShell prank that opens Notepad windows at random intervals and slowly types mysterious Matrix-style messages, creating the impression that your computer is trying to communicate with you or has been hacked.

## 🎯 Features

- **20 creepy Matrix-style messages** with quotes from the movie and beyond
- **Character-by-character typing animation** for maximum effect
- **Adjustable typing speed** to control the creepiness factor
- **Personalized messages** that include the victim's username
- **Scheduled task option** - runs automatically at logon (Requires Admin)
- **Easy install/uninstall** with simple commands (Requires Admin)
- **Test mode** to preview a random message
- **Run mode** to run without installing as a scheduled task

## 🚀 Quick Start

### Prerequisites
- Windows 10/11
- PowerShell 5.1 or later
- Notepad (pre-installed on Windows)
- Administrator privileges (for scheduled task installation)

### Basic Usage

```powershell
# Run directly to output the help information
.\Start-Matrix.ps1

# Test with a single Matrix message
.\Start-Matrix.ps1 -Test

# Run with custom settings
.\Start-Matrix.ps1 -Run -MinInterval 10 -MaxInterval 30 -TypeSpeed 2
```

### Installation as Scheduled Task

```powershell
# Install as scheduled task (runs at logon)
.\Start-Matrix.ps1 -Install

# Uninstall the scheduled task
.\Start-Matrix.ps1 -Uninstall
```

### Testing

```powershell
# Test by displaying a single random Matrix message
.\Start-Matrix.ps1 -Test
```

## ⚙️ Parameters

| Parameter | Description | Default | Options |
|-----------|-------------|---------|---------|
| `-MinInterval` | Minimum interval in minutes between messages | `20` | Any integer |
| `-MaxInterval` | Maximum interval in minutes between messages | `40` | Any integer |
| `-TypeSpeed` | Typing animation speed (1-5, where 1 is fastest) | `3` | 1-5 |
| `-TaskName` | Scheduled task name | `MatrixPhantomTextPrank` | Any string |
| `-Install` | Install as scheduled task | - | Switch |
| `-Uninstall` | Remove scheduled task | - | Switch |
| `-Run` | Run the prank interactively | - | Switch |
| `-Test` | Test with a single message | - | Switch |

## 🔍 How It Works

1. **Message Selection**
   - Randomly selects from 20 pre-written Matrix-themed messages
   - Some messages incorporate the victim's username for a personalized touch
   - Includes binary code, quotes from The Matrix movie, and eerie warnings

2. **Delivery Method**
   - Opens a new Notepad window that appears suddenly on screen
   - Types the message one character at a time with random slight pauses
   - Creates an authentic "someone is typing" effect

3. **Timing**
   - Waits a random interval between the min and max interval settings
   - Variable timing makes it harder to predict when the next message will appear

4. **Scheduled Task**
   - When installed, creates a scheduled task that runs at user logon
   - Task runs in hidden mode automatically

## 💬 Sample Messages

Here are a few examples of the Matrix-style messages:

- "Wake up, [Username]..."
- "The Matrix has you..."
- "Follow the white rabbit."
- "Knock, knock..."
- "There is no spoon."
- "System breach detected. Identity compromised."
- "01101000 01100101 01101100 01110000 00100000 01101101 01100101" (Binary for "help me")

## 🛡️ When the Prank is Running

- **PowerShell runs hidden** but Notepad windows appear visibly
- **Character-by-character typing** creates an unsettling effect
- **Random timing** makes it hard to predict when the next message will appear
- **Messages remain** until closed by the user, creating evidence of the "haunting"

## 🔧 Troubleshooting

### Common Issues

**"Script must be run as Administrator"**
- Right-click PowerShell and select "Run as Administrator" when installing/uninstalling

**"Execution Policy" errors**
- The script uses `-ExecutionPolicy Bypass` when launching hidden

**No Notepad windows appearing**
- Verify the script is running (check Task Manager for PowerShell processes)
- Ensure Notepad is installed on the system
- The random interval might be longer than expected

**Task not running at logon**
- Check Task Scheduler: `taskschd.msc` → Task Scheduler Library
- Verify task exists and is enabled

### Scheduled Task Management

**View the task:**
```powershell
Get-ScheduledTask -TaskName "MatrixPhantomTextPrank" | Format-List
```

**Run the task manually:**
```powershell
Start-ScheduledTask -TaskName "MatrixPhantomTextPrank"
```

## 🎨 Customization

### Adjusting Creepiness Factor

For more frequent, faster messages (higher creepiness):
```powershell
.\Start-Matrix.ps1 -Install -MinInterval 5 -MaxInterval 15 -TypeSpeed 2
```

For subtle, slower messages (lower creepiness):
```powershell
.\Start-Matrix.ps1 -Install -MinInterval 60 -MaxInterval 180 -TypeSpeed 4
```

### Adding Your Own Messages

Open the script in a text editor and look for the `$messages = @(...)` array. Add your custom messages following the same format.

### Changing Task Name

If you want to make the task less obvious in the Task Scheduler:
```powershell
.\Start-Matrix.ps1 -Install -TaskName "SystemNotificationService"
```

## ⚠️ Disclaimer

This script is for entertainment purposes only. Please use responsibly:
- Don't use in professional environments without permission
- Could be alarming for less tech-savvy users
- Not recommended for use on shared computers where others may be confused
- May interrupt workflow by bringing Notepad windows to the foreground

## 🎭 Why This Prank Works

This prank plays on the fear of computer takeover, surveillance, and the uncanny valley effect of machines appearing to have consciousness. By using themes from "The Matrix" movie, it taps into cultural understanding of computer hacking and AI. The slow typing animation creates the unsettling impression that an intelligence is actively communicating in real-time.

---

*Created with mischief in mind* 😈
