#!/bin/bash
exec > /tmp/out.txt 2>&1
echo "== interfaces =="; ip -br addr
echo "== crear perfil NAT para eth1 =="
sudo nmcli -t con delete NAT-INTERNET 2>/dev/null || true
sudo nmcli con add type ethernet ifname eth1 con-name NAT-INTERNET ipv4.method auto ipv6.method disabled
sudo nmcli con up NAT-INTERNET 2>&1
sleep 10
echo "== ip eth1 =="; ip -4 addr show eth1 | grep inet
echo "== ruta =="; ip route
echo "== internet =="; ping -c 2 -W 3 8.8.8.8 | tail -3
echo "== dns =="; getent hosts deb.debian.org || echo "sin DNS"
echo "== apt update =="; sudo apt-get update 2>&1 | tail -4
echo "== candidatos zabbix =="; apt-cache policy zabbix-server-mysql 2>/dev/null | head -6
echo "== mariadb =="; apt-cache policy mariadb-server 2>/dev/null | head -4
