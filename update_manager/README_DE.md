# Universal Update Manager

Deutsche Version | **[English Version](README.md)**

---

**Version:** 2.2
**Plattform:** Windows 10/11
**Sprache:** PowerShell

> Dieses Projekt wurde mit KI-Unterstuetzung (Claude) entwickelt und dient auch als Lernprojekt zum besseren Verstaendnis von PowerShell-Automatisierung.

---

## Beschreibung

Ein umfassender Windows-Update-Manager, der Updates aus mehreren Quellen in einem einzigen Tool mit Hardware-Auto-Erkennung und flexibler Konfiguration zusammenfasst.

---

## Features

### Multi-Quellen Update-Verwaltung:
- **Windows Update** - Offizielle Microsoft-Updates
- **Winget** - Microsoft Paketmanager
- **Chocolatey** - Community-Paketmanager
- **Microsoft Store** - UWP-App Updates

### Hardware-Auto-Erkennung:
- **CPU-Hersteller** - Intel, AMD
- **GPU-Hersteller** - NVIDIA (App + GeForce Experience), AMD, Intel
- **Mainboard** - MSI Center Unterstuetzung
- **Automatische Treiber-Auswahl** - Aktualisiert nur relevante Hardware

### Konfiguration:
- **JSON-basiert** - Einfach anzupassen
- **Flexibel** - Komponenten einzeln aktivieren/deaktivieren
- **KISS-Prinzip** - Nur Einstellungen die tatsaechlich genutzt werden

---

## Installation & Nutzung

### Voraussetzungen:
- Windows 10/11
- PowerShell 5.1 oder hoeher
- Administrator-Rechte

### Schnellstart:
1. Alle Dateien in einen Ordner herunterladen
2. Doppelklick auf `universal-update-manager.bat`
3. Admin-Erhoehung bestaetigen
4. Option aus Menue waehlen

### Manuelle Ausfuehrung:
```powershell
# Als Administrator ausfuehren
.\universal-update-manager.ps1
```

---

## Konfiguration

### update-config.json Struktur:

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

### Komponenten aktivieren/deaktivieren:
- `enabled` auf `true` oder `false` setzen
- Konfiguration bleibt ueber Ausfuehrungen hinweg erhalten

---

## Treiber-Updates

| Hersteller | Tool | Hinweise |
|------------|------|----------|
| **NVIDIA** | NVIDIA App (Prioritaet) oder GeForce Experience | Auto-erkannt |
| **Intel** | Intel Driver & Support Assistant | Auto-erkannt |
| **MSI** | MSI Center | Mainboard auto-erkannt |

---

## Log-Dateien

Logs werden gespeichert in:
```
%LOCALAPPDATA%\UpdateManager\universal-update-manager.log
```

---

## Datei-Struktur

```
update_manager/
├── universal-update-manager.bat    # Starter (Admin-Erhoehung)
├── universal-update-manager.ps1    # Haupt-Script
├── update-config.json              # Konfiguration
├── README.md                       # Englische Dokumentation
└── README_DE.md                    # Deutsche Dokumentation
```

---

## Changelog

### v2.2 (23.11.2025)
- NVIDIA App Support hinzugefuegt (ersetzt GeForce Experience)
- Hardware-Vendor `enabled`-Flags werden jetzt beachtet
- Config aufgeraeumt (KISS-Prinzip)
- Log-Pfad nach `%LOCALAPPDATA%\UpdateManager` verschoben
- Vereinfachte Voraussetzungspruefung

### v2.1 (02.11.2025)
- Config-Settings werden jetzt tatsaechlich genutzt
- PSWindowsUpdate Modul-Check beim Start
- Sonderzeichen-Fixes
- Verbesserte Fehlerbehandlung

---

## Autor

**David Vaupel**
Windows-Automatisierungs-Enthusiast | PowerShell-Lernender

---

## Lizenz

MIT License - Frei nutzbar und modifizierbar

---

**Status:** Produktionsreif
**Letzte Aktualisierung:** November 2025
