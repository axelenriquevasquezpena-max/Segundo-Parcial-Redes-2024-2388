#!/bin/bash
exec > /tmp/out.txt 2>&1
echo "== paquetes zabbix disponibles =="; apt-cache search zabbix | sort
echo "== contenido server-mysql =="; apt-cache show zabbix-server-mysql 2>/dev/null | grep -E "^(Version|Depends)" | head -6
echo "== frontend =="; apt-cache show zabbix-frontend-php 2>/dev/null | grep -E "^(Version|Depends)" | head -6
