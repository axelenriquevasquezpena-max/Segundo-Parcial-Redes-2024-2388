#!/bin/bash
exec > /tmp/out.txt 2>&1
export DEBIAN_FRONTEND=noninteractive
echo 'zabbix-server-mysql zabbix-server-mysql/install-dbconfig boolean false' | sudo debconf-set-selections
sudo apt-get install -y --no-install-recommends \
  zabbix-server-mysql zabbix-frontend-php zabbix-agent \
  apache2 libapache2-mod-php php-mysql php-gd php-bcmath php-mbstring php-xml php-ldap \
  mariadb-server snmp fping 2>&1 | tail -20
echo "== version =="; /usr/sbin/zabbix_server -V 2>&1 | head -2
echo "== esquema sql =="; sudo find /usr/share -path "*zabbix*" -name "*.sql*" 2>/dev/null | head
echo "== servicios =="; systemctl is-enabled mariadb apache2 zabbix-server zabbix-agent 2>&1
echo "== config server =="; ls -l /etc/zabbix/ 2>/dev/null
