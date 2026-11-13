"""R1 evidence: end-to-end DHCP test. SW1's Vlan1 is temporarily a DHCP client,
then restored to its static management address. Saves evidence/r1_dhcp_test.txt."""
import os
import time
from cisco import connect

BASE = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
EVID = os.path.join(BASE, "evidence")
os.makedirs(EVID, exist_ok=True)
lines = []


def log(s):
    print(s)
    lines.append(str(s))


r1 = connect("R1")
r1.enable()
sw = connect("SW")
sw.enable()

log("### R1: estadisticas DHCP antes ###")
log(r1.send_command("show ip dhcp server statistics"))

log("\n### SW1: Vlan1 pasa a cliente DHCP (temporal) ###")
log(sw.send_config_set(["interface Vlan1", "no ip address", "ip address dhcp"], cmd_verify=False))
time.sleep(25)
log(sw.send_command_timing("show dhcp lease", read_timeout=30, last_read=3))
log(sw.send_command("show ip interface brief | include Vlan1"))

log("\n### R1: tabla de bindings (debe aparecer un lease nuevo .52) ###")
log(r1.send_command("show ip dhcp binding"))

log("\n### Restaurando direccionamiento estatico de SW1 ###")
log(sw.send_config_set(["interface Vlan1", "no ip address dhcp",
                        "ip address 192.168.16.2 255.255.255.0", "no shutdown"], cmd_verify=False))
time.sleep(8)
log(sw.send_command("show ip interface brief | include Vlan1"))
log(sw.send_command("write memory"))

log("\n### R1: estadisticas DHCP despues ###")
log(r1.send_command("show ip dhcp server statistics"))

log("\n### Conectividad post-restauracion: R1 -> SW1 ###")
log(r1.send_command("ping 192.168.16.2 repeat 4"))

r1.disconnect()
sw.disconnect()
with open(os.path.join(EVID, "r1_dhcp_test.txt"), "w", encoding="utf-8") as f:
    f.write("\n".join(lines))
print("\nguardado: evidence/r1_dhcp_test.txt")
