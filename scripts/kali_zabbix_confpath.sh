#!/bin/bash
exec > /tmp/out.txt 2>&1
echo "== rutas conf =="; sudo ls -ld /usr/share/zabbix/conf 2>&1; sudo ls -l /usr/share/zabbix/conf/ 2>&1 | head
echo "== apache conf zabbix =="; sudo cat /etc/apache2/conf-available/zabbix-frontend-php.conf
echo "== grep config path en php =="; sudo grep -rn "zabbix.conf.php" /usr/share/zabbix/include/*.php 2>/dev/null | head -5
echo "== errores apache =="; sudo tail -8 /var/log/apache2/error.log
