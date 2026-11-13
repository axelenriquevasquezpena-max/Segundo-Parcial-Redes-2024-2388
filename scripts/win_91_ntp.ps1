$ErrorActionPreference = "Continue"
Write-Output "== CONFIGURAR DC01 COMO SERVIDOR NTP =="
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\W32Time\TimeProviders\NtpServer" -Name Enabled -Value 1
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\W32Time\Config" -Name AnnounceFlags -Value 5
Set-Service -Name w32time -StartupType Automatic
Restart-Service -Name w32time -Force
Start-Sleep 3
Write-Output "== REGLA NTP SOLO LABORATORIO =="
if (-not (Get-NetFirewallRule -DisplayName "NTP Laboratorio" -ErrorAction SilentlyContinue)) {
  New-NetFirewallRule -DisplayName "NTP Laboratorio" -Direction Inbound -Protocol UDP -LocalPort 123 -RemoteAddress 192.168.16.0/24 -Action Allow | Out-Null
}
Get-NetFirewallRule -DisplayName "NTP Laboratorio" | Select-Object DisplayName, Enabled, Direction, Action | Format-Table -AutoSize
Write-Output "== ESTADO W32TIME =="
Get-Service w32time | Select-Object Name, Status, StartType | Format-Table -AutoSize
w32tm /query /status
Write-Output "== HORA =="
Get-Date -Format "yyyy-MM-dd HH:mm:ss K"
