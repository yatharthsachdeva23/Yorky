' Silent background launcher for Yorky Desktop Companion
Option Explicit
Dim fso, sh, pywPath, scriptPath
Set fso = CreateObject("Scripting.FileSystemObject")
Set sh = CreateObject("WScript.Shell")

pywPath = "C:\Users\DELL\AppData\Local\Programs\Python\Python37\pythonw.exe"
scriptPath = "c:\Desktop\Antigravity Projects\YouTube Manager\companion\yorky_pet.py"

If fso.FileExists(pywPath) And fso.FileExists(scriptPath) Then
    sh.CurrentDirectory = "c:\Desktop\Antigravity Projects\YouTube Manager"
    sh.Run """" & pywPath & """ """ & scriptPath & """", 0, False
End If
