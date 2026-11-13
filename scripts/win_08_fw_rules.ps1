$ErrorActionPreference = "Continue"
Write-Output "== REACTIVAR FIREWALL =="
Set-NetFirewallProfile -Profile Domain,Private,Public -Enabled True
Get-NetFirewallProfile | Select-Object Name, Enabled | Format-Table -AutoSize

Write-Output "== REGLA ACOTADA AL LABORATORIO =="
Get-NetFirewallRule -DisplayName "RADIUS Laboratorio*" -ErrorAction SilentlyContinue | Remove-NetFirewallRule -ErrorAction SilentlyContinue
New-NetFirewallRule -DisplayName "RADIUS Laboratorio UDP" -Direction Inbound -Protocol UDP `
  -LocalPort 1812,1813 -RemoteAddress 192.168.16.0/24 -Action Allow -Profile Any `
  -Description "Permite RADIUS/NPS solo desde la red del laboratorio" | Out-Null
$r = Get-NetFirewallRule -DisplayName "RADIUS Laboratorio UDP"
$r | Select-Object DisplayName, Enabled, Direction, Action, Profile | Format-Table -AutoSize
$r | Get-NetFirewallPortFilter | Select-Object Protocol, LocalPort | Format-Table -AutoSize
$r | Get-NetFirewallAddressFilter | Select-Object RemoteAddress | Format-Table -AutoSize

Write-Output "== ESCUCHA NPS =="
Get-NetUDPEndpoint -LocalPort 1812,1813 -ErrorAction SilentlyContinue | Select-Object LocalAddress, LocalPort | Format-Table -AutoSize
Get-Service IAS | Select-Object Name, Status, StartType | Format-Table -AutoSize

Write-Output "== AUDITORIA NPS =="
auditpol /set /subcategory:"Network Policy Server" /success:enable /failure:enable
auditpol /get /subcategory:"Network Policy Server"
