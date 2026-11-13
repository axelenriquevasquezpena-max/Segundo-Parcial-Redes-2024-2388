Set-NetFirewallProfile -Profile Domain,Private,Public -Enabled False
Get-NetFirewallProfile | Select-Object Name, Enabled | Format-Table -AutoSize
Write-Output "firewall deshabilitado temporalmente"
