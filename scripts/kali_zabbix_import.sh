#!/bin/bash
exec > /tmp/out.txt 2>&1
echo "== tamano esquema =="; ls -l /usr/share/zabbix-server-mysql/*.sql.gz; gzip -t /usr/share/zabbix-server-mysql/schema.sql.gz && echo "gzip OK"
echo "== primeras lineas =="; zcat /usr/share/zabbix-server-mysql/schema.sql.gz | head -5
echo "== import schema (stderr) =="
zcat /usr/share/zabbix-server-mysql/schema.sql.gz | sudo mysql --default-character-set=utf8mb4 zabbix 2>&1 | tail -10
echo "== tablas tras schema =="; sudo mysql -N -e "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema='zabbix';"
echo "== import data =="
zcat /usr/share/zabbix-server-mysql/images.sql.gz | sudo mysql --default-character-set=utf8mb4 zabbix 2>&1 | tail -5
zcat /usr/share/zabbix-server-mysql/data.sql.gz | sudo mysql --default-character-set=utf8mb4 zabbix 2>&1 | tail -5
echo "== tablas final =="; sudo mysql -N -e "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema='zabbix';"
echo "== dbversion =="; sudo mysql -N -e "SELECT mandatory FROM zabbix.dbversion;" 2>&1
echo "== LogFile config =="; grep -E "^(LogFile|LogType|DBHost|DBName|DBUser)" /etc/zabbix/zabbix_server.conf
