#!/bin/bash
exec > /tmp/out.txt 2>&1
echo "== ZBX_CONFIG_FILE en defines =="
sudo grep -rn "ZBX_CONFIG_FILE" /usr/share/zabbix/include/defines.inc.php /usr/share/zabbix/*.php 2>/dev/null | head
echo "== constantes de config =="
sudo grep -rn "zabbix.conf.php\|ZBX_CONFIG" /usr/share/zabbix/include/*.php 2>/dev/null | head -10
echo "== estructura UI =="
sudo ls /usr/share/zabbix | head -20
echo "== open_basedir =="
php -i 2>/dev/null | grep -i "open_basedir\|Loaded Configuration"
echo "== prueba php como www-data =="
sudo tee /tmp/chk.php >/dev/null <<'PHP'
<?php
require_once '/usr/share/zabbix/include/defines.inc.php';
echo "ZBX_CONFIG_FILE=" . (defined('ZBX_CONFIG_FILE') ? ZBX_CONFIG_FILE : 'NO DEFINIDA') . "\n";
if (defined('ZBX_CONFIG_FILE')) {
  echo "existe=" . (file_exists(ZBX_CONFIG_FILE) ? 'SI' : 'NO') . "\n";
  echo "legible=" . (is_readable(ZBX_CONFIG_FILE) ? 'SI' : 'NO') . "\n";
}
PHP
sudo -u www-data php /tmp/chk.php 2>&1 | head -10
echo "== log apache reciente =="
sudo tail -5 /var/log/apache2/error.log
