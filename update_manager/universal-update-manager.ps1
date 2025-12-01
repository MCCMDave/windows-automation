<#
.SYNOPSIS
    Universal Update Manager v2.2 - Zentrale Update-Verwaltung fuer Windows

.DESCRIPTION
    Vereint alle Update-Quellen in einem Script:
    - Winget (Desktop-Apps)
    - Chocolatey (Package Manager)
    - Windows Update (OS & Sicherheit)
    - Microsoft Store Apps
    - Hersteller-Updates (NVIDIA, Intel, MSI)

.NOTES
    Autor: Dave
    Datum: 23.11.2025
    Version: 2.2
    Projekt: Homelab & System-Verwaltung

.CHANGELOG
    v2.2 (23.11.2025):
    - NVIDIA App Support hinzugefuegt (ersetzt GeForce Experience)
    - Hardware-Vendor enabled-Flags werden jetzt beachtet
    - Config aufgeraeumt (KISS-Prinzip)
    - Log-Pfad nach %LOCALAPPDATA%\UpdateManager verschoben
    - Vereinfachte Voraussetzungspruefung

    v2.1 (02.11.2025):
    - Config-Settings werden jetzt tatsaechlich genutzt
    - PSWindowsUpdate Modul-Check beim Start
    - Sonderzeichen-Fixes (Coding Guidelines)
    - Bessere Fehlerbehandlung
#>

#Requires -RunAsAdministrator

# ============================================
# KONFIGURATION
# ============================================

$ErrorActionPreference = "Continue"
$ScriptVersion = "2.2"
$LogDir = "$env:LOCALAPPDATA\UpdateManager"
if (-not (Test-Path $LogDir)) { New-Item -ItemType Directory -Path $LogDir -Force | Out-Null }
$LogFile = "$LogDir\universal-update-manager.log"
$ConfigFile = "$PSScriptRoot\update-config.json"
$MaxLogSizeMB = 5

# Log-Rotation: Wenn Log > 5 MB, alte Datei archivieren
if (Test-Path $LogFile) {
    $logSize = (Get-Item $LogFile).Length / 1MB
    if ($logSize -gt $MaxLogSizeMB) {
        $archiveName = "$LogDir\universal-update-manager_$(Get-Date -Format 'yyyyMMdd_HHmmss').log"
        Move-Item $LogFile $archiveName -Force
        # Nur die letzten 3 Archive behalten
        Get-ChildItem "$LogDir\universal-update-manager_*.log" |
            Sort-Object LastWriteTime -Descending |
            Select-Object -Skip 3 |
            Remove-Item -Force
    }
}

# Farben
$ColorSuccess = "Green"
$ColorError = "Red"
$ColorWarning = "Yellow"
$ColorInfo = "Cyan"
$ColorHeader = "Magenta"

# Globale Config-Variable
$Global:Config = $null

# ============================================
# LOGGING FUNKTION
# ============================================

function Write-Log {
    param(
        [string]$Message,
        [string]$Level = "INFO"
    )
    
    $Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $LogMessage = "[$Timestamp] [$Level] $Message"
    
    try {
        # In Datei schreiben
        Add-Content -Path $LogFile -Value $LogMessage -ErrorAction SilentlyContinue
    } catch {
        # Wenn Logging fehlschlägt, trotzdem weitermachen
        Write-Host "WARNUNG: Logging fehlgeschlagen!" -ForegroundColor Yellow
    }
    
    # Auf Konsole ausgeben
    switch ($Level) {
        "SUCCESS" { Write-Host $Message -ForegroundColor $ColorSuccess }
        "ERROR"   { Write-Host $Message -ForegroundColor $ColorError }
        "WARNING" { Write-Host $Message -ForegroundColor $ColorWarning }
        "INFO"    { Write-Host $Message -ForegroundColor $ColorInfo }
        default   { Write-Host $Message }
    }
}

# ============================================
# KONFIGURATION LADEN
# ============================================

function Load-Config {
    if (Test-Path $ConfigFile) {
        try {
            $config = Get-Content $ConfigFile -Raw | ConvertFrom-Json
            Write-Log "Konfiguration geladen: $ConfigFile" "SUCCESS"
            return $config
        } catch {
            Write-Log "Fehler beim Laden der Konfiguration: $($_.Exception.Message)" "ERROR"
            Write-Log "Verwende Standard-Einstellungen..." "WARNING"
            return $null
        }
    } else {
        Write-Log "Konfigurationsdatei nicht gefunden: $ConfigFile" "WARNING"
        Write-Log "Verwende Standard-Einstellungen..." "WARNING"
        return $null
    }
}

# ============================================
# VORAUSSETZUNGEN PRÜFEN
# ============================================

