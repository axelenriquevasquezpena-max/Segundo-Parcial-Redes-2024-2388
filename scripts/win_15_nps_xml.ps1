$ErrorActionPreference = "Continue"
Write-Output "== RESTAURAR RESPALDO =="
Import-NpsConfiguration -Path "C:\Windows\Temp\nps_backup.xml" -Force
Start-Sleep 3

Write-Output "== BUSCAR msAuthType EN EL XML =="
$xml = Get-Content "C:\Windows\Temp\nps_backup.xml" -Raw
$idx = $xml.IndexOf("Connections to other access servers")
if ($idx -ge 0) {
  $start = [Math]::Max(0, $idx - 400)
  Write-Output $xml.Substring($start, 2600)
} else {
  Write-Output "no se encontro el nombre de la politica"
}
