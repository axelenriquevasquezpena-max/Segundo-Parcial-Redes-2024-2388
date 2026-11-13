$ErrorActionPreference = "Continue"
Write-Output "== CARPETA IAS =="
Get-ChildItem "C:\Windows\System32\ias" -Force -ErrorAction SilentlyContinue | Select-Object Name, Length, LastWriteTime | Format-Table -AutoSize
Write-Output "== EXPORT CON NETSH =="
netsh nps export filename="C:\Windows\Temp\nps_export.xml" exportPSK=YES
Start-Sleep 2
Get-Item "C:\Windows\Temp\nps_export.xml" -ErrorAction SilentlyContinue | Select-Object Length, LastWriteTime | Format-List
Write-Output "== PRIMEROS 800 =="
if (Test-Path "C:\Windows\Temp\nps_export.xml") {
  $x = Get-Content "C:\Windows\Temp\nps_export.xml" -Raw
  Write-Output $x.Substring(0, [Math]::Min(800, $x.Length))
  Write-Output "== COINCIDENCIAS DE POLITICA =="
  [regex]::Matches($x, ".{0,60}msAuthType.{0,100}") | ForEach-Object {$_.Value} | Select-Object -First 8
}
