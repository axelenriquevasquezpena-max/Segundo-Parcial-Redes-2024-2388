$ErrorActionPreference = "Stop"
Write-Output "== ZONA HORARIA =="
Set-TimeZone -Id "SA Western Standard Time"
Get-Date -Format "yyyy-MM-dd HH:mm:ss K"
(Get-TimeZone).DisplayName
Write-Output "== RENOMBRAR A DC01 =="
Rename-Computer -NewName "DC01" -Force
Write-Output "== INSTALAR ROLES =="
$r = Install-WindowsFeature -Name AD-Domain-Services, DNS, NPAS -IncludeManagementTools
$r.Success
Get-WindowsFeature AD-Domain-Services, DNS, NPAS | Select-Object Name, InstallState | Format-Table -AutoSize
Write-Output "== REINICIO =="
Restart-Computer -Force
