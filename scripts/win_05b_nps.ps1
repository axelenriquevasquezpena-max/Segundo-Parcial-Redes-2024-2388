$ErrorActionPreference = "Continue"
Write-Output "== PARAMETROS New-NpsRadiusClient =="
(Get-Command New-NpsRadiusClient).Parameters.Keys
Write-Output "== INTENTO CON CMDLET =="
Remove-NpsRadiusClient -Name "R1" -ErrorAction SilentlyContinue
Remove-NpsRadiusClient -Name "SW1" -ErrorAction SilentlyContinue
New-NpsRadiusClient -Name "R1" -Address "192.168.16.1" -SharedSecret "{{RADIUS_SECRET}}" -ErrorAction Continue
New-NpsRadiusClient -Name "SW1" -Address "192.168.16.2" -SharedSecret "{{RADIUS_SECRET}}" -ErrorAction Continue
Write-Output "== LISTA =="
Get-NpsRadiusClient | Select-Object Name, Address, Enabled | Format-Table -AutoSize
