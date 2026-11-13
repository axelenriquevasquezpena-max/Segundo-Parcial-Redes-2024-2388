$ErrorActionPreference = "Continue"
Write-Output "== POLITICAS ACTUALES =="
netsh nps show np | Select-Object -First 45
Write-Output "== CLIENTES =="
Get-NpsRadiusClient | Select-Object Name, Address, Enabled | Format-Table -AutoSize
Write-Output "== SERVICIO =="
Get-Service IAS | Select-Object Name, Status | Format-Table -AutoSize
Write-Output "== XML IMPORTADO: propiedad de la politica =="
if (Test-Path "C:\Windows\Temp\nps_import.xml") {
  [xml]$d = Get-Content "C:\Windows\Temp\nps_import.xml" -Raw
  $p = $d.SelectSingleNode("//NetworkPolicy/Children/Connections_to_other_access_servers/Properties")
  $p.ChildNodes | ForEach-Object { Write-Output ($_.Name + " = " + $_.InnerText) }
}
