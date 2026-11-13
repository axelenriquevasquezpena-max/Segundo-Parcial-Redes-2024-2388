$ErrorActionPreference = "Continue"
Write-Output "== FECHA Y HORA DEL SERVIDOR =="
Get-Date -Format "yyyy-MM-dd HH:mm:ss K"
(Get-TimeZone).DisplayName
Write-Output ""
Write-Output "== DOMINIO =="
Get-ADDomain | Select-Object DNSRoot, NetBIOSName, DistinguishedName, DomainMode | Format-List
Get-ADForest | Select-Object Name, ForestMode, GlobalCatalogs | Format-List
Write-Output "== CONTROLADOR =="
Get-ADDomainController | Select-Object Name, IPv4Address, OperatingSystem, IsGlobalCatalog, Enabled | Format-Table -AutoSize
Write-Output ""
Write-Output "== UNIDADES ORGANIZATIVAS =="
Get-ADOrganizationalUnit -Filter * | Select-Object -ExpandProperty DistinguishedName
Write-Output ""
Write-Output "== USUARIOS =="
Get-ADUser -Filter * -SearchBase "OU=Usuarios,OU=Laboratorio,DC=parcial,DC=local" -Properties msNPAllowDialin, Title, Enabled |
  Select-Object SamAccountName, Name, Title, Enabled, msNPAllowDialin | Format-Table -AutoSize
Write-Output "== GRUPOS Y MIEMBROS =="
foreach ($g in @("GRP-Administradores-TI","GRP-Usuarios-RADIUS")) {
  Write-Output ($g + ": " + ((Get-ADGroupMember -Identity $g | Select-Object -ExpandProperty SamAccountName) -join ", "))
}
Write-Output ""
Write-Output "== DNS =="
Get-DnsServerZone | Where-Object {$_.ZoneName -like "*parcial.local*"} | Select-Object ZoneName, ZoneType, IsDsIntegrated | Format-Table -AutoSize
Resolve-DnsName dc01.parcial.local -Type A | Select-Object Name, IPAddress | Format-Table -AutoSize
Write-Output ""
Write-Output "== NPS =="
Get-Service IAS | Select-Object Name, Status, StartType | Format-Table -AutoSize
Get-NpsRadiusClient | Select-Object Name, Address, Enabled | Format-Table -AutoSize
Write-Output "== POLITICA DE RED (tipos de autenticacion) =="
netsh nps show np | Select-String -Pattern "Name             =|NP-Authentication-Type"
Write-Output "== ESCUCHA RADIUS =="
Get-NetUDPEndpoint -LocalPort 1812,1813 -ErrorAction SilentlyContinue | Select-Object LocalAddress, LocalPort | Format-Table -AutoSize
Write-Output "== REGLA DE FIREWALL (solo laboratorio) =="
$r = Get-NetFirewallRule -DisplayName "RADIUS Laboratorio UDP"
$r | Select-Object DisplayName, Enabled, Direction, Action, Profile | Format-Table -AutoSize
$r | Get-NetFirewallPortFilter | Select-Object Protocol, LocalPort | Format-Table -AutoSize
$r | Get-NetFirewallAddressFilter | Select-Object RemoteAddress | Format-Table -AutoSize
Write-Output "== PERFILES DE FIREWALL =="
Get-NetFirewallProfile | Select-Object Name, Enabled | Format-Table -AutoSize