function Test-Prerequisites {
    Write-Log "Pruefe Voraussetzungen..." "INFO"

    # Internet-Verbindung pruefen (kritisch)
    if (-not (Test-InternetConnection)) {
        Write-Log "Keine Internet-Verbindung!" "ERROR"
        return $false
    }
    Write-Log "Internet-Verbindung OK" "SUCCESS"

    # Winget pruefen (optional)
    if (Test-WingetAvailable) {
        Write-Log "Winget verfuegbar" "SUCCESS"
    } else {
        Write-Log "Winget nicht gefunden" "WARNING"
    }

    return $true
}

# ============================================
# HARDWARE-ERKENNUNG
# ============================================

function Get-HardwareInfo {
    Write-Log "Erkenne Hardware..." "INFO"
    
    $hardware = @{
        CPU = ""
        GPU = ""
        Mainboard = ""
        HasNVIDIA = $false
        HasIntel = $false
        HasMSI = $false
    }
    
    try {
        # CPU
        $cpu = Get-CimInstance Win32_Processor -ErrorAction Stop | Select-Object -First 1
        $hardware.CPU = $cpu.Name
        $hardware.HasIntel = $cpu.Name -like "*Intel*"
        
        Write-Log "CPU: $($hardware.CPU)" "INFO"
        
    } catch {
        Write-Log "Fehler bei CPU-Erkennung: $($_.Exception.Message)" "ERROR"
        $hardware.CPU = "Unbekannt"
    }
    
    try {
        # GPU
        $gpu = Get-CimInstance Win32_VideoController -ErrorAction Stop | Where-Object { $_.Name -notlike "*Microsoft*" } | Select-Object -First 1
        if ($gpu) {
            $hardware.GPU = $gpu.Name
            $hardware.HasNVIDIA = $gpu.Name -like "*NVIDIA*"
            Write-Log "GPU: $($hardware.GPU)" "INFO"
        } else {
            $hardware.GPU = "Keine dedizierte GPU gefunden"
            Write-Log "GPU: Keine dedizierte GPU gefunden" "INFO"
        }
        
    } catch {
        Write-Log "Fehler bei GPU-Erkennung: $($_.Exception.Message)" "ERROR"
        $hardware.GPU = "Unbekannt"
    }
    
    try {
        # Mainboard
        $board = Get-CimInstance Win32_BaseBoard -ErrorAction Stop
        $hardware.Mainboard = "$($board.Manufacturer) $($board.Product)"
        $hardware.HasMSI = $board.Manufacturer -like "*Micro-Star*"
        
        Write-Log "Mainboard: $($hardware.Mainboard)" "INFO"
        
    } catch {
        Write-Log "Fehler bei Mainboard-Erkennung: $($_.Exception.Message)" "ERROR"
        $hardware.Mainboard = "Unbekannt"
    }
    
    return $hardware
}

# ============================================
# VERFÜGBARKEIT PRÜFEN
# ============================================

function Test-WingetAvailable {
    try {
        $null = Get-Command winget -ErrorAction Stop
        return $true
    } catch {
        return $false
    }
}

function Test-ChocoAvailable {
    try {
        $null = Get-Command choco -ErrorAction Stop
        return $true
    } catch {
        return $false
    }
}

function Test-InternetConnection {
    try {
        $result = Test-Connection -ComputerName 8.8.8.8 -Count 1 -Quiet -ErrorAction Stop
        return $result
    } catch {
        return $false
    }
}

function Test-PSWindowsUpdateModule {
    try {
        $module = Get-Module -ListAvailable -Name PSWindowsUpdate
        return ($null -ne $module)
    } catch {
        return $false
    }
}

# ============================================
# UPDATE-FUNKTIONEN
# ============================================

