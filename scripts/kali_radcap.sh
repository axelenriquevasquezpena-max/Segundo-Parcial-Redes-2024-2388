#!/bin/bash
exec > /tmp/out.txt 2>&1
command -v tcpdump >/dev/null || sudo apt-get install -y tcpdump >/dev/null 2>&1
echo "== captura durante radtest =="
sudo timeout 12 tcpdump -i eth0 -n -c 6 udp port 1812 > /tmp/cap.txt 2>&1 &
sleep 2
radtest 'radius1@parcial.local' '{{AD_USER_PASS}}' 192.168.16.51 0 '{{RADIUS_SECRET}}' 2>&1 | tail -6 | sed 's/{{AD_USER_PASS}}/********/g'
sleep 3
echo "== paquetes =="
cat /tmp/cap.txt
echo "== ruta a DC =="
ip route get 192.168.16.51
echo "== ping DC =="
ping -c 2 -W 2 192.168.16.51 | tail -3
