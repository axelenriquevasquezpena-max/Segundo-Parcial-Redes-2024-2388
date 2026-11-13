Start-Transcript -Path "C:\Windows\Temp\promote.log" -Append -Force
$ErrorActionPreference = "Continue"

Write-Output "== IP ESTATICA =="
$nic = "Ethernet0 2"
netsh interface ipv4 set address name="$nic" static 192.168.16.51 255.255.255.0 192.168.16.1
netsh interface ipv4 set dns name="$nic" static 127.0.0.1
Start-Sleep 3
ipconfig /all | Select-String -Pattern "IPv4|Default Gateway|DNS Servers" 

Write-Output "== PROMOVER BOSQUE parcial.local =="
$dsrm = ConvertTo-SecureString "{{DSRM_PASS}}" -AsPlainText -Force
Import-Module ADDSDeployment
Install-ADDSForest -DomainName "parcial.local" -DomainNetbiosName "PARCIAL" -InstallDns -SafeModeAdministratorPassword $dsrm -Force -NoRebootOnCompletion
Write-Output "== RESULTADO =="
(Get-CimInstance Win32_ComputerSystem).Domain
Stop-Transcript
Restart-Computer -Force
