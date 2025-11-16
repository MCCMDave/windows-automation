# 🪟 Windows Automatisierungs-Scripts

🇩🇪 Deutsche Version | **[🇬🇧 English Version](README.md)**

---

PowerShell-Automatisierungs-Scripts für Windows-System-Administration und Wartung.

---

## 📖 Überblick

Dieses Repository enthält produktionsreife PowerShell-Scripts zur Automatisierung gängiger Windows-Administrationsaufgaben. Alle Tools sind aktiv im Einsatz und auf Windows 10/11 Systemen getestet.

---

## 🛠️ Tools

### Universal Update Manager v2.1
Umfassender Windows-Update-Manager mit Multi-Quellen-Unterstützung und Hardware-Auto-Erkennung.

**Features:**
- Windows Update, Winget und Chocolatey Unterstützung
- Automatische CPU-, GPU- und Mainboard-Erkennung
- JSON-basierte Konfiguration
- Admin-Rechte-Automatisierung
- Farbige Fortschrittsanzeige

**[→ Zum Update Manager](update-manager/)**

---

## 💻 Tech Stack

- PowerShell 5.1+
- Windows 10/11
- JSON-Konfiguration
- WMI/CIM für Hardware-Erkennung
- PSWindowsUpdate-Modul

---

## 📦 Installation

```bash
# Repository klonen
git clone https://github.com/MCCMDave/windows-automation.git
cd windows-automation

# Zu spezifischem Tool navigieren
cd update-manager

# Script ausführen (als Administrator)
.\universal-update-manager.bat
```

---

## 🎯 Anwendungsfälle

### System-Administratoren:
- Automatisiertes Update-Management über mehrere PCs
- Hardware-spezifische Treiber-Updates
- Konfigurations-basiertes Deployment

### Heimanwender:
- Windows up-to-date halten
- Automatisierte Treiber-Updates
- Ein-Klick-Update-Lösung

### IT-Abteilungen:
- Standardisierter Update-Prozess
- Konfigurierbare Update-Quellen
- Erweiterbare Architektur

---

## 📈 Geplante Tools

**Demnächst:**
- [ ] System-Cleanup-Automatisierung
- [ ] Backup-Script-Sammlung
- [ ] Netzwerk-Diagnose-Tool
- [ ] Performance-Monitoring
- [ ] Registry-Verwaltung

---

## 🔗 Verwandte Projekte

- **[python-learning](https://github.com/MCCMDave/python-learning)** - Python-Automatisierungs-Projekte
- **[homelab-automation](https://github.com/MCCMDave/homelab-automation)** - Linux-Automatisierungs-Scripts

---

## 💡 Lernreise

Diese Scripts wurden entwickelt um:
- PowerShell-Automatisierung zu lernen
- Windows-System-Administration zu verstehen
- Praktische Tools für den täglichen Gebrauch zu bauen
- Fehlerbehandlung und Logging zu üben

**Erlernte Fähigkeiten:**
- PowerShell-Scripting
- Windows-API-Interaktion
- JSON-Konfigurations-Management
- Hardware-Erkennung via WMI
- Admin-Rechte-Verwaltung

---

## 📊 Projekt-Status

- ✅ **Universal Update Manager:** Produktionsreif, v2.1
- 🔄 **Zukünftige Tools:** In Planungsphase

---

## 🤝 Beiträge

Verbesserungen und Vorschläge sind willkommen!

**Wie man beiträgt:**
1. Repository forken
2. Feature-Branch erstellen
3. Änderungen vornehmen
4. Pull Request einreichen

---

## 📄 Lizenz

MIT License - Frei nutzbar und modifizierbar

---

## 👨‍💻 Autor

**David Vaupel**  
Windows-Automatisierung | PowerShell-Entwickler | System-Administration

📧 221494616+MCCMDave@users.noreply.github.com  
💼 [LinkedIn](https://www.linkedin.com/in/david-vaupel)  
🌐 [GitHub](https://github.com/MCCMDave)

---

## 📂 Repository-Struktur

```
windows-automation/
├── update-manager/
│   ├── universal-update-manager.bat
│   ├── universal-update-manager.ps1
│   ├── update-config.json
│   └── README.md
├── .gitignore
└── README.md  # Diese Datei
```

---

**Status:** ✅ Aktiv in Entwicklung  
**Letzte Aktualisierung:** November 2025  
**Plattform:** Windows 10/11  
**Sprache:** PowerShell
