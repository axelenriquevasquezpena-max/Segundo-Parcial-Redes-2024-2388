"""Configura AAA/RADIUS en R1 y verifica autenticacion contra NPS (sin exponer secretos)."""
import json
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import cisco

BASE = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
v = json.load(open(os.path.join(BASE, ".vault", "vault.json"), encoding="utf-8"))
secret = v["radius_secret"]
user_pass = v["ad_user_pass"]

try:
    sys.stdout.reconfigure(encoding="utf-8", errors="replace")
except Exception:
    pass

conn = cisco.connect("R1")
conn.enable()
out = []

cmds = [
    "aaa new-model",
    "radius-server host 192.168.16.51 auth-port 1812 acct-port 1813 key " + secret,
    "radius-server retransmit 2",
    "radius-server timeout 5",
    "radius-server deadtime 1",
    "ip radius source-interface FastEthernet0/0",
    "aaa authentication login default group radius local",
    "line vty 0 4",
    " login authentication default",
    " exit",
]
out.append("== CONFIGURACION APLICADA ==")
out.append(conn.send_config_set(cmds, read_timeout=90))

out.append("== VERIFICACION DE CONFIGURACION ==")
for c in ["show running-config | include aaa|radius-server|radius source",
          "show aaa servers",
          "show ip radius source-interface"]:
    try:
        out.append("R1# " + c + "\n" + conn.send_command(c, read_timeout=60))
    except Exception as e:
        out.append("R1# " + c + "\nerror: " + str(e))

out.append("== PRUEBA AAA: CREDENCIALES VALIDAS ==")
try:
    out.append(conn.send_command_timing(
        "test aaa group radius radius1 %s new-code" % user_pass, read_timeout=60))
except Exception as e:
    out.append("error: " + str(e))

out.append("== PRUEBA AAA: PASSWORD INCORRECTA ==")
try:
    out.append(conn.send_command_timing(
        "test aaa group radius radius1 ClaveIncorrecta123! new-code", read_timeout=60))
except Exception as e:
    out.append("error: " + str(e))

out.append("== GUARDAR ==")
out.append(conn.send_config_set(["end", "write memory"], read_timeout=90))
conn.disconnect()

texto = "\n".join(out)
for s in (secret, user_pass):
    texto = texto.replace(s, "********")
print(texto)

dest = os.path.join(BASE, "evidence", "r4_r1_aaa.txt")
open(dest, "w", encoding="utf-8", newline="\n").write(texto + "\n")
print("\n[guardado en " + dest + "]")
