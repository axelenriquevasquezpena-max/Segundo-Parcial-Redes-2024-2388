#!/bin/bash
exec > /tmp/out.txt 2>&1
echo "== buscar zabbix.conf.php en todo el frontend =="
sudo grep -rn "zabbix\.conf\.php" /usr/share/zabbix --include=*.php 2>/dev/null | head -10
echo "== archivos de config =="
sudo find /usr/share/zabbix -maxdepth 3 -name "*conf*" -type f | head -20
echo "== CConfigFile =="
sudo sed -n '1,80p' /usr/share/zabbix/include/classes/core/CConfigFile.php 2>/dev/null
