"""Acceso local de respaldo en la consola de R1 mediante login local."""
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
cmds = ["line con 0", " login local", " exit"]
out = conn.send_config_set(cmds, read_timeout=90)
print(out)
print(conn.send_command("show running-config | section line con", read_timeout=60))
conn.send_config_set(["end", "write memory"], read_timeout=90)
conn.disconnect()
