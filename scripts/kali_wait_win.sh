#!/bin/bash
exec > /tmp/out.txt 2>&1
for i in $(seq 1 60); do
  if timeout 3 bash -c "</dev/tcp/192.168.16.51/5985" 2>/dev/null; then
    echo "WinRM disponible tras $((i*10)) s"
    break
  fi
  sleep 10
done
sleep 15
nxc winrm 192.168.16.51 -u '{{WINDOWS_USER}}' -p '{{WINDOWS_PASS}}' -x 'hostname' 2>&1 | tail -3
