#!/bin/bash
exec > /tmp/out.txt 2>&1
command -v sshpass >/dev/null || sudo apt-get install -y sshpass >/dev/null 2>&1
SSHOPT="-oStrictHostKeyChecking=no -oUserKnownHostsFile=/dev/null -oKexAlgorithms=+diffie-hellman-group1-sha1 -oHostKeyAlgorithms=+ssh-rsa -oPubkeyAuthentication=no -oPreferredAuthentications=password -c aes256-cbc -oConnectTimeout=15"
echo "== SSH R1 con usuario del dominio (radius1) =="
sshpass -p '{{AD_USER_PASS}}' ssh $SSHOPT radius1@192.168.16.1 "show clock; show users" 2>&1 | sed 's/{{AD_USER_PASS}}/********/g' | head -20
echo "== SSH R1 con password incorrecta =="
sshpass -p 'ClaveIncorrecta123!' ssh $SSHOPT radius1@192.168.16.1 "show clock" 2>&1 | tail -5
echo "== SSH R1 con usuario inexistente =="
sshpass -p 'ClaveIncorrecta123!' ssh $SSHOPT noexiste@192.168.16.1 "show clock" 2>&1 | tail -5
