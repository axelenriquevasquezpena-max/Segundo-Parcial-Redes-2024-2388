$ErrorActionPreference = "Continue"
Write-Output "== FECHA Y HORA =="
Get-Date -Format "yyyy-MM-dd HH:mm:ss K"
Write-Output "== EQUIPO =="
hostname
(Get-CimInstance Win32_OperatingSystem).Caption
Write-Output "== IP =="
Get-NetIPAddress -AddressFamily IPv4 | Where-Object {$_.IPAddress -like "192.168.*"} | Select-Object IPAddress,PrefixLength,InterfaceAlias | Format-Table -AutoSize
Write-Output "== ROLES INSTALADOS =="
Get-WindowsFeature | Where-Object {$_.Installed -and $_.Name -match "AD-Domain|DNS|NPAS|DHCP"} | Select-Object Name,DisplayName | Format-Table -AutoSize
Write-Output "== VMTools =="
Get-Service VMTools -ErrorAction SilentlyContinue | Select-Object Name,Status,StartType | Format-Table -AutoSize
