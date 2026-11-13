$ErrorActionPreference = "Continue"
Write-Output "== IMPORT DEL EXPORT ORIGINAL =="
netsh nps import filename="C:\Windows\Temp\nps_export.xml"
Write-Output ("exit code: " + $LASTEXITCODE)
Start-Sleep 3
Write-Output "== POLITICA =="
netsh nps show np | Select-String -Pattern "NP-Authentication-Type"