function Update-Winget {
    Write-Host "`n"
    Write-Host "============================================" -ForegroundColor $ColorHeader
    Write-Host "WINGET UPDATES" -ForegroundColor $ColorHeader
    Write-Host "============================================`n" -ForegroundColor $ColorHeader
    
    # Config-Check
    if ($Global:Config -and -not $Global:Config.updateSources.winget.enabled) {
        Write-Log "Winget-Updates sind in der Config deaktiviert" "WARNING"
        Write-Host "Winget-Updates sind deaktiviert (Config).`n" -ForegroundColor $ColorWarning
        return
    }
    
    if (-not (Test-WingetAvailable)) {
        Write-Log "Winget ist nicht verfuegbar!" "ERROR"
        Write-Host "Winget ist nicht installiert!`n" -ForegroundColor $ColorError
        Write-Host "Hinweis: Winget ist auf Windows 11 vorinstalliert." -ForegroundColor $ColorInfo
        Write-Host "Ansonsten: 'App Installer' im Microsoft Store installieren.`n" -ForegroundColor $ColorInfo
        return
    }
    
    Write-Log "Starte Winget Updates..." "INFO"
    
    try {
        # Prüfe ob Updates verfügbar sind
        Write-Host "Pruefe auf Updates...`n" -ForegroundColor $ColorInfo
        
        $upgradeList = winget upgrade 2>&1
        $hasUpdates = $upgradeList -match "upgrades available"
        
        if ($hasUpdates) {
            Write-Host $upgradeList
            Write-Host "`n"
            
            # Auto-Accept aus Config?
            $autoAccept = $false
            if ($Global:Config -and $Global:Config.updateSources.winget.autoAccept) {
                $autoAccept = $true
            }
            
            if (-not $autoAccept) {
                $response = Read-Host "Updates installieren? (J/N)"
                if ($response -ne "J" -and $response -ne "j") {
                    Write-Log "Winget Updates uebersprungen." "WARNING"
                    return
                }
            }
            
            Write-Host "`nInstalliere Updates...`n" -ForegroundColor $ColorInfo
            winget upgrade --all --include-unknown --accept-source-agreements --accept-package-agreements
            Write-Log "Winget Updates abgeschlossen!" "SUCCESS"
            
        } else {
            Write-Host "Keine Winget-Updates verfuegbar.`n" -ForegroundColor $ColorSuccess
            Write-Log "Keine Winget-Updates verfuegbar." "SUCCESS"
        }
        
    } catch {
        Write-Log "Fehler bei Winget Updates: $($_.Exception.Message)" "ERROR"
        Write-Host "FEHLER bei Winget Updates: $($_.Exception.Message)`n" -ForegroundColor $ColorError
    }
}

function Update-Chocolatey {
    Write-Host "`n"
    Write-Host "============================================" -ForegroundColor $ColorHeader
    Write-Host "CHOCOLATEY UPDATES" -ForegroundColor $ColorHeader
    Write-Host "============================================`n" -ForegroundColor $ColorHeader
    
    # Config-Check
    if ($Global:Config -and -not $Global:Config.updateSources.chocolatey.enabled) {
        Write-Log "Chocolatey-Updates sind in der Config deaktiviert" "WARNING"
        Write-Host "Chocolatey-Updates sind deaktiviert (Config).`n" -ForegroundColor $ColorWarning
        return
    }
    
    if (-not (Test-ChocoAvailable)) {
        Write-Log "Chocolatey ist nicht verfuegbar!" "WARNING"
        Write-Host "Chocolatey ist nicht installiert!`n" -ForegroundColor $ColorWarning
        Write-Host "Installation:" -ForegroundColor $ColorInfo
        Write-Host "PowerShell als Admin > Set-ExecutionPolicy Bypass -Scope Process -Force" -ForegroundColor $ColorInfo
        Write-Host "iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))`n" -ForegroundColor $ColorInfo
        return
    }
    
    Write-Log "Starte Chocolatey Updates..." "INFO"
    
    try {
        # Chocolatey selbst updaten
        Write-Host "Aktualisiere Chocolatey selbst...`n" -ForegroundColor $ColorInfo
        choco upgrade chocolatey -y
        
        # Prüfe auf veraltete Pakete
        Write-Host "`nPruefe auf veraltete Pakete...`n" -ForegroundColor $ColorInfo
        
        $outdated = choco outdated 2>&1
        Write-Host $outdated
        
        # Zähle Updates
        $updateCount = ($outdated | Select-String "outdated").Count
        
        if ($updateCount -gt 0) {
            Write-Host "`n"
            
            # Auto-Accept aus Config?
            $autoAccept = $false
            if ($Global:Config -and $Global:Config.updateSources.chocolatey.autoAccept) {
                $autoAccept = $true
            }
            
            if (-not $autoAccept) {
                $response = Read-Host "Pakete aktualisieren? (J/N)"
                if ($response -ne "J" -and $response -ne "j") {
                    Write-Log "Chocolatey Updates uebersprungen." "WARNING"
                    return
                }
            }
            
            Write-Host "`nAktualisiere Pakete...`n" -ForegroundColor $ColorInfo
            choco upgrade all -y
            Write-Log "Chocolatey Updates abgeschlossen!" "SUCCESS"
            
        } else {
            Write-Host "`nKeine Chocolatey-Updates verfuegbar.`n" -ForegroundColor $ColorSuccess
            Write-Log "Keine Chocolatey-Updates verfuegbar." "SUCCESS"
        }
        
    } catch {
        Write-Log "Fehler bei Chocolatey Updates: $($_.Exception.Message)" "ERROR"
        Write-Host "FEHLER bei Chocolatey Updates: $($_.Exception.Message)`n" -ForegroundColor $ColorError
    }
}

