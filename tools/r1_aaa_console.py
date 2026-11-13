"""Deja acceso local de respaldo en la consola de R1 y restablece el usuario admin."""
import json
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import cisco

BASE = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
v = json.load(open(os.path.join(BASE, ".vault", "vault.json"), encoding="utf-8"))
try:
    sys.stdout.reconfigure(encoding="utf-8", errors="replace")
except Exception:
    pass

conn = cisco.connect("R1")
conn.enable()
cmds = [
    "aaa authentication login LOCAL local",
    "line con 0",
    " login authentication LOCAL",
    " exit",
    "username admin privilege 15 secret " + v["admin_ssh"],
]
out = conn.send_config_set(cmds, read_timeout=90)
for s in (v["admin_ssh"], v["ad_user_pass"], v["radius_secret"]):
    out = out.replace(s, "********")
print(out)
for c in ["show running-config | include aaa authentication|username admin|line con|login authentication",
          "show running-config | section line con"]:
    print("R1# " + c)
    print(conn.send_command(c, read_timeout=60))
conn.send_config_set(["end", "write memory"], read_timeout=90)
conn.disconnect()
