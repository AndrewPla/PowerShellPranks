# PowerShellPranks

A collection of harmless (but hilarious) PowerShell pranks contributed by the community. Just enough mischief to make your coworkers raise an eyebrow (and hopefully laugh)

## 🎯 Set-BadgerHomepage.ps1

**The Ultimate Prank Experience** - A comprehensive PowerShell prank script that sets browser homepages to legendary fun websites with full system compatibility checks, enhanced error handling, and complete undo functionality!

### ✨ Features

- 🔍 **Smart System Detection**: Automatically detects PowerShell version, installed browsers, and admin privileges
- 🌐 **Multi-Browser Support**: Configures Chrome, Edge, and Firefox homepages intelligently
- 🚀 **Startup Persistence**: Creates a startup shortcut for login-time surprises
- 🛡️ **URL Validation**: Validates URLs for proper format and accessibility
- 📁 **Comprehensive Backups**: Creates timestamped backup files for all changes
- 🔄 **Complete Undo**: Full rollback functionality with `-Undo` parameter
- ⚡ **Enhanced Error Handling**: Detailed error reporting and graceful failure handling
- 🎯 **Interactive Menu**: User-friendly website selection with descriptions
- 🔒 **Safety First**: Multiple confirmation prompts and safety checks
- 📊 **Detailed Reporting**: Comprehensive status reporting and results summary
- **Important Note:** Browsers that use user profiles (such as Chrome, Edge, and Firefox) may overwrite homepage and startup settings if the browser is running during script execution, or if profiles sync settings from the cloud. For best results, ensure all browsers are closed before running the script, and be aware that profile sync may revert changes.

### 🎮 Available Websites

1. **Badger Badger Badger** - The classic Flash animation that loops forever
2. **Badger Badger Badger YouTube** - The legendary animation with sound (10+ hours!)

### 📋 System Requirements

- **PowerShell**: 5.1 or higher (Windows PowerShell or PowerShell Core)
- **Operating System**: Windows (any version with PowerShell support)
- **Browsers**: At least one of Chrome, Edge, or Firefox installed
- **Permissions**: User profile access (admin rights optional but beneficial)
- **Network**: Internet connectivity for URL validation (optional)

### 🚀 Usage Examples

**Quick Start (Interactive Mode):**
```powershell
.\Set-BadgerHomepage.ps1
```

**System Compatibility Check:**
```powershell
# Check system without making changes
.\Set-BadgerHomepage.ps1 -CheckOnly
```

**Pre-select Website:**
```powershell
# Badger Badger Badger
.\Set-BadgerHomepage.ps1 -SiteChoice 1

# Badger YouTube Video
.\Set-BadgerHomepage.ps1 -SiteChoice 2
```

**Custom URL with Validation:**
```powershell
.\Set-BadgerHomepage.ps1 -TargetURL "https://your-custom-site.com"
```

**Silent Setup (Minimal Prompts):**
```powershell
.\Set-BadgerHomepage.ps1 -SiteChoice 1 -Force -SkipImmediate
```

**Complete Undo/Rollback:**
```powershell
# Completely reverse all changes
.\Set-BadgerHomepage.ps1 -Undo
```

### 🛠️ Advanced Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `-TargetURL` | String | Custom URL (must be HTTP/HTTPS) |
| `-SiteChoice` | Int | Pre-select website (1-2) |
| `-SkipImmediate` | Switch | Don't open website immediately |
| `-Undo` | Switch | Reverse all changes completely |
| `-CheckOnly` | Switch | System check without changes |
| `-Force` | Switch | Bypass safety checks and prompts |

### 🔧 What It Does

1. **System Validation**:
   - Checks PowerShell version compatibility (5.1+)
   - Detects installed browsers (Chrome, Edge, Firefox)
   - Verifies admin privileges and provides guidance
   - Validates target URLs for format and accessibility

2. **Browser Configuration**:
   - Sets homepage for each detected browser
   - Creates timestamped backup files before changes
   - Handles browser-specific settings and preferences
   - Detects running browser processes and provides warnings

3. **Startup Integration**:
   - Creates Windows startup shortcut for login-time activation
   - Uses hidden PowerShell execution to avoid command prompt windows
   - Configures shortcut with appropriate icons and descriptions

4. **Safety & Recovery**:
   - Comprehensive backup system with timestamps
   - Complete undo functionality via `-Undo` parameter
   - Registry backup files (.reg) for easy Edge restoration
   - Detailed error reporting and troubleshooting guidance

### 🔄 Undo Instructions

**Automatic Undo (Recommended):**
```powershell
.\Set-BadgerHomepage.ps1 -Undo
```

**Manual Restoration:**
1. **Browser Settings**: Restore from backup files in `%TEMP%\PowerShellPranks\`
2. **Edge Registry**: Double-click the `.reg` backup files
3. **Startup Shortcut**: Delete `%USERPROFILE%\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup\PrankTime.lnk`

### 📊 Exit Codes

- `0`: Complete success
- `1`: Partial success (some browsers configured)
- `2`: Significant failures (no browsers configured)

### 🛡️ Safety Features

- **Non-Destructive**: All changes are completely reversible
- **Backup Everything**: Timestamped backups of all modified files
- **Smart Detection**: Only modifies detected/installed browsers
- **Process Awareness**: Warns when browsers are running
- **URL Validation**: Checks URL format and accessibility
- **Error Handling**: Graceful handling of all error conditions
- **User Confirmation**: Multiple confirmation prompts (unless `-Force` used)

### 🎭 Prank Responsibly

This script is designed for harmless fun among colleagues and friends. Always:
- Get permission before pranking others
- Inform targets how to undo changes
- Use in appropriate environments only
- Respect workplace policies and relationships

### 🔍 Troubleshooting

**Common Issues:**

1. **"PowerShell version incompatible"**
   - Upgrade to PowerShell 5.1 or higher
   - Use Windows PowerShell or PowerShell Core

2. **"No browsers detected"**
   - Install Chrome, Edge, or Firefox
   - Check browser installation paths

3. **"URL validation failed"**
   - Verify URL format (must start with http:// or https://)
   - Check internet connectivity
   - Use `-Force` to bypass validation

4. **"Permission denied errors"**
   - Run as Administrator for system-wide changes
   - Check antivirus software interference

**Getting Help:**
```powershell
# View detailed parameter help
Get-Help .\Set-BadgerHomepage.ps1 -Detailed

# View examples
Get-Help .\Set-BadgerHomepage.ps1 -Examples

# Check system compatibility
.\Set-BadgerHomepage.ps1 -CheckOnly
```

## Why PowerShell Pranks?

IT admins are clever, and sometimes a little chaos is just what the helpdesk needs to stay entertained. This repo is a living archive of fun, non-destructive PowerShell pranks you can play (responsibly!) on friends, coworkers, or lab machines.

⚠️ **Disclaimer:** These pranks are for educational and entertainment purposes. Always prank responsibly. Never run these scripts on production systems or without consent.

## Contributing

Got a classic prank up your sleeve? We'd love to see it!

- Fork the repo
- Add your prank script under the `/pranks` folder
- Include a short README in your subfolder explaining what it does
- Submit a PR

Please keep it **harmless** and **reversible**.

## Prank Ethics

✅ Fun, annoying, and 100% safe
❌ Malicious, destructive, or irreversible

If it messes with data, disables functionality, or causes real problems, it doesn't belong here.

## License

MIT License — Use it, remix it, but don't be a jerk about it.
