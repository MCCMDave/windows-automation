# Universal Update Manager

**[Deutsche Version](README_DE.md)** | English Version

---

**Version:** 2.2
**Platform:** Windows 10/11
**Language:** PowerShell

> This project was developed with AI assistance (Claude) and also serves as a learning project for better understanding PowerShell automation.

---

## Description

A comprehensive Windows update manager that consolidates updates from multiple sources into a single tool with hardware auto-detection and flexible configuration.

---

## Features

### Multi-Source Update Management:
- **Windows Update** - Official Microsoft updates
- **Winget** - Microsoft package manager
- **Chocolatey** - Community package manager
- **Microsoft Store** - UWP app updates

### Hardware Auto-Detection:
- **CPU Vendor** - Intel, AMD
- **GPU Vendor** - NVIDIA (App + GeForce Experience), AMD, Intel
- **Mainboard** - MSI Center support
- **Automatic Driver Selection** - Updates only relevant hardware

### Configuration:
- **JSON-based** - Easy to customize
- **Flexible** - Enable/disable components individually
- **KISS Principle** - Only settings that are actually used

---

## Installation & Usage

### Requirements:
- Windows 10/11
- PowerShell 5.1 or higher
- Administrator rights

### Quick Start:
1. Download all files to a folder
2. Double-click `universal-update-manager.bat`
3. Confirm admin elevation
4. Select option from menu

### Manual Execution:
```powershell
# Run as Administrator
.\universal-update-manager.ps1
```

---

## Configuration

### update-config.json Structure:

```json
{
  "updateSources": {
    "winget": { "enabled": true, "autoAccept": false },
    "chocolatey": { "enabled": true, "autoAccept": false },
    "windowsUpdate": { "enabled": true, "includeDrivers": true },
    "microsoftStore": { "enabled": true }
  },
  "hardwareVendors": {
    "nvidia": { "enabled": true },
    "intel": { "enabled": true },
    "msi": { "enabled": true }
  }
}
```

### Enable/Disable Components:
- Set `enabled` to `true` or `false`
- Configuration persists across runs

---

## Driver Updates

| Vendor | Tool | Notes |
|--------|------|-------|
| **NVIDIA** | NVIDIA App (priority) or GeForce Experience | Auto-detected |
| **Intel** | Intel Driver & Support Assistant | Auto-detected |
| **MSI** | MSI Center | Mainboard auto-detected |

---

## Log Files

Logs are stored in:
```
%LOCALAPPDATA%\UpdateManager\universal-update-manager.log
```

**Log Rotation:** When the log exceeds 5 MB, it's archived automatically. Only the last 3 archives are kept.

---

## File Structure

```
update_manager/
├── universal-update-manager.bat    # Launcher (admin elevation)
├── universal-update-manager.ps1    # Main script
├── update-config.json              # Configuration
├── README.md                       # English documentation
└── README_DE.md                    # German documentation
```

---

## Changelog

### v2.2 (2025-11-23)
- Added NVIDIA App support (replaces GeForce Experience)
- Hardware vendor `enabled` flags now respected
- Cleaned up config (KISS principle)
- Log path moved to `%LOCALAPPDATA%\UpdateManager`
- Log rotation: archives when > 5 MB, keeps last 3
- Summary display after "All Updates" with duration
- Simplified prerequisites check

### v2.1 (2025-11-02)
- Config settings now actually used
- PSWindowsUpdate module check at startup
- Special character fixes
- Improved error handling

---

## Author

**David Vaupel**
Windows Automation Enthusiast | PowerShell Learner

---

## License

MIT License - Free to use and modify

---

**Status:** Production-Ready
**Last Updated:** November 2025
