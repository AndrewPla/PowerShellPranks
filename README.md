# PowerShellPranks

A collection of harmless (but hilarious) PowerShell pranks contributed by the community. Just enough mischief to make your coworkers raise an eyebrow (and hopefully laugh)

## 🎯 Set-BadgerHomepage.ps1

**The Ultimate Prank Experience** - Sets the user's browser homepage to legendary fun websites and ensures they're greeted by entertainment every time they log in!

### What it does

- 🌐 Sets the homepage for Chrome, Edge, and Firefox to your choice of fun websites
- 🚀 Creates a startup shortcut that opens the chosen website on login
- 📝 Creates backup files for easy restoration
- 🎉 Opens the website immediately for instant gratification (optional)
- 🎯 Interactive menu to choose between multiple prank websites

### Available Websites

1. **Badger Badger Badger** - The classic Flash animation that loops forever
2. **Nyan Cat (10 Hours)** - The legendary rainbow cat flying through space

### How to use

**Interactive Mode (Recommended):**

```powershell
.\Set-BadgerHomepage.ps1
```

**Pre-select a website:**

```powershell
# Badger Badger Badger
.\Set-BadgerHomepage.ps1 -SiteChoice 1

# Nyan Cat
.\Set-BadgerHomepage.ps1 -SiteChoice 2
```

**Custom URL:**

```powershell
.\Set-BadgerHomepage.ps1 -TargetURL "https://your-custom-site.com"
```

**Advanced Options:**

```powershell
# Skip opening immediately
.\Set-BadgerHomepage.ps1 -SiteChoice 1 -SkipImmediate

# Get help
Get-Help .\Set-BadgerHomepage.ps1 -Full
```

### How to undo

- **Browser settings**: Restore from the automatically created backup files
- **Startup shortcut**: Delete `PrankTime.lnk` from your Startup folder
- **Quick undo**: Manual reset browser homepage in browser settings

### Requirements

- Windows PowerShell 5.1 or PowerShell 7+
- Works on current user profile (no admin rights needed for most features)
- Compatible with Windows 10/11

## Why PowerShell Pranks?

IT admins are clever, and sometimes a little chaos is just what the helpdesk needs to stay entertained. This repo is a living archive of fun, non-destructive PowerShell pranks you can play (responsibly!) on friends, coworkers, or lab machines.

⚠️ **Disclaimer:** These pranks are for educational and entertainment purposes. Always prank responsibly. Never run these scripts on production systems or without consent.

## Contributing

Got a classic prank up your sleeve? We’d love to see it!

- Fork the repo
- Add your prank script under the `/pranks` folder
- Include a short README in your subfolder explaining what it does
- Submit a PR

Please keep it **harmless** and **reversible**.

## Prank Ethics

✅ Fun, annoying, and 100% safe
❌ Malicious, destructive, or irreversible

If it messes with data, disables functionality, or causes real problems, it doesn’t belong here.

## License

MIT License — Use it, remix it, but don’t be a jerk about it.
