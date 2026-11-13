#!/bin/bash
exec > /tmp/out.txt 2>&1
echo "== directorios y permisos =="
sudo ls -ld /etc/zabbix /etc/zabbix/web /usr/share/zabbix/conf
echo "== crear enlace esperado por el frontend =="
sudo ln -sfn /etc/zabbix/web/zabbix.conf.php /usr/share/zabbix/conf/zabbix.conf.php
sudo ls -l /usr/share/zabbix/conf/zabbix.conf.php
echo "== legible por www-data? =="
sudo -u www-data test -r /usr/share/zabbix/conf/zabbix.conf.php && echo "SI" || echo "NO"
echo "== API login =="
curl -s -X POST -H 'Content-Type: application/json-rpc' \
  -d '{"jsonrpc":"2.0","method":"user.login","params":{"username":"Admin","password":"zabbix"},"id":1}' \
  http://127.0.0.1/zabbix/api_jsonrpc.php | head -c 400; echo
echo "== version API =="
curl -s -X POST -H 'Content-Type: application/json-rpc' \
  -d '{"jsonrpc":"2.0","method":"apiinfo.version","params":{},"id":1}' \
  http://127.0.0.1/zabbix/api_jsonrpc.php | head -c 200; echo
