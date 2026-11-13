$ErrorActionPreference = "Continue"
Write-Output "== ULTIMO EVENTO NPS 13 (completo) =="
$e = Get-WinEvent -LogName System -MaxEvents 200 -ErrorAction SilentlyContinue | Where-Object {$_.ProviderName -eq "NPS" -and $_.Id -eq 13} | Select-Object -First 1
if ($e) { Write-Output $e.TimeCreated; Write-Output $e.Message }
Write-Output "== CLIENTES RADIUS EN NPS =="
Get-NpsRadiusClient | Format-List Name, Address, Enabled, VendorName
Write-Output "== REINICIO DEL SERVICIO NPS =="
Restart-Service IAS -Force
Start-Sleep 6
Get-Service IAS | Select-Object Name, Status | Format-Table -AutoSize
Get-NetUDPEndpoint -LocalPort 1812 -ErrorAction SilentlyContinue | Select-Object LocalAddress, LocalPort | Format-Table -AutoSize
