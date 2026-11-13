#!/bin/bash
exec > /tmp/out.txt 2>&1
sudo mkdir -p /var/log/zabbix-server
sudo chown zabbix:zabbix /var/log/zabbix-server
sudo systemctl restart zabbix-server
sleep 10
echo "== estado =="; systemctl is-active zabbix-server mariadb apache2 zabbix-agent
echo "== log =="; sudo tail -12 /var/log/zabbix-server/zabbix_server.log 2>&1
echo "== proceso =="; pgrep -a zabbix_server | head -3
echo "== UI local =="; curl -s -o /dev/null -w "%{http_code}\n" http://127.0.0.1/zabbix/
echo "== UI desde la IP del laboratorio =="; curl -s -o /dev/null -w "%{http_code}\n" http://192.168.16.52/zabbix/
echo "== puertos =="; ss -lntp | grep -E ':80 |:10051 '
