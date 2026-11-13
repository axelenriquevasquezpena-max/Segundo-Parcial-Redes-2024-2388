$ErrorActionPreference = "Continue"
Write-Output "== EVENTOS NPS (Security 6272-6278) =="
Get-WinEvent -FilterHashtable @{LogName="Security"; Id=6272,6273,6274,6275,6276,6277,6278} -MaxEvents 8 -ErrorAction SilentlyContinue |
  ForEach-Object {
    $m = $_.Message -split "`n" | Where-Object {$_ -match "Reason|User:|Client|Policy|Authentication|Nombre|Usuario"} | Select-Object -First 6
    Write-Output ("---- " + $_.TimeCreated + " ID=" + $_.Id)
    $m | ForEach-Object { Write-Output ("   " + $_.Trim()) }
  }
Write-Output "== EVENTOS SISTEMA IAS =="
Get-WinEvent -LogName System -MaxEvents 40 -ErrorAction SilentlyContinue |
  Where-Object {$_.ProviderName -match "IAS|RemoteAccess|NPS"} |
  Select-Object TimeCreated, Id, ProviderName, @{n="Msg";e={($_.Message -split "`n")[0]}} | Format-Table -AutoSize
Write-Output "== CONTADOR DE PAQUETES UDP =="
Get-NetUDPEndpoint -LocalPort 1812 -ErrorAction SilentlyContinue | Select-Object LocalAddress, LocalPort
