Import-Module ActiveDirectory
$ErrorActionPreference = "Continue"
$dominio = (Get-ADDomain).DNSRoot
Write-Output "== DOMINIO =="
Get-ADDomain | Select-Object DNSRoot, NetBIOSName, DistinguishedName | Format-List

Write-Output "== UNIDADES ORGANIZATIVAS =="
$base = "DC=parcial,DC=local"
if (-not (Get-ADOrganizationalUnit -Filter "Name -eq 'Laboratorio'" -SearchBase $base -ErrorAction SilentlyContinue)) {
  New-ADOrganizationalUnit -Name "Laboratorio" -Path $base -ProtectedFromAccidentalDeletion $false | Out-Null
}
foreach ($sub in @("Usuarios","Grupos","Equipos")) {
  if (-not (Get-ADOrganizationalUnit -Filter "Name -eq '$sub'" -SearchBase "OU=Laboratorio,$base" -ErrorAction SilentlyContinue)) {
    New-ADOrganizationalUnit -Name $sub -Path "OU=Laboratorio,$base" -ProtectedFromAccidentalDeletion $false | Out-Null
  }
}
Get-ADOrganizationalUnit -Filter * -SearchBase $base | Select-Object -ExpandProperty DistinguishedName

Write-Output "== GRUPOS =="
foreach ($g in @(
  @{n="GRP-Administradores-TI"; d="Administradores de TI del laboratorio"},
  @{n="GRP-Usuarios-RADIUS";    d="Usuarios autorizados para autenticarse por RADIUS"}
)) {
  if (-not (Get-ADGroup -Filter "Name -eq '$($g.n)'" -ErrorAction SilentlyContinue)) {
    New-ADGroup -Name $g.n -GroupScope Global -GroupCategory Security -Path "OU=Grupos,OU=Laboratorio,$base" -Description $g.d | Out-Null
  }
  Write-Output ("grupo: " + $g.n)
}

Write-Output "== USUARIOS =="
$pw = ConvertTo-SecureString "{{AD_USER_PASS}}" -AsPlainText -Force
$usuarios = @(
  @{s="vasquez"; n="Axel"; a="Vasquez Pena"; g="GRP-Administradores-TI"; t="Administrador de red"},
  @{s="radius1"; n="Usuario"; a="RADIUS Demo"; g="GRP-Usuarios-RADIUS"; t="Cuenta de prueba RADIUS"}
)
foreach ($u in $usuarios) {
  $sam = $u.s
  if (-not (Get-ADUser -Filter "SamAccountName -eq '$sam'" -ErrorAction SilentlyContinue)) {
    New-ADUser -SamAccountName $sam -UserPrincipalName "$sam@$dominio" -Name "$($u.n) $($u.a)" `
      -GivenName $u.n -Surname $u.a -DisplayName "$($u.n) $($u.a)" -Title $u.t `
      -Path "OU=Usuarios,OU=Laboratorio,$base" -AccountPassword $pw -Enabled $true -PasswordNeverExpires $true `
      -ChangePasswordAtLogon $false
  }
  Add-ADGroupMember -Identity $u.g -Members $sam -ErrorAction SilentlyContinue
  Set-ADUser -Identity $sam -Replace @{msNPAllowDialin=$true}
  Write-Output ("usuario: $sam -> grupo " + $u.g + " (dial-in permitido)")
}

Write-Output "== VERIFICACION =="
Get-ADUser -Filter * -SearchBase "OU=Usuarios,OU=Laboratorio,$base" -Properties msNPAllowDialin |
  Select-Object SamAccountName, Name, Enabled, msNPAllowDialin | Format-Table -AutoSize
foreach ($g in @("GRP-Administradores-TI","GRP-Usuarios-RADIUS")) {
  Write-Output ("miembros de " + $g + ": " + ((Get-ADGroupMember -Identity $g | Select-Object -ExpandProperty SamAccountName) -join ", "))
}
Write-Output "== DNS =="
Get-DnsServerZone | Select-Object ZoneName, ZoneType, IsDsIntegrated | Format-Table -AutoSize
Resolve-DnsName dc01.parcial.local -ErrorAction SilentlyContinue | Select-Object Name, IPAddress | Format-Table -AutoSize
