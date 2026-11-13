#!/bin/bash
exec > /tmp/out.txt 2>&1
for i in $(seq 1 40); do
  if timeout 3 bash -c "</dev/tcp/192.168.16.51/5985" 2>/dev/null; then echo "WinRM arriba ($((i*10))s)"; break; fi
  sleep 10
done
sleep 20
nxc winrm 192.168.16.51 -u '{{WINDOWS_USER}}' -p '{{WINDOWS_PASS}}' -x 'powershell -NoProfile -Command "(Get-CimInstance Win32_ComputerSystem).Domain; (Get-CimInstance Win32_OperatingSystem).LastBootUpTime; Get-Service NTDS | Select-Object -ExpandProperty Status"' 2>&1 | tail -8
