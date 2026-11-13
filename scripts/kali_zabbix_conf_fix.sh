#!/bin/bash
exec > /tmp/out.txt 2>&1
sudo tee /etc/zabbix/zabbix.conf.php >/dev/null <<'PHPEOF'
<?php
// Configuracion del frontend Zabbix (laboratorio Parcial Redes)
global $DB, $ZBX_SERVER, $ZBX_SERVER_PORT, $ZBX_SERVER_NAME, $IMAGE_FORMAT_DEFAULT;

$DB['TYPE']     = 'MYSQL';
$DB['SERVER']   = 'localhost';
$DB['PORT']     = '0';
$DB['DATABASE'] = 'zabbix';
$DB['USER']     = 'zabbix';
$DB['PASSWORD'] = '{{ZABBIX_DB_PASS}}';
$DB['SCHEMA']   = '';
$DB['ENCRYPTION'] = false;
$DB['KEY_FILE'] = '';
$DB['CERT_FILE'] = '';
$DB['CA_FILE'] = '';
$DB['VERIFY_HOST'] = false;
$DB['CIPHER_LIST'] = '';

$ZBX_SERVER      = 'localhost';
$ZBX_SERVER_PORT = '10051';
$ZBX_SERVER_NAME = 'Zabbix Parcial Redes';

$IMAGE_FORMAT_DEFAULT = IMAGE_FORMAT_PNG;
PHPEOF
sudo chown root:www-data /etc/zabbix/zabbix.conf.php
sudo chmod 640 /etc/zabbix/zabbix.conf.php
sudo ln -sfn /etc/zabbix/zabbix.conf.php /usr/share/zabbix/conf/zabbix.conf.php
echo "== permisos =="
sudo ls -ld /etc/zabbix /etc/zabbix/web; sudo ls -l /etc/zabbix/zabbix.conf.php
sudo -u www-data test -r /etc/zabbix/zabbix.conf.php && echo "www-data LEE: SI" || echo "www-data LEE: NO"
sudo php -l /etc/zabbix/zabbix.conf.php
echo "== API login =="
curl -s -X POST -H 'Content-Type: application/json-rpc' \
  -d '{"jsonrpc":"2.0","method":"user.login","params":{"username":"Admin","password":"zabbix"},"id":1}' \
  http://127.0.0.1/zabbix/api_jsonrpc.php | head -c 300; echo
echo "== version API =="
curl -s -X POST -H 'Content-Type: application/json-rpc' \
  -d '{"jsonrpc":"2.0","method":"apiinfo.version","params":{},"id":1}' \
  http://127.0.0.1/zabbix/api_jsonrpc.php | head -c 200; echo
