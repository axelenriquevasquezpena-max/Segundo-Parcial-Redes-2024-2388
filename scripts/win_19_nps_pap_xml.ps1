$ErrorActionPreference = "Stop"
$x = "C:\Windows\Temp\nps_export.xml"
$y = "C:\Windows\Temp\nps_import.xml"
[ xml ]$doc = Get-Content $x -Raw

$props = $doc.SelectSingleNode("//NetworkPolicy/Children/Connections_to_other_access_servers/Properties")
if (-not $props) { throw "no se encontro la politica en NetworkPolicy" }
Write-Output "== ACCION DE LA POLITICA =="
Write-Output $props.msNPAction

$tipos = @($props.msNPAuthenticationType2 | ForEach-Object { $_.InnerText })
Write-Output ("tipos actuales: " + ($tipos -join ","))

if ($tipos -notcontains "1") {
  $el = $doc.CreateElement("msNPAuthenticationType2")
  $el.SetAttribute("dt", "urn:schemas-microsoft-com:datatypes", "int")
  $el.InnerText = "1"
  $props.AppendChild($el) | Out-Null
  Write-Output "tipo PAP (1) agregado"
}
$tipos2 = @($props.msNPAuthenticationType2 | ForEach-Object { $_.InnerText })
Write-Output ("tipos nuevos: " + ($tipos2 -join ","))
$doc.Save($y)

Write-Output "== IMPORTAR =="
netsh nps import filename="$y"
Start-Sleep 4
Write-Output "== POLITICA TRAS IMPORTAR =="
netsh nps show np | Select-String -Pattern "Name|NP-Authentication-Type|0x1009"

Write-Output "== REINICIO NPS =="
Restart-Service IAS -Force
Start-Sleep 6
Get-Service IAS | Select-Object Name, Status | Format-Table -AutoSize
