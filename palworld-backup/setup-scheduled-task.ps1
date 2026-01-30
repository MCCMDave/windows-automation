# ============================================
# SETUP: Palworld Backup als Scheduled Task
# ============================================
# Erstellt einen Windows Task der alle 15 Minuten das Backup ausfuehrt.
# ============================================

$TaskName = "PalworldBackup"
$ScriptPath = "$PSScriptRoot\palworld-backup.ps1"

# Pruefen ob Task bereits existiert
$existingTask = Get-ScheduledTask -TaskName $TaskName -ErrorAction SilentlyContinue

if ($existingTask) {
    Write-Host "Task '$TaskName' existiert bereits. Loesche und erstelle neu..." -ForegroundColor Yellow
    Unregister-ScheduledTask -TaskName $TaskName -Confirm:$false
}

# Aktion: PowerShell Script ausfuehren (versteckt, ohne Fenster)
$action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass -File `"$ScriptPath`""

# Trigger: Alle 15 Minuten, unbegrenzt
$trigger = New-ScheduledTaskTrigger -Once -At (Get-Date) -RepetitionInterval (New-TimeSpan -Minutes 15)

# Einstellungen
$settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable -RunOnlyIfNetworkAvailable

# Task erstellen
Register-ScheduledTask -TaskName $TaskName -Action $action -Trigger $trigger -Settings $settings -Description "Palworld Save Backup alle 15 Minuten" -User $env:USERNAME

Write-Host ""
Write-Host "Task '$TaskName' wurde erstellt!" -ForegroundColor Green
Write-Host ""
Write-Host "Details:" -ForegroundColor Cyan
Write-Host "  - Intervall: Alle 15 Minuten"
Write-Host "  - Script: $ScriptPath"
Write-Host "  - Backups: D:\Backups\Palworld\"
Write-Host "  - Log: D:\Backups\Palworld\backup.log"
Write-Host ""
Write-Host "Task verwalten:" -ForegroundColor Cyan
Write-Host "  - Starten: Start-ScheduledTask -TaskName '$TaskName'"
Write-Host "  - Stoppen: Stop-ScheduledTask -TaskName '$TaskName'"
Write-Host "  - Loeschen: Unregister-ScheduledTask -TaskName '$TaskName'"
Write-Host ""
