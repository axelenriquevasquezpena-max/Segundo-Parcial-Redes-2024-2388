#!/bin/bash
exec > /tmp/out.txt 2>&1
echo "== esperando promocion y reinicio =="
sleep 200
for i in $(seq 1 60); do
  if timeout 3 bash -c "</dev/tcp/192.168.16.51/5985" 2>/dev/null; then
    echo "puerto 5985 abierto en intento $i"
    break
  fi
  sleep 10
done
sleep 45
echo "== estado dominio =="
nxc winrm 192.168.16.51 -u '{{WINDOWS_USER}}' -p '{{WINDOWS_PASS}}' -x 'powershell -NoProfile -Command "(Get-CimInstance Win32_ComputerSystem).Domain; Get-Service NTDS | Select-Object -ExpandProperty Status; Get-Service DNS | Select-Object -ExpandProperty Status"' 2>&1 | tail -8
echo "== IP =="
nxc winrm 192.168.16.51 -u '{{WINDOWS_USER}}' -p '{{WINDOWS_PASS}}' -x 'ipconfig | findstr /C:"IPv4" /C:"Gateway"' 2>&1 | tail -5
echo "== ultimas lineas del log =="
nxc winrm 192.168.16.51 -u '{{WINDOWS_USER}}' -p '{{WINDOWS_PASS}}' -x 'powershell -NoProfile -Command "Get-Content C:\Windows\Temp\promote.log -Tail 15"' 2>&1 | tail -18