function Update-Windows {
    Write-Host "`n"
    Write-Host "============================================" -ForegroundColor $ColorHeader
    Write-Host "WINDOWS UPDATE" -ForegroundColor $ColorHeader
    Write-Host "============================================`n" -ForegroundColor $ColorHeader
    
    # Config-Check
    if ($Global:Config -and -not $Global:Config.updateSources.windowsUpdate.enabled) {
        Write-Log "Windows-Updates sind in der Config deaktiviert" "WARNING"
        Write-Host "Windows-Updates sind deaktiviert (Config).`n" -ForegroundColor $ColorWarning
        return
    }
    
    # PSWindowsUpdate Modul prüfen
    if (-not (Test-PSWindowsUpdateModule)) {
        Write-Log "PSWindowsUpdate Modul nicht gefunden!" "ERROR"
        Write-Host "PSWindowsUpdate Modul ist nicht installiert!`n" -ForegroundColor $ColorError

        # PowerShell Version anzeigen
        $psVersion = $PSVersionTable.PSVersion.Major
        Write-Host "Aktuelle PowerShell Version: $psVersion" -ForegroundColor $ColorInfo
        if ($psVersion -ge 7) {
            Write-Host "Hinweis: PowerShell 7+ nutzt eigene Module (nicht kompatibel mit PS 5.1)`n" -ForegroundColor $ColorWarning
        }

        Write-Host "Installation:" -ForegroundColor $ColorInfo
        Write-Host "Install-Module -Name PSWindowsUpdate -Force -Scope CurrentUser`n" -ForegroundColor $ColorInfo
        
        $response = Read-Host "Modul jetzt installieren? (J/N)"
        if ($response -eq "J" -or $response -eq "j") {
            try {
                Write-Host "`nInstalliere PSWindowsUpdate Modul...`n" -ForegroundColor $ColorInfo
                Install-Module -Name PSWindowsUpdate -Force -Scope CurrentUser -ErrorAction Stop
                Write-Host "Modul erfolgreich installiert!`n" -ForegroundColor $ColorSuccess
                Write-Log "PSWindowsUpdate Modul installiert" "SUCCESS"
            } catch {
                Write-Host "FEHLER bei Installation: $($_.Exception.Message)`n" -ForegroundColor $ColorError
                Write-Log "Fehler bei PSWindowsUpdate Installation: $($_.Exception.Message)" "ERROR"
                return
            }
        } else {
            return
        }
    }
    
    Write-Log "Starte Windows Updates..." "INFO"
    
    try {
        # Modul importieren
        Import-Module PSWindowsUpdate -ErrorAction Stop
        
        Write-Host "Suche nach Windows-Updates...`n" -ForegroundColor $ColorInfo
        
        # Suche Updates
        $updates = Get-WindowsUpdate -MicrosoftUpdate
        
        if ($updates.Count -eq 0) {
            Write-Host "Keine Windows-Updates verfuegbar.`n" -ForegroundColor $ColorSuccess
            Write-Log "Keine Windows-Updates verfuegbar." "SUCCESS"
            return
        }
        
        Write-Host "Gefundene Updates:" -ForegroundColor $ColorInfo
        $updates | Format-Table -Property Title, Size
        
        Write-Host "`n"
        $response = Read-Host "Updates installieren? (J/N)"
        
        if ($response -eq "J" -or $response -eq "j") {
            Write-Host "`nInstalliere Updates...`n" -ForegroundColor $ColorInfo
            
            # Treiber einbeziehen?
            $includeDrivers = $true
            if ($Global:Config -and $Global:Config.updateSources.windowsUpdate.includeDrivers -eq $false) {
                $includeDrivers = $false
            }
            
            if ($includeDrivers) {
                Install-WindowsUpdate -MicrosoftUpdate -AcceptAll -AutoReboot:$false
            } else {
                Install-WindowsUpdate -MicrosoftUpdate -AcceptAll -AutoReboot:$false -NotCategory "Drivers"
            }
            
            Write-Log "Windows Updates abgeschlossen!" "SUCCESS"
            
            # Neustart erforderlich?
            $rebootRequired = Get-WURebootStatus -Silent
            if ($rebootRequired) {
                Write-Host "`nHINWEIS: Neustart erforderlich!`n" -ForegroundColor $ColorWarning
                Write-Log "Neustart erforderlich nach Windows Updates" "WARNING"
            }
            
        } else {
            Write-Log "Windows Updates uebersprungen." "WARNING"
        }
        
    } catch {
        Write-Log "Fehler bei Windows Updates: $($_.Exception.Message)" "ERROR"
        Write-Host "FEHLER bei Windows Updates: $($_.Exception.Message)`n" -ForegroundColor $ColorError
    }
}

