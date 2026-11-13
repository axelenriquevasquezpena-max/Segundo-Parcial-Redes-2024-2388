$ErrorActionPreference = "Continue"
$h = (netsh nps set np ?) -join "`n"
$lines = $h -split "`n"
Write-Output "== SINTAXIS set np =="
$lines | Select-Object -First 60 | ForEach-Object { Write-Output $_.TrimEnd() }
