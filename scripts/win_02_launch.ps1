schtasks /create /tn "LabPromote" /tr "powershell -NoProfile -ExecutionPolicy Bypass -File C:\Windows\Temp\win_02_promote.ps1" /sc once /st 23:59 /ru SYSTEM /rl HIGHEST /f
schtasks /run /tn "LabPromote"
Write-Output "tarea lanzada"
