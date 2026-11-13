#!/bin/bash
exec > /tmp/out.txt 2>&1
echo "== R1 sysDescr / sysName (DES) =="
snmpwalk -v3 -l authPriv -u zabbix -a SHA -A '{{SNMP_AUTH}}' -x DES -X '{{SNMP_PRIV}}' 192.168.16.1 1.3.6.1.2.1.1 2>&1 | head -12
echo "== SW1 sysDescr / sysName (AES128) =="
snmpwalk -v3 -l authPriv -u zabbix -a SHA -A '{{SNMP_AUTH}}' -x AES -X '{{SNMP_PRIV}}' 192.168.16.2 1.3.6.1.2.1.1 2>&1 | head -12
echo "== uptime R1 =="
snmpget -v3 -l authPriv -u zabbix -a SHA -A '{{SNMP_AUTH}}' -x DES -X '{{SNMP_PRIV}}' 192.168.16.1 1.3.6.1.2.1.1.3.0 2>&1
echo "== uptime SW1 =="
snmpget -v3 -l authPriv -u zabbix -a SHA -A '{{SNMP_AUTH}}' -x AES -X '{{SNMP_PRIV}}' 192.168.16.2 1.3.6.1.2.1.1.3.0 2>&1