function Update-MicrosoftStore {
    Write-Host "`n"
    Write-Host "============================================" -ForegroundColor $ColorHeader
    Write-Host "MICROSOFT STORE APPS" -ForegroundColor $ColorHeader
    Write-Host "============================================`n" -ForegroundColor $ColorHeader
    
    # Config-Check
    if ($Global:Config -and -not $Global:Config.updateSources.microsoftStore.enabled) {
        Write-Log "Microsoft Store Updates sind in der Config deaktiviert" "WARNING"
        Write-Host "Microsoft Store Updates sind deaktiviert (Config).`n" -ForegroundColor $ColorWarning
        return
    }
    
    Write-Log "Oeffne Microsoft Store..." "INFO"
    
    try {
        Write-Host "Oeffne Microsoft Store...`n" -ForegroundColor $ColorInfo
        
        # Öffne Store direkt bei Downloads & Updates
        Start-Process "ms-windows-store://downloadsandupdates"
        
        Write-Host "Microsoft Store geoeffnet!" -ForegroundColor $ColorSuccess
        Write-Host "Bitte manuell auf 'Alle aktualisieren' klicken.`n" -ForegroundColor $ColorInfo
        
        Write-Log "Microsoft Store geoeffnet" "SUCCESS"
        
    } catch {
        Write-Log "Fehler beim Oeffnen des Microsoft Store: $($_.Exception.Message)" "ERROR"
        Write-Host "FEHLER: $($_.Exception.Message)`n" -ForegroundColor $ColorError
    }
}

function Update-NVIDIA {
    param($Hardware)

    if (-not $Hardware.HasNVIDIA) {
        Write-Log "Keine NVIDIA-Grafikkarte erkannt. Ueberspringe..." "INFO"
        return
    }

    # Config enabled-Check
    if ($Global:Config -and -not $Global:Config.hardwareVendors.nvidia.enabled) {
        Write-Log "NVIDIA-Updates sind in der Config deaktiviert" "INFO"
        return
    }

    Write-Host "`n"
    Write-Host "============================================" -ForegroundColor $ColorHeader
    Write-Host "NVIDIA TREIBER-UPDATE" -ForegroundColor $ColorHeader
    Write-Host "============================================`n" -ForegroundColor $ColorHeader

    Write-Log "Pruefe NVIDIA-Treiber..." "INFO"

    try {
        # NVIDIA App (neu, ab 2024) - hat Prioritaet
        $nvidiaAppPaths = @(
            "C:\Program Files\NVIDIA Corporation\NVIDIA App\CEF\NVIDIA App.exe",
            "C:\Program Files (x86)\NVIDIA Corporation\NVIDIA App\CEF\NVIDIA App.exe"
        )

        if ($Global:Config -and $Global:Config.hardwareVendors.nvidia.nvidiaAppPath) {
            $nvidiaAppPaths = @($Global:Config.hardwareVendors.nvidia.nvidiaAppPath) + $Global:Config.hardwareVendors.nvidia.nvidiaAppAlternativePaths
        }

        foreach ($path in $nvidiaAppPaths) {
            if (Test-Path $path) {
                Write-Host "Starte NVIDIA App..." -ForegroundColor $ColorInfo
                Start-Process $path -ErrorAction SilentlyContinue
                Write-Host "NVIDIA App gestartet!" -ForegroundColor $ColorSuccess
                Write-Host "Pruefe auf Treiber-Updates unter 'Treiber'.`n" -ForegroundColor $ColorInfo
                Write-Log "NVIDIA App gestartet: $path" "SUCCESS"
                return
            }
        }

        # Fallback: GeForce Experience (Legacy)
        $gfePaths = @(
            "C:\Program Files\NVIDIA Corporation\NVIDIA GeForce Experience\NVIDIA GeForce Experience.exe",
            "C:\Program Files (x86)\NVIDIA Corporation\NVIDIA GeForce Experience\NVIDIA GeForce Experience.exe"
        )

        if ($Global:Config -and $Global:Config.hardwareVendors.nvidia.geforceExperiencePath) {
            $gfePaths = @($Global:Config.hardwareVendors.nvidia.geforceExperiencePath) + $Global:Config.hardwareVendors.nvidia.alternativePaths
        }

        foreach ($path in $gfePaths) {
            if (Test-Path $path) {
                Write-Host "Starte NVIDIA GeForce Experience..." -ForegroundColor $ColorInfo
                Start-Process $path -ErrorAction SilentlyContinue
                Write-Host "GeForce Experience gestartet!" -ForegroundColor $ColorSuccess
                Write-Host "Pruefe auf Treiber-Updates unter 'Treiber' > 'Nach Updates suchen'.`n" -ForegroundColor $ColorInfo
                Write-Log "NVIDIA GeForce Experience gestartet: $path" "SUCCESS"
                return
            }
        }

        Write-Host "Weder NVIDIA App noch GeForce Experience gefunden.`n" -ForegroundColor $ColorWarning
        Write-Host "Download NVIDIA App: https://www.nvidia.com/de-de/software/nvidia-app/`n" -ForegroundColor $ColorInfo
        Write-Log "NVIDIA App/GeForce Experience nicht gefunden" "WARNING"

    } catch {
        Write-Log "Fehler bei NVIDIA-Update: $($_.Exception.Message)" "ERROR"
        Write-Host "FEHLER: $($_.Exception.Message)`n" -ForegroundColor $ColorError
    }
}

