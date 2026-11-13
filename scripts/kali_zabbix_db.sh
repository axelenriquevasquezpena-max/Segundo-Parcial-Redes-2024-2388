#!/bin/bash
exec > /tmp/out.txt 2>&1
set -x
sudo systemctl enable --now mariadb
sudo mysql -e "CREATE DATABASE IF NOT EXISTS zabbix CHARACTER SET utf8mb4 COLLATE utf8mb4_bin;"
sudo mysql -e "CREATE USER IF NOT EXISTS 'zabbix'@'localhost' IDENTIFIED BY '{{ZABBIX_DB_PASS}}';"
sudo mysql -e "GRANT ALL PRIVILEGES ON zabbix.* TO 'zabbix'@'localhost'; FLUSH PRIVILEGES;"
sudo mysql -e "SET GLOBAL log_bin_trust_function_creators = 1;"
zcat /usr/share/zabbix-server-mysql/schema.sql.gz | sudo mysql zabbix
zcat /usr/share/zabbix-server-mysql/images.sql.gz | sudo mysql zabbix
zcat /usr/share/zabbix-server-mysql/data.sql.gz | sudo mysql zabbix
echo "== tablas creadas =="
sudo mysql -N -e "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema='zabbix';"# configurar password en el server
sudo sed -i "s|^# DBPassword=.*|DBPassword={{ZABBIX_DB_PASS}}|" /etc/zabbix/zabbix_server.conf
sudo grep -c "^DBPassword=" /etc/zabbix/zabbix_server.conf
# frontend: config escrita directamente para evitar el asistente web
sudo mkdir -p /etc/zabbix/web
sudo tee /etc/zabbix/web/zabbix.conf.php >/dev/null <<'PHPEOF'
<?php
// Configuracion generada por automatizacion del laboratorio
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
echo "== apache zabbix =="
sudo sed -i 's|# php_value date.timezone.*|php_value date.timezone America/Santo_Domingo|' /etc/zabbix/apache.conf
sudo a2enconf zabbix-frontend-php 2>&1 | tail -2
sudo systemctl enable --now apache2
sudo systemctl enable --now zabbix-server
sudo systemctl enable --now zabbix-agent
sleep 8
echo "== estado =="; systemctl is-active mariadb apache2 zabbix-server zabbix-agent
echo "== puerto 80 =="; ss -lntp | grep ':80 '
echo "== frontend http =="; curl -s -o /dev/null -w "%{http_code}\n" http://127.0.0.1/zabbix/
echo "== log zabbix =="; sudo tail -5 /var/log/zabbix/zabbix_server.log 2>/dev/null
