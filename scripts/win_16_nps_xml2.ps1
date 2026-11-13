$ErrorActionPreference = "Continue"
Write-Output "== ARCHIVO =="
Get-Item "C:\Windows\Temp\nps_backup.xml" | Select-Object Length, LastWriteTime | Format-List
Write-Output "== PRIMEROS 1200 CARACTERES =="
$xml = Get-Content "C:\Windows\Temp\nps_backup.xml" -Raw
Write-Output $xml.Substring(0, [Math]::Min(1200, $xml.Length))
Write-Output "== ETIQUETAS DISTINTAS =="
[regex]::Matches($xml, "<([A-Za-z0-9_]+)") | ForEach-Object {$_.Groups[1].Value} | Sort-Object -Unique | Select-Object -First 40
Write-Output "== BUSCAR AuthType =="
[regex]::Matches($xml, ".{0,80}(?i)authtype.{0,120}") | ForEach-Object {$_.Value} | Select-Object -First 10
