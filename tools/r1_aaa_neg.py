"""Segunda pasada: prueba negativa AAA y contadores RADIUS."""
import json
import os
import sys
import time

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
out = []
conn.send_command_timing("test aaa group radius radius1 ClaveIncorrecta123! new-code", read_timeout=30)
time.sleep(8)
out.append("== PRUEBA AAA: PASSWORD INCORRECTA ==")
out.append(conn.send_command_timing("", read_timeout=30))
out.append("== CONTADORES RADIUS ==")
out.append(conn.send_command("show aaa servers", read_timeout=60))
conn.disconnect()
texto = "\n".join(out)
print(texto)
dest = os.path.join(BASE, "evidence", "r4_r1_aaa.txt")
open(dest, "a", encoding="utf-8", newline="\n").write("\n" + texto + "\n")
