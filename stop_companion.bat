@echo off
"C:\Users\DELL\AppData\Local\Programs\Python\Python37\python.exe" "%~dp0companion\yorky_pet.py" --quit 2>nul
taskkill /F /FI "WINDOWTITLE eq Yorky Companion*" 2>nul
powershell -NoProfile -Command "Get-CimInstance Win32_Process | Where-Object { $_.CommandLine -match 'yorky_pet' } | ForEach-Object { Stop-Process -Id $_.ProcessId -Force }" 2>nul
echo Yorky Companion closed.
exit
