@echo off
title Chrome CDP Port 9222 Launcher
echo [1/2] Checking if Chrome is already running on port 9222...
netstat -ano | findstr :9222 >nul
if %errorlevel% equ 0 (
    echo [*] Chrome is ALREADY running on port 9222!
    exit /b 0
)

echo [2/2] Launching Chrome Profile 8 on remote debugging port 9222...
start "" "C:\Program Files\Google\Chrome\Application\chrome.exe" --remote-debugging-port=9222 --user-data-dir="C:\Users\DELL\AppData\Local\ChromeDebugProfile" --profile-directory="Profile 8" --no-first-run --no-default-browser-check

timeout /t 2 >nul
echo [+] Chrome started successfully on port 9222!
