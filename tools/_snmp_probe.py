import json
from cisco import connect

v = json.load(open("../.vault/vault.json"))
c = connect("R1")
c.enable()
for opt in ["priv 3des", "priv des"]:
    c.send_command_timing("conf t", read_timeout=15)
    cmd = "snmp-server user zabbix CIS-GRP v3 auth sha {} {} {}".format(
        v["snmp_auth"], opt, v["snmp_priv"])
    out = c.send_command_timing(cmd, read_timeout=40)
    out = out.replace(v["snmp_auth"], "***").replace(v["snmp_priv"], "***")
    c.send_command_timing("end", read_timeout=15)
    print(opt, "=>", out.strip()[:300].replace("\n", " | "))
    print("users:", c.send_command("show snmp user").strip()[:300])
c.disconnect()
