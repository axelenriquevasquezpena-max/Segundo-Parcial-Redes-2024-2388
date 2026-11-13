#!/bin/bash
exec > /tmp/out.txt 2>&1
echo "== hostname =="; hostname
echo "== fecha =="; date
echo "== usuario =="; whoami
echo "== interfaces =="; ip -4 addr show | grep -E "inet |^[0-9]"
echo "== ruta =="; ip route
echo "== zabbix instalado? =="; command -v zabbix_server || echo "no zabbix_server"
systemctl is-active zabbix-server 2>/dev/null || true
systemctl is-active zabbix-agent 2>/dev/null || true
echo "== paquetes =="; dpkg -l 2>/dev/null | grep -E "zabbix|snmp" | awk '{print $2, $3}'
echo "== ssh =="; systemctl is-active ssh 2>/dev/null || true
echo "== ping gateway =="; ping -c 2 -W 2 192.168.16.1 | tail -3
echo "== ping R1 snmp udp =="; (command -v snmpget && snmpget -v3 -l authPriv -u zabbix -a SHA -A x -x DES -X x 192.168.16.1 1.3.6.1.2.1.1.1.0 2>&1 | head -3) || echo "sin net-snmp"
