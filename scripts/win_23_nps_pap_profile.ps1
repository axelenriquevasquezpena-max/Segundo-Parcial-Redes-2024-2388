$ErrorActionPreference = "Stop"
$x = "C:\Windows\Temp\nps_export.xml"
$y = "C:\Windows\Temp\nps_pap.xml"
[xml]$doc = Get-Content $x -Raw

$props = $doc.SelectSingleNode("//RadiusProfiles/Children/Connections_to_other_access_servers/Properties")
if (-not $props) { throw "no se encontro el perfil de la politica" }
$actuales = @($props.msNPAuthenticationType2 | ForEach-Object { [int]$_.InnerText })
Write-Output ("tipos actuales del perfil: " + ($actuales -join ","))

if ($actuales -notcontains 1) {
  $el = $doc.CreateElement("msNPAuthenticationType2")
  $el.SetAttribute("dt", "urn:schemas-microsoft-com:datatypes", "int")
  $el.InnerText = "1"
  $props.AppendChild($el) | Out-Null
  Write-Output "PAP (1) agregado al perfil"
}
$nuevos = @($props.msNPAuthenticationType2 | ForEach-Object { [int]$_.InnerText })
Write-Output ("tipos nuevos del perfil: " + ($nuevos -join ","))
$doc.Save($y)

Write-Output "== IMPORTAR =="
netsh nps import filename="$y"
Write-Output ("exit code: " + $LASTEXITCODE)
Start-Sleep 4
Write-Output "== POLITICA =="
netsh nps show np | Select-String -Pattern "NP-Authentication-Type"

Write-Output "== REINICIO NPS =="
Restart-Service IAS -Force
Start-Sleep 6
Get-Service IAS | Select-Object Name, Status | Format-Table -AutoSize
