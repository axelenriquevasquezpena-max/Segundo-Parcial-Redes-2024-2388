$ErrorActionPreference = "Continue"
Write-Output "== AYUDA import =="
netsh nps import ? | Select-Object -First 25
