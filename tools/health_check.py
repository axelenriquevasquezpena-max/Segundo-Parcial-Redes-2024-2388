"""Chequeo de salud post-interrupcion: estado de los 3 equipos y de los requisitos ya hechos."""
import os
import time
from cisco import connect

BASE = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
EVID = os.path.join(BASE, "evidence")
os.makedirs(EVID, exist_ok=True)
out = [f"# Chequeo de salud {time.strftime('%Y-%m-%d %H:%M:%S')}", ""]

CHECKS = {
    "R1": ["show clock", "show ip interface brief", "show ip ospf neighbor",
           "show ip dhcp binding", "show ip ssh", "show snmp user", "show snmp group",
           "show run | include ip dhcp pool|network|default-router|dns-server|lease",
           "show users"],
    "R2": ["show clock", "show ip interface brief", "show ip ospf neighbor",
           "show ip ssh", "show run | section line vty"],
    "SW": ["show clock", "show ip interface brief | include Vlan1", "show ip route",
           "show ip ssh", "show snmp user", "show run | section line vty",
           "show interfaces status"],
}
for dev in ("R1", "R2", "SW"):
    try:
        c = connect(dev)
        c.enable()
        out.append(f"\n===== {dev} =====")
        for cmd in CHECKS[dev]:
            out.append(f"\n--- {cmd} ---")
            out.append(c.send_command(cmd, read_timeout=90))
        c.disconnect()
    except Exception as e:
        out.append(f"\n===== {dev} ERROR: {type(e).__name__}: {e}")

txt = "\n".join(out)
open(os.path.join(EVID, "health_check.txt"), "w", encoding="utf-8").write(txt)
print(txt)
