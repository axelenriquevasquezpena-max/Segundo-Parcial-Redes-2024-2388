#!/bin/bash
exec > /tmp/out.txt 2>&1
echo "== RADTEST =="
radtest 'radius1@parcial.local' '{{AD_USER_PASS}}' 192.168.16.51 0 '{{RADIUS_SECRET}}' 2>&1 | tail -8 | sed 's/{{AD_USER_PASS}}/********/g'
