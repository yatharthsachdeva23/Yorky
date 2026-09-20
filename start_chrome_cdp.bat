@echo off
setlocal enabledelayedexpansion
title Chrome CDP Port 9222 Launcher

echo ========================================================
echo   Chrome CDP Remote Debugging Launcher (Port 9222)
echo ========================================================

:: 1. Rapidly check if Chrome CDP is already actively listening
C:\Windows\System32\curl.exe -s --connect-timeout 1 http://127.0.0.1:9222/json/version >nul 2>&1
if %errorlevel% equ 0 (
    echo [*] Chrome CDP is ALREADY running and responding on port 9222!
    echo [*] Bringing up YouTube Studio...
    powershell -NoProfile -ExecutionPolicy Bypass -Command "Start-Process 'C:\Program Files\Google\Chrome\Application\chrome.exe' -ArgumentList 'https://studio.youtube.com'" >nul 2>&1
    echo [+] YouTube Studio ready: https://studio.youtube.com
    ping 127.0.0.1 -n 3 >nul 2>&1
    exit /b 0
)

:: 2. Launch Chrome completely detached via PowerShell Start-Process
:: Properly quote directories with spaces so Chrome does not misinterpret '8' as a URL
echo [*] Launching Chrome Profile 8 on remote debugging port 9222...
powershell -NoProfile -ExecutionPolicy Bypass -Command "Start-Process 'C:\Program Files\Google\Chrome\Application\chrome.exe' -ArgumentList '--remote-debugging-port=9222', '\"--user-data-dir=C:\Users\DELL\AppData\Local\ChromeDebugProfile\"', '\"--profile-directory=Profile 8\"', '--no-first-run', '--no-default-browser-check', 'https://studio.youtube.com'"

:: 3. Poll for port 9222 to become active (up to 6 attempts, 1 second each)
echo [*] Waiting for CDP port 9222 to initialize...
for /L %%i in (1,1,6) do (
    ping 127.0.0.1 -n 2 >nul 2>&1
    C:\Windows\System32\curl.exe -s --connect-timeout 1 http://127.0.0.1:9222/json/version >nul 2>&1
    if !errorlevel! equ 0 (
        echo [+] Chrome CDP port 9222 is ONLINE and READY!
        echo [+] YouTube Studio opened: https://studio.youtube.com
        ping 127.0.0.1 -n 3 >nul 2>&1
        exit /b 0
    )
)

echo [!] Warning: Chrome was launched, but port 9222 did not respond within 6 seconds.
echo [!] Check if another Chrome instance is using the profile.
exit /b 1
