"""Exporta las configuraciones finales saneadas (sin secretos) a configs_equipos/.
Reemplaza claves, hashes, usuarios SNMP y comunidades por marcadores."""
import os
import re
import time
from cisco import connect

BASE = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
OUT = os.path.join(BASE, "configs_equipos")
os.makedirs(OUT, exist_ok=True)

PATTERNS = [
    (r"^(\s*enable secret).*$", r"\1 <REDACTADO>"),
    (r"^(\s*enable password).*$", r"\1 <REDACTADO>"),
    (r"^(\s*username .*?(?:secret|password))\s.*$", r"\1 <REDACTADO>"),
    (r"^(\s*ip ospf message-digest-key \d+ md5).*$", r"\1 <REDACTADO>"),
    (r"^(\s*ip ospf authentication-key).*$", r"\1 <REDACTADO>"),
    (r"^(\s*snmp-server user).*$", r"\1 <REDACTADO>"),
    (r"^(\s*snmp-server community).*$", r"\1 <REDACTADO>"),
    (r"^(\s*radius-server host .*?\bkey(?:\s+\d+)?)\s+.*$", r"\1 <REDACTADO>"),
    (r"^(\s*radius server .*?\bkey(?:\s+\d+)?)\s+.*$", r"\1 <REDACTADO>"),
    (r"^(\s*radius-server key(?:\s+\d+)?)\s+.*$", r"\1 <REDACTADO>"),
    (r"^(\s*key \d+)$", r"\1  <REDACTADO>"),
    (r"^(\s*key-string)\s+.*$", r"\1 <REDACTADO>"),
    (r"^(\s*crypto isakmp key)\s+.*$", r"\1 <REDACTADO>"),
    (r"^(\s*ntp authentication-key \d+ md5).*$", r"\1 <REDACTADO>"),
    # cualquier hash/hex residual tipo $1$..., password 7/8/9 y claves hex largas
    (r"^(\s*password).*$", r"\1 <REDACTADO>"),
]

meta = {"R1": "R1.cfg", "R2": "R2.cfg", "SW": "SW1.cfg"}
for dev, fname in meta.items():
    c = connect(dev)
    c.enable()
    cfg = c.send_command("show running-config", read_timeout=120)
    c.disconnect()
    clean = cfg
    for pat, rep in PATTERNS:
        clean = re.sub(pat, rep, clean, flags=re.M)
    header = (f"! Configuracion exportada del laboratorio GNS3 - {time.strftime('%Y-%m-%d %H:%M')}\n"
              "! Secretos, hashes y claves reemplazados por <REDACTADO>\n")
    body = clean.split("\n", 1)[1] if clean.lower().startswith("building configuration") else clean
    with open(os.path.join(OUT, fname), "w", encoding="utf-8") as f:
        f.write(header + body)
    print("exportado:", fname, len(body), "bytes")
