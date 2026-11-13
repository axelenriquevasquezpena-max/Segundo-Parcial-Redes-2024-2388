#!/bin/bash
exec > /tmp/out.txt 2>&1
echo "== gateway campus 10.24.23.1 =="; ping -c 2 -W 2 10.24.23.1 | tail -3
echo "== ruta 10.24.88.1 =="; ping -c 2 -W 2 10.24.88.1 | tail -3
echo "== agregar default temporal =="; ip route add default via 10.24.23.1 2>&1; ip route
echo "== ping 8.8.8.8 =="; ping -c 2 -W 2 8.8.8.8 | tail -3
echo "== DNS =="; echo "nameserver 8.8.8.8" > /etc/resolv.conf; getent hosts deb.debian.org || echo "sin DNS"
echo "== apt update (solo indice) =="; apt-get update -o Acquire::http::Timeout=8 -o Acquire::Retries=1 2>&1 | tail -6
echo "== zabbix ya instalado? =="; command -v zabbix_server || echo no
ls /var/cache/apt/archives/*.deb 2>/dev/null | wc -l
