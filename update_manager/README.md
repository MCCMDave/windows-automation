# 🔄 Universal Update Manager

**[🇩🇪 Deutsche Version](README_DE.md)** | 🇬🇧 English Version

---

**Version:** 2.1  
**Platform:** Windows 10/11  
**Language:** PowerShell

---

## 📖 Description

A comprehensive Windows update manager that consolidates updates from multiple sources into a single tool with hardware auto-detection and flexible configuration.

---

## ✨ Features

### Multi-Source Update Management:
- ✅ **Windows Update** - Official Microsoft updates
- ✅ **Winget** - Microsoft package manager
- ✅ **Chocolatey** - Community package manager
- ✅ **Optional Components** - Configurable via JSON

### Hardware Auto-Detection:
- ✅ **CPU Vendor** - Intel, AMD, or other
- ✅ **GPU Vendor** - NVIDIA, AMD, Intel
- ✅ **Mainboard** - MSI, ASUS, Gigabyte, etc.
- ✅ **Automatic Driver Selection** - Updates only installed hardware

### Configuration:
- ✅ **JSON-based** - Easy to customize
- ✅ **Flexible** - Enable/disable components
- ✅ **Extensible** - Add new update sources

### User Experience:
- ✅ **Admin Rights Check** - Automatic elevation
- ✅ **Progress Display** - Clear status updates
- ✅ **Error Handling** - Robust failure management
- ✅ **Colored Output** - Easy to read
- ✅ **Batch File Launcher** - Double-click execution

---

## 🚀 Installation & Usage

### Requirements:
- Windows 10/11
- PowerShell 5.1 or higher
- Administrator rights

### Quick Start:
1. Download all files to a folder
2. Double-click `universal-update-manager.bat`
3. Confirm admin elevation
4. Wait for updates to complete

### Manual Execution:
```powershell
# Run as Administrator
.\universal-update-manager.ps1
```

---

## ⚙️ Configuration

### update-config.json Structure:

```json
{
  "components": {
    "windows_update": true,
    "winget": true,
    "chocolatey": true,
    "cpu_drivers": true,
    "gpu_drivers": true,
    "mainboard_drivers": true
  },
  "settings": {
    "auto_reboot": false,
    "create_restore_point": true,
    "verbose_logging": false
  }
}
```

### Enable/Disable Components:
- Set to `true` to enable
- Set to `false` to disable
- Configuration persists across runs

---

## 🔧 How It Works

### 1. Hardware Detection:
```powershell
# Auto-detect CPU vendor
$cpu = Get-CimInstance Win32_Processor
if ($cpu.Name -like "*Intel*") { ... }
if ($cpu.Name -like "*AMD*") { ... }

# Auto-detect GPU vendor
$gpu = Get-CimInstance Win32_VideoController
if ($gpu.Name -like "*NVIDIA*") { ... }
if ($gpu.Name -like "*AMD*" -or $gpu.Name -like "*Radeon*") { ... }

# Auto-detect Mainboard
$mainboard = Get-CimInstance Win32_BaseBoard
```

### 2. Update Sources:
- **Windows Update:** `PSWindowsUpdate` module
- **Winget:** Microsoft's built-in package manager
- **Chocolatey:** Community package manager

### 3. Driver Updates:
- **Intel:** Intel Driver & Support Assistant
- **AMD:** AMD Software Adrenalin
- **NVIDIA:** GeForce Experience
- **Mainboard:** Vendor-specific tools (MSI Center, etc.)

---

## 📊 Example Output

```
====================================================
   Universal Update Manager v2.1
====================================================

✓ Admin rights confirmed
✓ Configuration loaded
✓ Hardware detection complete

CPU: Intel Core i7-13700F
GPU: NVIDIA GeForce RTX 4060
Mainboard: MSI MAG H610

====================================================
Starting Updates...
====================================================

[1/6] Windows Update...
  ✓ 3 updates installed

[2/6] Winget Updates...
  ✓ 12 packages updated

[3/6] Chocolatey Updates...
  ✓ 5 packages updated

[4/6] Intel Drivers...
  ✓ Updated

[5/6] NVIDIA Drivers...
  ✓ Updated

[6/6] MSI Mainboard...
  ✓ Updated

====================================================
All updates completed successfully!
====================================================

Press any key to exit...
```

---

## 📁 File Structure

```
update_manager/
├── universal-update-manager.bat    # Launcher
├── universal-update-manager.ps1    # Main script
├── update-config.json              # Configuration
└── README.md                       # This file
```

---

## 🛠️ Tech Stack

- PowerShell 5.1+
- JSON configuration
- WMI/CIM classes for hardware detection
- PSWindowsUpdate module
- Winget & Chocolatey integration

---

## 📈 Future Enhancements

**Planned Features:**
- [ ] GUI interface with WPF
- [ ] Scheduled automatic updates
- [ ] Update history log
- [ ] Rollback functionality
- [ ] Email notifications
- [ ] Multi-PC management

---

## 💡 Learning Journey

This project taught me:
- PowerShell automation
- Windows system administration
- JSON configuration management
- Hardware detection via WMI
- Error handling and logging
- Admin rights management

**Part of:** [Windows Automation Collection](https://github.com/MCCMDave/windows-automation)

---

## 🔗 Related Projects

- [python-learning](https://github.com/MCCMDave/python-learning) - Python automation projects
- [homelab-automation](https://github.com/MCCMDave/homelab-automation) - Linux automation

---

## 👨‍💻 Author

**David Vaupel**  
Windows Automation Enthusiast | PowerShell Developer

📧 221494616+MCCMDave@users.noreply.github.com  
💼 [LinkedIn](https://www.linkedin.com/in/david-vaupel)

---

## 📄 License

MIT License - Free to use and modify

---

**Status:** ✅ Production-Ready | Actively Used  
**Version:** 2.1  
**Last Updated:** November 2025  
**Platform:** Windows 10/11
