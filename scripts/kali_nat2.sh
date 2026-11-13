#!/bin/bash
exec > /tmp/out.txt 2>&1
echo "== ping NAT gw 145.2 =="; ping -c 2 -W 2 192.168.145.2 | tail -3
echo "== ping host 145.1 =="; ping -c 2 -W 2 192.168.145.1 | tail -3
echo "== resolv.conf =="; grep -v '^#' /etc/resolv.conf | head
echo "== curl ipv4 =="; curl -4 -s -m 8 -o /dev/null -w "%{http_code}\n" http://deb.debian.org/debian/dists/bookworm/Release || echo "curl fallo"
echo "== curl ipv6 =="; curl -6 -s -m 8 -o /dev/null -w "%{http_code}\n" http://deb.debian.org/debian/dists/bookworm/Release || echo "curl6 fallo"
echo "== ip route get 8.8.8.8 =="; ip route get 8.8.8.8
echo "== traceroute =="; command -v traceroute && traceroute -n -m 3 -w 2 8.8.8.8 2>&1 | tail -5
