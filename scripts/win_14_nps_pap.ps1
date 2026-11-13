$ErrorActionPreference = "Continue"
Write-Output "== RESPALDO CONFIG NPS =="
Export-NpsConfiguration -Path "C:\Windows\Temp\nps_backup.xml" -Force
Get-Item "C:\Windows\Temp\nps_backup.xml" | Select-Object Length, LastWriteTime | Format-List

Write-Output "== PERMITIR PAP EN LA POLITICA =="
netsh nps set np name="Connections to other access servers" profileid=0x1009 profiledata="0x1" "0x4" "0x5"
Write-Output "== POLITICA RESULTANTE =="
netsh nps show np | Select-String -Pattern "Name|State|NP-Authentication-Type|0x1009"

Write-Output "== REINICIO NPS =="
Restart-Service IAS -Force
Start-Sleep 6
Get-Service IAS | Select-Object Name, Status | Format-Table -AutoSize
