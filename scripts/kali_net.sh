#!/bin/bash
exec > /tmp/out.txt 2>&1
echo "== nmcli devices =="; nmcli -t -f DEVICE,TYPE,STATE,CONNECTION device status
echo "== conexiones =="; nmcli -t -f NAME,UUID,TYPE,DEVICE con show
echo "== eth0 ipv4 method =="; nmcli -t -f ipv4.method,ipv4.addresses,ipv4.gateway con show "$(nmcli -t -f NAME,DEVICE con show --active | grep ':eth0' | cut -d: -f1)" 2>/dev/null
echo "== ip -d eth0 =="; ip -d addr show eth0 | head -12
echo "== internet =="; ping -c 2 -W 2 8.8.8.8 | tail -3
echo "== DNS =="; getent hosts deb.debian.org || echo "sin resolucion DNS"
echo "== ping R1 =="; ping -c 2 -W 2 192.168.16.1 | tail -3
echo "== leases =="; ls -l /var/lib/dhcp/ 2>/dev/null | tail -5
echo "== zabbix repo =="; ls /etc/apt/sources.list.d/ 2>/dev/null
echo "== espacio =="; df -h / | tail -1
