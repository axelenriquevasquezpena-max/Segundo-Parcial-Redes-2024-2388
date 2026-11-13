#!/bin/bash
exec > /tmp/out.txt 2>&1
echo "== posibles esquemas =="; sudo find /usr/share/doc/zabbix-server-mysql /usr/share/zabbix-server-mysql /usr/share/zabbix -maxdepth 2 -type f \( -name "*.sql*" -o -name "*.gz" \) 2>/dev/null | head -10
echo "== dpkg -L server =="; dpkg -L zabbix-server-mysql | grep -Ei "sql|gz" | head -10
echo "== apache conf zabbix =="; ls -l /etc/zabbix/apache.conf 2>/dev/null; ls /etc/apache2/conf-available/ | grep -i zabbix
echo "== estado servicios =="; systemctl is-active mariadb apache2 zabbix-server 2>&1
