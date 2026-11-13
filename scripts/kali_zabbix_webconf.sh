#!/bin/bash
exec > /tmp/out.txt 2>&1
echo "== existe conf? =="; sudo ls -l /etc/zabbix/web/ 2>&1
if [ ! -s /etc/zabbix/web/zabbix.conf.php ]; then
  echo "== creando zabbix.conf.php =="
  sudo mkdir -p /etc/zabbix/web
  sudo tee /etc/zabbix/web/zabbix.conf.php >/dev/null <<'PHPEOF'
<?php
return [
    'DB' => [
        'TYPE' => 'MYSQL',
        'SERVER' => 'localhost',
        'PORT' => '0',
        'DATABASE' => 'zabbix',
        'USER' => 'zabbix',
        'PASSWORD' => '{{ZABBIX_DB_PASS}}',
        'ENCRYPTION' => false,
        'VERIFY_HOST' => false,
        'VAULT' => [],
        'VAULT_URL' => '',
    ],
    'PHP' => ['EXECUTEMAXTIME' => 600, 'MEMORYLIMIT' => 128, 'MAXEXECUTIONTIME' => 300],
    'ZBX_SERVER_NAME' => 'Zabbix Parcial Redes',
    'IMAGE_FORMAT_DEFAULT' => 'png',
];
PHPEOF
  sudo chown root:www-data /etc/zabbix/web/zabbix.conf.php
  sudo chmod 640 /etc/zabbix/web/zabbix.conf.php
fi
echo "== resultado =="; sudo ls -l /etc/zabbix/web/zabbix.conf.php; sudo php -l /etc/zabbix/web/zabbix.conf.php
echo "== UI =="; curl -s -o /dev/null -w "%{http_code}\n" http://127.0.0.1/zabbix/
echo "== API =="; curl -s -X POST -H 'Content-Type: application/json-rpc' -d '{"jsonrpc":"2.0","method":"user.login","params":{"username":"Admin","password":"zabbix"},"id":1}' http://127.0.0.1/zabbix/api_jsonrpc.php | head -c 300; echo
