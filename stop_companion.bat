@echo off
taskkill /F /FI "WINDOWTITLE eq Yorky Companion*" 2>nul
powershell -Command "Get-Process python, pythonw | Where-Object { $_.CommandLine -like '*yorky_pet*' } | Stop-Process -Force" 2>nul
echo Yorky Companion closed.
exit
