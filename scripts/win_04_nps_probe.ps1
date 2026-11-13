$ErrorActionPreference = "Continue"
Write-Output "== SERVICIO NPS =="
Set-Service -Name IAS -StartupType Automatic
Start-Service -Name IAS
Get-Service IAS | Select-Object Name,Status,StartType | Format-Table -AutoSize
Write-Output "== CMDLETS NPS =="
Get-Command -Module NPAS | Select-Object -ExpandProperty Name
Write-Output "== POLITICAS ACTUALES (np) =="
netsh nps show np
Write-Output "== POLITICAS DE SOLICITUD (crp) =="
netsh nps show crp
