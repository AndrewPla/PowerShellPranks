# ⚠️ Fake Error Message Prank

A humorous PowerShell prank that displays funny fake error messages at random intervals, creating the illusion of system issues while being completely harmless.

## 🎯 Features

- **30 humorous error messages** covering a range of office and tech humor
- **Random message selection** for variety and unpredictability
- **Configurable timing** with randomized intervals
- **Scheduled task option** - runs automatically at logon (Requires Admin)
- **Easy install/uninstall** with simple commands (Requires Admin)
- **Test mode** to preview a random error message
- **Run mode** to run without installing as a scheduled task

## 🚀 Quick Start

### Prerequisites
- Windows 10/11
- PowerShell 5.1 or later
- Administrator privileges (for scheduled task installation)

### Basic Usage

```powershell
# Run directly to output the help information
.\Start-Error.ps1

# Test with a single random error message
.\Start-Error.ps1 -Test

# Run with custom settings
.\Start-Error.ps1 -Run -MinInterval 10 -MaxInterval 60
```

### Installation as Scheduled Task

```powershell
# Install as scheduled task (runs at logon)
.\Start-Error.ps1 -Install

# Uninstall the scheduled task
.\Start-Error.ps1 -Uninstall
```

### Testing

```powershell
# Test by showing a single error message
.\Start-Error.ps1 -Test
```

## ⚙️ Parameters

| Parameter | Description | Default | Options |
|-----------|-------------|---------|---------|
| `-MinInterval` | Minimum interval in minutes between messages | `30` | Any integer |
| `-MaxInterval` | Maximum interval in minutes between messages | `120` | Any integer |
| `-TaskName` | Scheduled task name | `FakeErrorPrank` | Any string |
| `-Install` | Install as scheduled task | - | Switch |
| `-Uninstall` | Remove scheduled task | - | Switch |
| `-Run` | Run the prank interactively | - | Switch |
| `-Test` | Test with a single error message | - | Switch |

## 🔍 How It Works

1. **Message Selection**
   - Chooses randomly from a collection of 30 humorous fake error messages
   - Messages mimic system errors but with absurd or comedic content
   - Some messages personalize using the current username

2. **Timing**
   - Waits a random interval between the min and max interval settings
   - Variable timing makes it harder to detect a pattern or source

3. **Display Method**
   - Uses Windows standard error dialog boxes that look authentic
   - Implemented using the PresentationFramework for native-looking error windows

4. **Scheduled Task**
   - When installed, creates a scheduled task that runs at user logon
   - Task runs in hidden mode automatically

## 💬 Sample Messages

Here are a few examples of the fake error messages:

- "System Alert: Keyboard not detected. Press F1 to continue."
- "Error: 404 Motivation not found. Please try again tomorrow."
- "Warning: Excessive caffeine consumption. Recommend switch to decaf."
- "Error: Mouse movement detected but no actual work being done."
- "Warning: Caps lock has been on for 3 days. Are you intentionally shouting?"

## 🛡️ When the Prank is Running

- **No visible window** when run in hidden mode
- **Random timing** makes it hard to track the source
- **Authentic-looking error dialogs** create genuine confusion
- **Harmless operation** - no actual system changes made

## 🔧 Troubleshooting

### Common Issues

**"Script must be run as Administrator"**
- Right-click PowerShell and select "Run as Administrator" when installing/uninstalling

**"Execution Policy" errors**
- The script uses `-ExecutionPolicy Bypass` when launching hidden

**No error messages appearing**
- Verify the script is running (check Task Manager for PowerShell processes)
- The random interval might be longer than expected

**Task not running at logon**
- Check Task Scheduler: `taskschd.msc` → Task Scheduler Library
- Verify task exists and is enabled

### Scheduled Task Management

**View the task:**
```powershell
Get-ScheduledTask -TaskName "FakeErrorPrank" | Format-List
```

**Run the task manually:**
```powershell
Start-ScheduledTask -TaskName "FakeErrorPrank"
```

## 🎨 Customization

### Changing Message Frequency

For more frequent messages:
```powershell
.\Start-Error.ps1 -Install -MinInterval 5 -MaxInterval 20
```

For less frequent messages:
```powershell
.\Start-Error.ps1 -Install -MinInterval 60 -MaxInterval 240
```

### Adding Custom Messages

Open the script in a text editor and look for the `$errorMessages = @(...)` array. Add your custom messages following the same format.

### Changing Task Name

If you want to make the task less obvious in the Task Scheduler:
```powershell
.\Start-Error.ps1 -Install -TaskName "SystemNotificationService"
```

## ⚠️ Disclaimer

This script is for entertainment purposes only. Please use responsibly:
- Don't use in professional environments without permission
- Consider context - avoid using during high-stress work periods
- Some users might find frequent error messages disruptive
- Not recommended during critical work or presentations

## 🎭 Why This Prank Works

This prank exploits how people are conditioned to take error messages seriously. Even when the message content is clearly absurd, the familiar format and appearance of a system error dialog causes an instant moment of concern before the humor registers.

---

*Created with mischief in mind* 😈
