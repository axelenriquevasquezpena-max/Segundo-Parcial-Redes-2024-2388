#!/bin/bash
exec > /tmp/out.txt 2>&1
echo "== whoami via WinRM =="
nxc winrm 192.168.16.51 -u '{{WINDOWS_USER}}' -p '{{WINDOWS_PASS}}' -x 'whoami' 2>&1 | tail -8
echo "== hostname y version =="
nxc winrm 192.168.16.51 -u '{{WINDOWS_USER}}' -p '{{WINDOWS_PASS}}' -x 'hostname & ver' 2>&1 | tail -10
echo "== estado VMTools =="
nxc winrm 192.168.16.51 -u '{{WINDOWS_USER}}' -p '{{WINDOWS_PASS}}' -x 'sc query VMTools' 2>&1 | tail -12
