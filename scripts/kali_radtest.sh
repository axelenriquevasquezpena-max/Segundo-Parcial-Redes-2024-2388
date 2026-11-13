#!/bin/bash
exec > /tmp/out.txt 2>&1
export DEBIAN_FRONTEND=noninteractive
if ! command -v radtest >/dev/null; then
  echo "== instalando freeradius-utils =="
  apt-get install -y --no-install-recommends freeradius-utils >/dev/null 2>&1
fi
command -v radtest || { echo "radtest no disponible"; exit 1; }
echo "== RADTEST usuario valido =="
radtest 'radius1@parcial.local' '{{AD_USER_PASS}}' 192.168.16.51 0 '{{RADIUS_SECRET}}' 2>&1 | sed 's/{{AD_USER_PASS}}/********/g'
echo "== RADTEST password incorrecta =="
radtest 'radius1@parcial.local' 'ClaveIncorrecta123!' 192.168.16.51 0 '{{RADIUS_SECRET}}' 2>&1
echo "== RADTEST secreto incorrecto =="
radtest 'radius1@parcial.local' '{{AD_USER_PASS}}' 192.168.16.51 0 'SecretoMalo' 2>&1 | tail -4 | sed 's/{{AD_USER_PASS}}/********/g'
