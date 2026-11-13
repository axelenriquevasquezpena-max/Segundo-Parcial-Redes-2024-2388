#!/bin/bash
exec > /tmp/out.txt 2>&1
sudo chmod 755 /etc/zabbix/web
sudo chown root:www-data /etc/zabbix/web/zabbix.conf.php
sudo chmod 640 /etc/zabbix/web/zabbix.conf.php
echo "== permisos =="
sudo ls -ld /etc/zabbix/web; sudo ls -l /etc/zabbix/web/zabbix.conf.php /usr/share/zabbix/conf/zabbix.conf.php
sudo -u www-data test -r /usr/share/zabbix/conf/zabbix.conf.php && echo "www-data LEE: SI" || echo "www-data LEE: NO"
echo "== API login =="
curl -s -X POST -H 'Content-Type: application/json-rpc' \
  -d '{"jsonrpc":"2.0","method":"user.login","params":{"username":"Admin","password":"zabbix"},"id":1}' \
  http://127.0.0.1/zabbix/api_jsonrpc.php | head -c 300; echo
echo "== version API =="
curl -s -X POST -H 'Content-Type: application/json-rpc' \
  -d '{"jsonrpc":"2.0","method":"apiinfo.version","params":{},"id":1}' \
  http://127.0.0.1/zabbix/api_jsonrpc.php | head -c 200; echo