function Update-Intel {
    param($Hardware)

    if (-not $Hardware.HasIntel) {
        Write-Log "Kein Intel-Prozessor erkannt. Ueberspringe..." "INFO"
        return
    }

    # Config enabled-Check
    if ($Global:Config -and -not $Global:Config.hardwareVendors.intel.enabled) {
        Write-Log "Intel-Updates sind in der Config deaktiviert" "INFO"
        return
    }
    
    Write-Host "`n"
    Write-Host "============================================" -ForegroundColor $ColorHeader
    Write-Host "INTEL DRIVER & SUPPORT ASSISTANT" -ForegroundColor $ColorHeader
    Write-Host "============================================`n" -ForegroundColor $ColorHeader
    
    Write-Log "Pruefe Intel-Treiber..." "INFO"
    
    try {
        # Prüfe ob DSA bereits läuft
        $dsaRunning = Get-Process | Where-Object { $_.ProcessName -like "*DSA*" }
        
        if ($dsaRunning) {
            Write-Host "Intel DSA laeuft bereits (Tray-Icon pruefen).`n" -ForegroundColor $ColorSuccess
            Write-Log "Intel DSA bereits aktiv" "SUCCESS"
            return
        }
        
        # Pfade aus Config oder Standard
        $intelDSAPaths = @(
            "C:\Program Files (x86)\Intel\Driver and Support Assistant\DSATray.exe",
            "C:\Program Files (x86)\Intel\Driver and Support Assistant\x86\DSATray.exe",
            "C:\Program Files\Intel\Driver and Support Assistant\DSATray.exe"
        )
        
        if ($Global:Config -and $Global:Config.hardwareVendors.intel.dsaPath) {
            $intelDSAPaths = @($Global:Config.hardwareVendors.intel.dsaPath) + $Global:Config.hardwareVendors.intel.alternativePaths
        }
        
        foreach ($path in $intelDSAPaths) {
            if (Test-Path $path) {
                Write-Host "Starte Intel DSA..." -ForegroundColor $ColorInfo
                Start-Process $path -ErrorAction SilentlyContinue
                Write-Host "Intel DSA gestartet (Tray-Icon pruefen).`n" -ForegroundColor $ColorSuccess
                Write-Log "Intel DSA gestartet: $path" "SUCCESS"
                return
            }
        }
        
        Write-Host "Intel DSA nicht gefunden.`n" -ForegroundColor $ColorWarning
        Write-Host "Hinweis: CPU-Treiber werden meist via Windows Update aktualisiert." -ForegroundColor $ColorInfo
        Write-Host "Download: https://www.intel.com/content/www/us/en/support/detect.html`n" -ForegroundColor $ColorInfo
        Write-Log "Intel DSA nicht gefunden" "WARNING"
        
    } catch {
        Write-Log "Fehler bei Intel-Update: $($_.Exception.Message)" "ERROR"
        Write-Host "FEHLER: $($_.Exception.Message)`n" -ForegroundColor $ColorError
    }
}

