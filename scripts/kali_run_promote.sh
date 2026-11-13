#!/bin/bash
exec > /tmp/out.txt 2>&1
echo "== ejecutar directamente con -File =="
nxc winrm 192.168.16.51 -u '{{WINDOWS_USER}}' -p '{{WINDOWS_PASS}}' -x 'powershell -NoProfile -ExecutionPolicy Bypass -File C:\Windows\Temp\win_02_promote.ps1' 2>&1 | tail -30
