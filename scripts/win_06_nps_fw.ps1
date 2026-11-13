$ErrorActionPreference = "Continue"
Write-Output "== CLIENTE DE PRUEBAS KALI =="
Remove-NpsRadiusClient -Name "KALI-TEST" -ErrorAction SilentlyContinue
New-NpsRadiusClient -Name "KALI-TEST" -Address "192.168.16.52" -SharedSecret "{{RADIUS_SECRET}}" | Out-Null
Get-NpsRadiusClient | Select-Object Name, Address, Enabled | Format-Table -AutoSize

Write-Output "== FIREWALL UDP 1812/1813 =="
Get-NetFirewallRule -DisplayName "RADIUS*" -ErrorAction SilentlyContinue | Select-Object DisplayName, Enabled, Direction, Action | Format-Table -AutoSize
if (-not (Get-NetFirewallRule -DisplayName "RADIUS Laboratorio" -ErrorAction SilentlyContinue)) {
  New-NetFirewallRule -DisplayName "RADIUS Laboratorio" -Direction Inbound -Protocol UDP -LocalPort 1812,1813 -Action Allow -Profile Any | Out-Null
}
Get-NetFirewallRule -DisplayName "RADIUS Laboratorio" | Select-Object DisplayName, Enabled, Direction, Action | Format-Table -AutoSize
Write-Output "== PERFILES DE FIREWALL =="
Get-NetFirewallProfile | Select-Object Name, Enabled | Format-Table -AutoSize
Write-Output "== SERVICIO =="
Get-Service IAS | Select-Object Name, Status | Format-Table -AutoSize