function Update-MSI {
    param($Hardware)

    if (-not $Hardware.HasMSI) {
        Write-Log "Kein MSI-Mainboard erkannt. Ueberspringe..." "INFO"
        return
    }

    # Config enabled-Check
    if ($Global:Config -and -not $Global:Config.hardwareVendors.msi.enabled) {
        Write-Log "MSI-Updates sind in der Config deaktiviert" "INFO"
        return
    }
    
    Write-Host "`n"
    Write-Host "============================================" -ForegroundColor $ColorHeader
    Write-Host "MSI CENTER / LIVE UPDATE" -ForegroundColor $ColorHeader
    Write-Host "============================================`n" -ForegroundColor $ColorHeader
    
    Write-Log "Pruefe MSI-Software..." "INFO"
    
    try {
        Write-Host "Oeffne MSI Center..." -ForegroundColor $ColorInfo
        
        # MSI Center ist eine Windows Store App
        $app = Get-AppxPackage | Where-Object { $_.PackageFamilyName -like "*MSICenter*" }
        
        if ($app) {
            Start-Process "shell:AppsFolder\$($app.PackageFamilyName)!App"
            Write-Host "MSI Center geoeffnet!" -ForegroundColor $ColorSuccess
            Write-Host "Updates unter 'Support' > 'Live Update' pruefen.`n" -ForegroundColor $ColorInfo
            Write-Log "MSI Center geoeffnet" "SUCCESS"
        } else {
            Write-Host "MSI Center nicht gefunden.`n" -ForegroundColor $ColorWarning
            Write-Host "Download: https://www.msi.com/Landing/msi-center`n" -ForegroundColor $ColorInfo
            Write-Log "MSI Center nicht gefunden" "WARNING"
        }
        
    } catch {
        Write-Log "Fehler bei MSI-Update: $($_.Exception.Message)" "ERROR"
        Write-Host "FEHLER: $($_.Exception.Message)`n" -ForegroundColor $ColorError
    }
}

# ============================================
# HAUPTMENÜ
# ============================================

function Show-Menu {
    Clear-Host
    Write-Host "`n"
    Write-Host "============================================" -ForegroundColor $ColorHeader
    Write-Host "UNIVERSAL UPDATE MANAGER v$ScriptVersion" -ForegroundColor $ColorHeader
    Write-Host "============================================`n" -ForegroundColor $ColorHeader
    
    Write-Host "1. Alle Updates (Vollstaendig)" -ForegroundColor $ColorInfo
    Write-Host "2. Winget Updates" -ForegroundColor $ColorInfo
    Write-Host "3. Chocolatey Updates" -ForegroundColor $ColorInfo
    Write-Host "4. Windows Update" -ForegroundColor $ColorInfo
    Write-Host "5. Microsoft Store Apps" -ForegroundColor $ColorInfo
    Write-Host "6. Hersteller-Updates (NVIDIA/Intel/MSI)" -ForegroundColor $ColorInfo
    Write-Host "7. System-Info anzeigen" -ForegroundColor $ColorInfo
    Write-Host "8. Log-Datei oeffnen" -ForegroundColor $ColorInfo
    Write-Host "0. Beenden`n" -ForegroundColor $ColorWarning
}

# ============================================
# SYSTEM-INFO ANZEIGE
# ============================================

function Show-SystemInfo {
    Clear-Host
    Write-Host "`n"
    Write-Host "============================================" -ForegroundColor $ColorHeader
    Write-Host "SYSTEM-INFORMATIONEN" -ForegroundColor $ColorHeader
    Write-Host "============================================`n" -ForegroundColor $ColorHeader
    
    $hardware = Get-HardwareInfo
    
    Write-Host "Hardware:" -ForegroundColor $ColorInfo
    Write-Host "  CPU: $($hardware.CPU)" -ForegroundColor White
    Write-Host "  GPU: $($hardware.GPU)" -ForegroundColor White
    Write-Host "  Mainboard: $($hardware.Mainboard)`n" -ForegroundColor White
    
    Write-Host "Verfuegbare Update-Quellen:" -ForegroundColor $ColorInfo
    Write-Host "  Winget: $(if (Test-WingetAvailable) { 'Verfuegbar' } else { 'Nicht gefunden' })" -ForegroundColor $(if (Test-WingetAvailable) { $ColorSuccess } else { $ColorError })
    Write-Host "  Chocolatey: $(if (Test-ChocoAvailable) { 'Verfuegbar' } else { 'Nicht gefunden' })" -ForegroundColor $(if (Test-ChocoAvailable) { $ColorSuccess } else { $ColorError })
    Write-Host "  PSWindowsUpdate: $(if (Test-PSWindowsUpdateModule) { 'Verfuegbar' } else { 'Nicht gefunden' })" -ForegroundColor $(if (Test-PSWindowsUpdateModule) { $ColorSuccess } else { $ColorError })
    Write-Host "  Internet: $(if (Test-InternetConnection) { 'Verbunden' } else { 'Offline' })`n" -ForegroundColor $(if (Test-InternetConnection) { $ColorSuccess } else { $ColorError })
    
    Write-Host "Konfiguration:" -ForegroundColor $ColorInfo
    if ($Global:Config) {
        Write-Host "  Config-Datei: Geladen" -ForegroundColor $ColorSuccess
        Write-Host "  Winget: $(if ($Global:Config.updateSources.winget.enabled) { 'Aktiviert' } else { 'Deaktiviert' })" -ForegroundColor White
        Write-Host "  Chocolatey: $(if ($Global:Config.updateSources.chocolatey.enabled) { 'Aktiviert' } else { 'Deaktiviert' })" -ForegroundColor White
        Write-Host "  Windows Update: $(if ($Global:Config.updateSources.windowsUpdate.enabled) { 'Aktiviert' } else { 'Deaktiviert' })" -ForegroundColor White
        Write-Host "  Microsoft Store: $(if ($Global:Config.updateSources.microsoftStore.enabled) { 'Aktiviert' } else { 'Deaktiviert' })`n" -ForegroundColor White
    } else {
        Write-Host "  Config-Datei: Nicht geladen (Standard-Einstellungen)" -ForegroundColor $ColorWarning
    }
    
    Read-Host "`nDruecke Enter zum Fortfahren"
}

