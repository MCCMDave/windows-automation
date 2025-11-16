# 🪟 Windows Automation Scripts

**[🇩🇪 Deutsche Version](README_DE.md)** | 🇬🇧 English Version

---

PowerShell automation scripts for Windows system administration and maintenance.

---

## 📖 Overview

This repository contains production-ready PowerShell scripts for automating common Windows administration tasks. All tools are actively used and tested on Windows 10/11 systems.

---

## 🛠️ Tools

### Universal Update Manager v2.1
Comprehensive Windows update manager with multi-source support and hardware auto-detection.

**Features:**
- Windows Update, Winget, and Chocolatey support
- Automatic CPU, GPU, and mainboard detection
- JSON-based configuration
- Admin rights automation
- Colored progress display

**[→ View Update Manager](update-manager/)**

---

## 💻 Tech Stack

- PowerShell 5.1+
- Windows 10/11
- JSON configuration
- WMI/CIM for hardware detection
- PSWindowsUpdate module

---

## 📦 Installation

```bash
# Clone repository
git clone https://github.com/MCCMDave/windows-automation.git
cd windows-automation

# Navigate to specific tool
cd update-manager

# Run script (as Administrator)
.\universal-update-manager.bat
```

---

## 🎯 Use Cases

### System Administrators:
- Automated update management across multiple PCs
- Hardware-specific driver updates
- Configuration-based deployment

### Home Users:
- Keep Windows up-to-date
- Automated driver updates
- One-click update solution

### IT Departments:
- Standardized update process
- Configurable update sources
- Extensible architecture

---

## 📈 Planned Tools

**Coming Soon:**
- [ ] System cleanup automation
- [ ] Backup script collection
- [ ] Network diagnostics tool
- [ ] Performance monitoring
- [ ] Registry management

---

## 🔗 Related Projects

- **[python-learning](https://github.com/MCCMDave/python-learning)** - Python automation projects
- **[homelab-automation](https://github.com/MCCMDave/homelab-automation)** - Linux automation scripts

---

## 💡 Learning Journey

These scripts were developed to:
- Learn PowerShell automation
- Understand Windows system administration
- Build practical tools for daily use
- Practice error handling and logging

**Skills Gained:**
- PowerShell scripting
- Windows API interaction
- JSON configuration management
- Hardware detection via WMI
- Admin rights management

---

## 📊 Project Status

- ✅ **Universal Update Manager:** Production-ready, v2.1
- 🔄 **Future Tools:** In planning phase

---

## 🤝 Contributing

Improvements and suggestions are welcome!

**How to contribute:**
1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

---

## 📄 License

MIT License - Free to use and modify

---

## 👨‍💻 Author

**David Vaupel**  
Windows Automation | PowerShell Developer | System Administration

📧 221494616+MCCMDave@users.noreply.github.com  
💼 [LinkedIn](https://www.linkedin.com/in/david-vaupel)  
🌐 [GitHub](https://github.com/MCCMDave)

---

## 📂 Repository Structure

```
windows-automation/
├── update-manager/
│   ├── universal-update-manager.bat
│   ├── universal-update-manager.ps1
│   ├── update-config.json
│   └── README.md
├── .gitignore
└── README.md  # This file
```

---

**Status:** ✅ Active Development  
**Last Updated:** November 2025  
**Platform:** Windows 10/11  
**Language:** PowerShell
