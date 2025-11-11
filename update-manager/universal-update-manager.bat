@echo off
REM ============================================
REM Universal Update Manager v2.1 - Starter
REM ============================================
REM Autor: Dave
REM Datum: 02.11.2025
REM Version: 2.1
REM Projekt: Homelab & System-Verwaltung
REM ============================================

title Universal Update Manager v2.1

REM Pruefe Admin-Rechte
net session >nul 2>&1
if %errorLevel% == 0 (
    REM Hat bereits Admin-Rechte
    goto :RunScript
) else (
    REM Fordere Admin-Rechte an
    echo Fordere Administrator-Rechte an...
    powershell -Command "Start-Process '%~f0' -Verb RunAs"
    exit /b
)

:RunScript
REM Wechsle ins Script-Verzeichnis
cd /d "%~dp0"

REM Starte PowerShell-Script (v2.1)
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0universal-update-manager.ps1"

REM Fenster offen halten falls Fehler
if %errorlevel% neq 0 (
    echo.
    echo Fehler beim Ausfuehren des Scripts!
    echo Bitte Log-Datei pruefen: Desktop\Universal-Update-Manager.log
    pause
)

exit /b