# ============================================
# HAUPTPROGRAMM
# ============================================

function Main {
    # Log-Datei initialisieren
    Write-Log "========================================" "INFO"
    Write-Log "Universal Update Manager v$ScriptVersion gestartet" "INFO"
    Write-Log "========================================" "INFO"
    
    # Konfiguration laden
    $Global:Config = Load-Config
    
    # Voraussetzungen prüfen
    Test-Prerequisites | Out-Null
    
    # Hardware erkennen
    $hardware = Get-HardwareInfo
    
    # Hauptschleife
    do {
        Show-Menu
        $choice = Read-Host "Auswahl"
        
        switch ($choice) {
            "1" {
                $startTime = Get-Date
                Write-Log "Starte vollstaendiges Update..." "INFO"
                Update-Winget
                Update-Chocolatey
                Update-Windows
                Update-MicrosoftStore
                Update-NVIDIA -Hardware $hardware
                Update-Intel -Hardware $hardware
                Update-MSI -Hardware $hardware
                $duration = (Get-Date) - $startTime

                # Zusammenfassung
                Write-Host "`n============================================" -ForegroundColor $ColorHeader
                Write-Host "ZUSAMMENFASSUNG" -ForegroundColor $ColorHeader
                Write-Host "============================================" -ForegroundColor $ColorHeader
                Write-Host "Dauer: $([math]::Round($duration.TotalMinutes, 1)) Minuten" -ForegroundColor White
                Write-Host "Geprueft: Winget, Chocolatey, Windows Update, Store" -ForegroundColor White
                if ($hardware.HasNVIDIA) { Write-Host "GPU: NVIDIA App geoeffnet" -ForegroundColor $ColorSuccess }
                if ($hardware.HasIntel) { Write-Host "CPU: Intel DSA geprueft" -ForegroundColor $ColorSuccess }
                if ($hardware.HasMSI) { Write-Host "Mainboard: MSI Center geoeffnet" -ForegroundColor $ColorSuccess }
                Write-Host "Log: $LogFile" -ForegroundColor $ColorInfo
                Write-Host "============================================`n" -ForegroundColor $ColorHeader

                Write-Log "Vollstaendiges Update abgeschlossen!" "SUCCESS"
                Read-Host "Druecke Enter zum Fortfahren"
            }
            "2" {
                Update-Winget
                Read-Host "`nDruecke Enter zum Fortfahren"
            }
            "3" {
                Update-Chocolatey
                Read-Host "`nDruecke Enter zum Fortfahren"
            }
            "4" {
                Update-Windows
                Read-Host "`nDruecke Enter zum Fortfahren"
            }
            "5" {
                Update-MicrosoftStore
                Read-Host "`nDruecke Enter zum Fortfahren"
            }
            "6" {
                Update-NVIDIA -Hardware $hardware
                Update-Intel -Hardware $hardware
                Update-MSI -Hardware $hardware
                Read-Host "`nDruecke Enter zum Fortfahren"
            }
            "7" {
                Show-SystemInfo
            }
            "8" {
                if (Test-Path $LogFile) {
                    notepad $LogFile
                } else {
                    Write-Log "Log-Datei nicht gefunden: $LogFile" "ERROR"
                    Write-Host "Log-Datei nicht gefunden!`n" -ForegroundColor $ColorError
                    Read-Host "Druecke Enter zum Fortfahren"
                }
            }
            "0" {
                Write-Log "Update Manager beendet." "INFO"
                Write-Host "`nAuf Wiedersehen!`n" -ForegroundColor $ColorSuccess
                exit
            }
            default {
                Write-Host "`nUngueltige Auswahl!`n" -ForegroundColor $ColorError
                Start-Sleep -Seconds 1
            }
        }
        
    } while ($true)
}

# ============================================
# SCRIPT STARTEN
# ============================================

try {
    Main
} catch {
    Write-Log "KRITISCHER FEHLER: $($_.Exception.Message)" "ERROR"
    Write-Host "`nKRITISCHER FEHLER: $($_.Exception.Message)`n" -ForegroundColor $ColorError
    Read-Host "Enter zum Beenden"
    exit 1
}
