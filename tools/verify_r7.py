"""R7 evidence: SSH login R2 -> R1 with local user admin (IOS 12.4 both sides).
Writes evidence/r7_ssh_test.txt with secrets masked."""
import json
import os
from cisco import connect, VAULT

BASE = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
EVID = os.path.join(BASE, "evidence")
os.makedirs(EVID, exist_ok=True)
with open(VAULT, encoding="utf-8") as f:
    pwd = json.load(f)["admin_ssh"]

lines = []


def log(s):
    s = str(s).replace(pwd, "********")
    print(s)
    lines.append(s)


r2 = connect("R2")
r2.enable()
log("### R2 -> ssh -l admin 192.168.16.1 (R1) ###")
out = r2.send_command_timing("ssh -l admin 192.168.16.1", read_timeout=30, last_read=4.0)
log(out)
if "assword" in out.lower():
    out = r2.send_command_timing(pwd, read_timeout=30, last_read=5.0)
    log(out)
out = r2.send_command_timing("show ip ssh", read_timeout=30, last_read=3.0)
log(out)
out = r2.send_command_timing("show clock", read_timeout=30, last_read=3.0)
log(out)
out = r2.send_command_timing("exit", read_timeout=30, last_read=3.0)
log(out)

log("\n### Configuracion vty / SSH en R1 ###")
log(r2.send_command("show running-config | section line vty"))
r2.disconnect()

with open(os.path.join(EVID, "r7_ssh_test.txt"), "w", encoding="utf-8") as f:
    f.write("\n".join(lines))
print("\nguardado: evidence/r7_ssh_test.txt")
