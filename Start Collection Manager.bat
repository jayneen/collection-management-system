
@echo off
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0Start Collection Manager.ps1"

if errorlevel 1 (
    echo.
    echo Collection Manager encountered an error.
    pause
)
