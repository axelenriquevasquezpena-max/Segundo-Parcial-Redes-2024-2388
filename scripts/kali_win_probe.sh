#!/bin/bash
exec > /tmp/out.txt 2>&1
echo "== puertos Windows =="
for p in 445 135 3389 5985; do timeout 3 bash -c "</dev/tcp/192.168.16.51/$p" 2>/dev/null && echo "$p abierto" || echo "$p cerrado"; done
echo "== herramientas =="
for t in impacket-wmiexec.py wmiexec.py nxc crackmapexec smbclient xfreerdp; do command -v $t >/dev/null && echo "$t OK" || echo "$t NO"; done
echo "== python impacket =="
python3 -c "import impacket, sys; print('impacket', impacket.__version__ if hasattr(impacket,'__version__') else 'ok')" 2>&1
echo "== listado SMB =="
smbclient -L //192.168.16.51 -U '{{WINDOWS_USER}}%{{WINDOWS_PASS}}' -m SMB3 2>&1 | head -20
