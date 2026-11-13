#!/bin/bash
exec > /tmp/out.txt 2>&1
echo "== comando simple =="
nxc winrm 192.168.16.51 -u '{{WINDOWS_USER}}' -p '{{WINDOWS_PASS}}' -x 'powershell -NoProfile -Command "Get-Date -Format yyyy-MM-dd_HH:mm:ss"' 2>&1 | tail -4
echo "== listar temp =="
nxc winrm 192.168.16.51 -u '{{WINDOWS_USER}}' -p '{{WINDOWS_PASS}}' -x 'dir C:\Windows\Temp\win_02_promote.ps1' 2>&1 | tail -6
echo "== dominio actual =="
nxc winrm 192.168.16.51 -u '{{WINDOWS_USER}}' -p '{{WINDOWS_PASS}}' -x 'powershell -NoProfile -Command "(Get-CimInstance Win32_ComputerSystem).Domain"' 2>&1 | tail -4
echo "== servicio NTDS =="
nxc winrm 192.168.16.51 -u '{{WINDOWS_USER}}' -p '{{WINDOWS_PASS}}' -x 'sc query NTDS' 2>&1 | tail -8
