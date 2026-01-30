# ============================================
# PALWORLD SAVE BACKUP SCRIPT
# ============================================
# Laedt Palworld Saves per FTP herunter und speichert sie lokal
# Ausfuehrung: Alle 15 Minuten per Windows Aufgabenplanung
#
# Autor: Dave
# Version: 1.0
# Datum: 30.01.2026
# ============================================

# KONFIGURATION
$FtpHost = "168.119.90.246"
$FtpUser = "c4i9sMyEpmD4"
$FtpPass = "wGCei5M0Qtn9"
$RemotePath = "/server-data/Pal/Saved/SaveGames/0/3296F42FB4FA43CB907E75BC5E9528BD"
$LocalBackupDir = "$env:USERPROFILE\Backups\Palworld"
$MaxBackupAgeDays = 7  # Backups aelter als 7 Tage loeschen

# Zeitstempel fuer dieses Backup
$Timestamp = Get-Date -Format "yyyy-MM-dd_HH-mm"
$BackupFolder = "$LocalBackupDir\$Timestamp"

# Logging
$LogFile = "$LocalBackupDir\backup.log"

function Write-Log {
    param([string]$Message, [string]$Level = "INFO")
    $LogEntry = "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')] [$Level] $Message"
    Add-Content -Path $LogFile -Value $LogEntry -ErrorAction SilentlyContinue
    if ($Level -eq "ERROR") {
        Write-Host $Message -ForegroundColor Red
    } else {
        Write-Host $Message
    }
}

function Download-FtpFile {
    param(
        [string]$RemoteFile,
        [string]$LocalFile
    )

    try {
        $ftpUri = "ftp://$FtpHost$RemoteFile"
        $request = [System.Net.FtpWebRequest]::Create($ftpUri)
        $request.Method = [System.Net.WebRequestMethods+Ftp]::DownloadFile
        $request.Credentials = New-Object System.Net.NetworkCredential($FtpUser, $FtpPass)
        $request.UseBinary = $true
        $request.UsePassive = $true

        $response = $request.GetResponse()
        $stream = $response.GetResponseStream()

        # Lokalen Ordner erstellen falls noetig
        $localDir = Split-Path $LocalFile -Parent
        if (-not (Test-Path $localDir)) {
            New-Item -ItemType Directory -Path $localDir -Force | Out-Null
        }

        $fileStream = [System.IO.File]::Create($LocalFile)
        $buffer = New-Object byte[] 8192

        do {
            $bytesRead = $stream.Read($buffer, 0, $buffer.Length)
            $fileStream.Write($buffer, 0, $bytesRead)
        } while ($bytesRead -gt 0)

        $fileStream.Close()
        $stream.Close()
        $response.Close()

        return $true
    }
    catch {
        Write-Log "Fehler beim Download von $RemoteFile : $($_.Exception.Message)" "ERROR"
        return $false
    }
}

function Get-FtpDirectoryListing {
    param([string]$RemoteDir)

    try {
        $ftpUri = "ftp://$FtpHost$RemoteDir"
        $request = [System.Net.FtpWebRequest]::Create($ftpUri)
        $request.Method = [System.Net.WebRequestMethods+Ftp]::ListDirectory
        $request.Credentials = New-Object System.Net.NetworkCredential($FtpUser, $FtpPass)
        $request.UsePassive = $true

        $response = $request.GetResponse()
        $reader = New-Object System.IO.StreamReader($response.GetResponseStream())
        $listing = $reader.ReadToEnd()
        $reader.Close()
        $response.Close()

        return $listing -split "`n" | Where-Object { $_.Trim() -ne "" }
    }
    catch {
        Write-Log "Fehler beim Auflisten von $RemoteDir : $($_.Exception.Message)" "ERROR"
        return @()
    }
}

# ============================================
# HAUPTPROGRAMM
# ============================================

Write-Log "=== Palworld Backup gestartet ===" "INFO"

# Backup-Verzeichnis erstellen
if (-not (Test-Path $LocalBackupDir)) {
    New-Item -ItemType Directory -Path $LocalBackupDir -Force | Out-Null
    Write-Log "Backup-Verzeichnis erstellt: $LocalBackupDir"
}

if (-not (Test-Path $BackupFolder)) {
    New-Item -ItemType Directory -Path $BackupFolder -Force | Out-Null
}

# World Saves herunterladen
Write-Log "Lade Level.sav..."
$levelOk = Download-FtpFile -RemoteFile "$RemotePath/Level.sav" -LocalFile "$BackupFolder\Level.sav"

Write-Log "Lade LevelMeta.sav..."
$metaOk = Download-FtpFile -RemoteFile "$RemotePath/LevelMeta.sav" -LocalFile "$BackupFolder\LevelMeta.sav"

# Player Saves herunterladen
Write-Log "Lade Player Saves..."
$players = Get-FtpDirectoryListing -RemoteDir "$RemotePath/Players/"
$playerCount = 0

foreach ($player in $players) {
    $playerFile = $player.Trim()
    if ($playerFile -match "\.sav$") {
        $downloaded = Download-FtpFile -RemoteFile "$RemotePath/Players/$playerFile" -LocalFile "$BackupFolder\Players\$playerFile"
        if ($downloaded) { $playerCount++ }
    }
}

# Zusammenfassung
if ($levelOk -and $metaOk) {
    $backupSize = (Get-ChildItem $BackupFolder -Recurse | Measure-Object -Property Length -Sum).Sum / 1MB
    Write-Log "Backup erfolgreich: $BackupFolder ($([math]::Round($backupSize, 2)) MB, $playerCount Spieler)" "INFO"
} else {
    Write-Log "Backup unvollstaendig!" "ERROR"
}

# Alte Backups aufraeumen
Write-Log "Raeume alte Backups auf..."
$cutoffDate = (Get-Date).AddDays(-$MaxBackupAgeDays)
$oldBackups = Get-ChildItem $LocalBackupDir -Directory | Where-Object {
    $_.Name -match "^\d{4}-\d{2}-\d{2}_\d{2}-\d{2}$" -and $_.CreationTime -lt $cutoffDate
}

foreach ($old in $oldBackups) {
    Remove-Item $old.FullName -Recurse -Force
    Write-Log "Geloescht: $($old.Name)"
}

Write-Log "=== Backup abgeschlossen ===" "INFO"
Write-Log "" "INFO"
