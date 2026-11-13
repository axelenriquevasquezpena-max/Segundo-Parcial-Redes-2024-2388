#!/bin/bash
exec > /tmp/out.txt 2>&1
sudo nmcli con mod NAT-INTERNET ipv4.route-metric 50
sudo nmcli con up NAT-INTERNET 2>&1
sleep 8
echo "== ruta =="; ip route
echo "== ip route get =="; ip route get 8.8.8.8
echo "== ping =="; ping -c 2 -W 3 8.8.8.8 | tail -3
echo "== curl =="; curl -4 -s -m 10 -o /dev/null -w "%{http_code}\n" http://deb.debian.org/debian/dists/bookworm/Release
echo "== apt update =="; sudo apt-get update 2>&1 | tail -5
