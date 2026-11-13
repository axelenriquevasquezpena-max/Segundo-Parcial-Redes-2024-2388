#!/bin/bash
exec > /tmp/out.txt 2>&1
echo "== journal zabbix-server =="; sudo journalctl -u zabbix-server -n 15 --no-pager 2>&1 | tail -15
echo "== log =="; sudo tail -15 /var/log/zabbix/zabbix_server.log 2>&1
echo "== tablas =="; sudo mysql -N -e "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema='zabbix';"
echo "== dbversion =="; sudo mysql -N -e "SELECT mandatory FROM zabbix.dbversion;" 2>&1
echo "== apache listen =="; grep -n "^Listen" /etc/apache2/ports.conf
echo "== fix listen =="; sudo sed -i 's/^Listen 127.0.0.1:80/Listen 80/' /etc/apache2/ports.conf; grep -n "^Listen" /etc/apache2/ports.conf
echo "== timezone php =="; sudo sed -i 's|^;date.timezone =.*|date.timezone = America/Santo_Domingo|' /etc/php/8.4/apache2/php.ini; sudo grep -c "^date.timezone" /etc/php/8.4/apache2/php.ini
sudo systemctl restart apache2
echo "== listen tras reinicio =="; ss -lntp | grep ':80 '
echo "== restart zabbix =="; sudo systemctl restart zabbix-server; sleep 6; systemctl is-active zabbix-server
echo "== log tras restart =="; sudo tail -8 /var/log/zabbix/zabbix_server.log 2>&1
