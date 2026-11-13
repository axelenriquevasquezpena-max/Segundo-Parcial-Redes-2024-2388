#!/usr/bin/env python3
"""Registra R1 y SW1 en Zabbix con interfaz SNMPv3 y verifica métricas reales.
Se ejecuta dentro de Kali. Los secretos llegan por placeholders resueltos en el host."""
import json
import time
import urllib.request

API = "http://127.0.0.1/zabbix/api_jsonrpc.php"
SNMP_AUTH = "{{SNMP_AUTH}}"
SNMP_PRIV = "{{SNMP_PRIV}}"


def call(method, params, auth=None):
    payload = {"jsonrpc": "2.0", "method": method, "params": params, "id": 1}
    if auth:
        payload["auth"] = auth
    req = urllib.request.Request(API, data=json.dumps(payload).encode(),
                                 headers={"Content-Type": "application/json-rpc"})
    with urllib.request.urlopen(req, timeout=30) as r:
        data = json.loads(r.read().decode())
    if "error" in data:
        raise RuntimeError(f"{method}: {data['error']}")
    return data["result"]


auth = call("user.login", {"username": "Admin", "password": "zabbix"})
print("login OK")

groups = call("hostgroup.get", {"filter": {"name": "Laboratorio Redes"}}, auth)
if groups:
    gid = groups[0]["groupid"]
else:
    gid = call("hostgroup.create", {"name": "Laboratorio Redes"}, auth)["groupids"][0]
print("grupo:", gid)

tpls = call("template.get", {"output": ["host"], "search": {"host": "Cisco IOS"}}, auth)
tpl_name = tpls[0]["host"] if tpls else None
tpl_id = tpls[0]["templateid"] if tpls else None
if not tpl_id:
    tpls = call("template.get", {"output": ["host"], "search": {"host": "Network Generic Device"}}, auth)
    tpl_name, tpl_id = tpls[0]["host"], tpls[0]["templateid"]
print("template:", tpl_name, tpl_id)

HOSTS = [
    ("R1", "192.168.16.1", 0),   # DES en IOS 12.4
    ("SW1", "192.168.16.2", 1),  # AES128
]
created = []
for name, ip, privproto in HOSTS:
    exists = call("host.get", {"filter": {"host": name}}, auth)
    if exists:
        hid = exists[0]["hostid"]
        print(name, "ya existe", hid)
    else:
        res = call("host.create", {
            "host": name,
            "name": name,
            "groups": [{"groupid": gid}],
            "templates": [{"templateid": tpl_id}],
            "interfaces": [{
                "type": 2, "main": 1, "useip": 1, "ip": ip, "dns": "", "port": "161",
                "details": {
                    "version": 3, "bulk": 1, "securityname": "zabbix",
                    "securitylevel": 2, "authprotocol": 1,
                    "authpassphrase": SNMP_AUTH,
                    "privprotocol": privproto,
                    "privpassphrase": SNMP_PRIV,
                    "contextname": "",
                },
            }],
        }, auth)
        hid = res["hostids"][0]
        print(name, "creado", hid)
    created.append((name, hid))

# items propios para evidencia directa
for name, hid in created:
    ifaces = call("hostinterface.get", {"hostids": hid, "output": ["interfaceid", "type"]}, auth)
    ifid = ifaces[0]["interfaceid"]
    for iname, key, oid, vtype in [
        ("sysDescr laboratorio", "sysDescr.lab", "1.3.6.1.2.1.1.1.0", 4),
        ("sysUpTime laboratorio", "sysUpTime.lab", "1.3.6.1.2.1.1.3.0", 3),
        ("sysName laboratorio", "sysName.lab", "1.3.6.1.2.1.1.5.0", 4),
    ]:
        try:
            call("item.create", {
                "hostid": hid, "name": iname, "key_": key, "type": 20,
                "snmp_oid": oid, "value_type": vtype, "delay": "30s",
                "interfaceid": ifid,
            }, auth)
        except RuntimeError as e:
            if "already exists" not in str(e):
                print("item", key, e)

print("\n--- esperando 70s a que Zabbix sondee ---")
time.sleep(70)

for name, hid in created:
    items = call("item.get", {"hostids": hid, "filter": {"key_": ["sysUpTime.lab", "sysDescr.lab", "sysName.lab"]},
                              "output": ["name", "key_", "lastvalue", "lastclock", "state", "error"]}, auth)
    print(f"\n== {name} ==")
    for it in items:
        ts = time.strftime("%Y-%m-%d %H:%M:%S", time.localtime(int(it["lastclock"]))) if it["lastclock"] != "0" else "-"
        print(f'  {it["name"]:<24} valor={it["lastvalue"][:60]!r:<64} ultimo={ts} estado={it["state"]} err={it["error"]}')

    tr = call("trigger.get", {"hostids": hid, "output": ["description", "value"], "limit": 5}, auth)
    print("  triggers:", len(tr))
