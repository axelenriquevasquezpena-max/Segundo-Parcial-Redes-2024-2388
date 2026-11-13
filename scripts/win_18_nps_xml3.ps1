$ErrorActionPreference = "Continue"
$x = Get-Content "C:\Windows\Temp\nps_export.xml" -Raw
Write-Output "== ELEMENTOS CON 'Auth' =="
[regex]::Matches($x, "<([A-Za-z0-9_]*[Aa]uth[A-Za-z0-9_]*)[ >]") | ForEach-Object {$_.Groups[1].Value} | Sort-Object -Unique
Write-Output "== BLOQUE DE LA POLITICA =="
$pos = $x.IndexOf("Connections_to_other_access_servers", 600)
if ($pos -lt 0) { $pos = $x.LastIndexOf("Connections_to_other_access_servers") }
Write-Output ("posicion " + $pos)
Write-Output $x.Substring([Math]::Max(0,$pos-200), [Math]::Min(2600, $x.Length - [Math]::Max(0,$pos-200)))
