#!/bin/bash
exec > /tmp/out.txt 2>&1
echo "== internet =="
ping -c 1 -W 3 8.8.8.8 | tail -2
ip route | head -4
echo "== apt update =="
sudo apt-get update -o Acquire::http::Timeout=10 2>&1 | tail -4
echo "== instalar freeradius-utils =="
DEBIAN_FRONTEND=noninteractive sudo apt-get install -y freeradius-utils 2>&1 | tail -12
echo "== binario =="
command -v radtest || ls /usr/bin/radtest 2>&1
dpkg -l | grep -i freeradius | head
