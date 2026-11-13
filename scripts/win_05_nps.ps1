$ErrorActionPreference = "Continue"
Write-Output "== COMANDOS NPS DISPONIBLES =="
Get-Command *Nps* -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Name
Write-Output "== CREAR CLIENTES RADIUS =="
netsh nps delete client name="R1" 2>$null | Out-Null
netsh nps delete client name="SW1" 2>$null | Out-Null
netsh nps add client name="R1" address="192.168.16.1" sharedsecret="{{RADIUS_SECRET}}" description="Router R1 - laboratorio" | Out-Null
netsh nps add client name="SW1" address="192.168.16.2" sharedsecret="{{RADIUS_SECRET}}" description="Switch SW1 - laboratorio" | Out-Null
Write-Output "== CLIENTES CONFIGURADOS =="
netsh nps show client
Write-Output "== SERVICIO Y PUERTOS =="
Get-Service IAS | Select-Object Name,Status,StartType | Format-Table -AutoSize
Get-NetUDPEndpoint -LocalPort 1812,1813 -ErrorAction SilentlyContinue | Select-Object LocalAddress,LocalPort | Format-Table -AutoSize
