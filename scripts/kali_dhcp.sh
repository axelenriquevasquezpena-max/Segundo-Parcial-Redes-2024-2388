#!/bin/bash
exec > /tmp/out.txt 2>&1
echo "== crear perfil DHCP para el laboratorio =="
sudo nmcli -t con delete LAB-DHCP 2>/dev/null || true
sudo nmcli con add type ethernet ifname eth0 con-name LAB-DHCP ipv4.method auto ipv6.method disabled
echo "== activar =="
sudo nmcli con up LAB-DHCP 2>&1
sleep 12
echo "== estado =="; nmcli -t -f DEVICE,STATE,CONNECTION device status
echo "== ip =="; ip -4 addr show eth0 | grep inet
echo "== ruta =="; ip route
echo "== dns =="; cat /etc/resolv.conf | grep -v '^#' | head -5
echo "== ping gateway =="; ping -c 3 -W 2 192.168.16.1 | tail -3
echo "== ping SW1 =="; ping -c 2 -W 2 192.168.16.2 | tail -3
