# 🔄 Universal Update Manager

🇩🇪 Deutsche Version | **[🇬🇧 English Version](README.md)**

---

**Version:** 2.1  
**Plattform:** Windows 10/11  
**Sprache:** PowerShell

---

## 📖 Beschreibung

Ein umfassender Windows-Update-Manager, der Updates aus mehreren Quellen in einem einzigen Tool mit Hardware-Auto-Erkennung und flexibler Konfiguration konsolidiert.

---

## ✨ Features

### Multi-Quellen Update-Verwaltung:
- ✅ **Windows Update** - Offizielle Microsoft-Updates
- ✅ **Winget** - Microsoft Paketmanager
- ✅ **Chocolatey** - Community-Paketmanager
- ✅ **Optionale Komponenten** - Konfigurierbar via JSON

### Hardware-Auto-Erkennung:
- ✅ **CPU-Hersteller** - Intel, AMD oder andere
- ✅ **GPU-Hersteller** - NVIDIA, AMD, Intel
- ✅ **Mainboard** - MSI, ASUS, Gigabyte, etc.
- ✅ **Automatische Treiber-Auswahl** - Aktualisiert nur installierte Hardware

### Konfiguration:
- ✅ **JSON-basiert** - Einfach anzupassen
- ✅ **Flexibel** - Komponenten aktivieren/deaktivieren
- ✅ **Erweiterbar** - Neue Update-Quellen hinzufügen

### Benutzererfahrung:
- ✅ **Admin-Rechte-Prüfung** - Automatische Erhöhung
- ✅ **Fortschrittsanzeige** - Klare Status-Updates
- ✅ **Fehlerbehandlung** - Robustes Failure-Management
- ✅ **Farbige Ausgabe** - Leicht lesbar
- ✅ **Batch-Datei-Launcher** - Doppelklick-Ausführung

---

## 🚀 Installation & Nutzung

### Voraussetzungen:
- Windows 10/11
- PowerShell 5.1 oder höher
- Administrator-Rechte

### Schnellstart:
1. Alle Dateien in einen Ordner herunterladen
2. Doppelklick auf `universal-update-manager.bat`
3. Admin-Erhöhung bestätigen
4. Warten bis Updates abgeschlossen sind

### Manuelle Ausführung:
```powershell
# Als Administrator ausführen
.\universal-update-manager.ps1
```

---

## ⚙️ Konfiguration

### update-config.json Struktur:

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

### Komponenten aktivieren/deaktivieren:
- Auf `true` setzen zum Aktivieren
- Auf `false` setzen zum Deaktivieren
- Konfiguration bleibt über Ausführungen hinweg erhalten

---

## 🔧 Funktionsweise

### 1. Hardware-Erkennung:
```powershell
# Auto-Erkennung CPU-Hersteller
$cpu = Get-CimInstance Win32_Processor
if ($cpu.Name -like "*Intel*") { ... }
if ($cpu.Name -like "*AMD*") { ... }

# Auto-Erkennung GPU-Hersteller
$gpu = Get-CimInstance Win32_VideoController
if ($gpu.Name -like "*NVIDIA*") { ... }
if ($gpu.Name -like "*AMD*" -or $gpu.Name -like "*Radeon*") { ... }

# Auto-Erkennung Mainboard
$mainboard = Get-CimInstance Win32_BaseBoard
```

### 2. Update-Quellen:
- **Windows Update:** `PSWindowsUpdate` Modul
- **Winget:** Microsofts integrierter Paketmanager
- **Chocolatey:** Community-Paketmanager

### 3. Treiber-Updates:
- **Intel:** Intel Driver & Support Assistant
- **AMD:** AMD Software Adrenalin
- **NVIDIA:** GeForce Experience
- **Mainboard:** Herstellerspezifische Tools (MSI Center, etc.)

---

## 📊 Beispiel-Ausgabe

```
====================================================
   Universal Update Manager v2.1
====================================================

✓ Admin-Rechte bestätigt
✓ Konfiguration geladen
✓ Hardware-Erkennung abgeschlossen

CPU: Intel Core i7-13700F
GPU: NVIDIA GeForce RTX 4060
Mainboard: MSI MAG H610

====================================================
Starte Updates...
====================================================

[1/6] Windows Update...
  ✓ 3 Updates installiert

[2/6] Winget Updates...
  ✓ 12 Pakete aktualisiert

[3/6] Chocolatey Updates...
  ✓ 5 Pakete aktualisiert

[4/6] Intel-Treiber...
  ✓ Aktualisiert

[5/6] NVIDIA-Treiber...
  ✓ Aktualisiert

[6/6] MSI Mainboard...
  ✓ Aktualisiert

====================================================
Alle Updates erfolgreich abgeschlossen!
====================================================

Drücke eine beliebige Taste zum Beenden...
```

---

## 📁 Datei-Struktur

```
update_manager/
├── universal-update-manager.bat    # Starter
├── universal-update-manager.ps1    # Haupt-Script
├── update-config.json              # Konfiguration
└── README.md                       # Diese Datei
```

---

## 🛠️ Tech Stack

- PowerShell 5.1+
- JSON-Konfiguration
- WMI/CIM-Klassen für Hardware-Erkennung
- PSWindowsUpdate-Modul
- Winget & Chocolatey Integration

---

## 📈 Zukünftige Erweiterungen

**Geplante Features:**
- [ ] GUI-Interface mit WPF
- [ ] Geplante automatische Updates
- [ ] Update-Verlaufs-Log
- [ ] Rollback-Funktionalität
- [ ] E-Mail-Benachrichtigungen
- [ ] Multi-PC-Verwaltung

---

## 💡 Lernreise

Dieses Projekt lehrte mich:
- PowerShell-Automatisierung
- Windows-System-Administration
- JSON-Konfigurations-Management
- Hardware-Erkennung via WMI
- Fehlerbehandlung und Logging
- Admin-Rechte-Verwaltung

**Teil von:** [Windows Automation Collection](https://github.com/MCCMDave/windows-automation)

---

## 🔗 Verwandte Projekte

- [python-learning](https://github.com/MCCMDave/python-learning) - Python-Automatisierungs-Projekte
- [homelab-automation](https://github.com/MCCMDave/homelab-automation) - Linux-Automatisierung

---

## 👨‍💻 Autor

**David Vaupel**  
Windows-Automatisierungs-Enthusiast | PowerShell-Entwickler

📧 221494616+MCCMDave@users.noreply.github.com  
💼 [LinkedIn](https://www.linkedin.com/in/david-vaupel)

---

## 📄 Lizenz

MIT License - Frei nutzbar und modifizierbar

---

**Status:** ✅ Produktionsreif | Aktiv genutzt  
**Version:** 2.1  
**Letzte Aktualisierung:** November 2025  
**Plattform:** Windows 10/11
