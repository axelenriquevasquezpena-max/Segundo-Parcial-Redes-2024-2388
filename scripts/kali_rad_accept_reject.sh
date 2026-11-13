#!/bin/bash
exec > /tmp/out.txt 2>&1
echo "== 1) USUARIO VALIDO + PASSWORD CORRECTA =="
radtest 'radius1@parcial.local' '{{AD_USER_PASS}}' 192.168.16.51 0 '{{RADIUS_SECRET}}' 2>&1 | grep -E "Received|Access-" | sed 's/{{AD_USER_PASS}}/********/g'
echo "== 2) USUARIO VALIDO + PASSWORD INCORRECTA =="
radtest 'radius1@parcial.local' 'ClaveIncorrecta123!' 192.168.16.51 0 '{{RADIUS_SECRET}}' 2>&1 | grep -E "Received|Access-"
echo "== 3) USUARIO INEXISTENTE =="
radtest 'noexiste@parcial.local' 'ClaveIncorrecta123!' 192.168.16.51 0 '{{RADIUS_SECRET}}' 2>&1 | grep -E "Received|Access-"
