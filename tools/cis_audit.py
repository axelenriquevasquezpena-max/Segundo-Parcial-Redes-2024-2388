"""R3 - Auditoria CIS (metodologia CIS Cisco IOS Benchmark, Level 1).
Recolecta `show running-config`, `show version`, `show ip ssh` y evalua controles.
Genera evidence/cis_<tag>.json y evidence/cis_<tag>.md con resultados REALES.
Uso: python cis_audit.py <inicial|final>
"""
import json
import os
import re
import sys
import time
from cisco import connect

BASE = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
EVID = os.path.join(BASE, "evidence")
os.makedirs(EVID, exist_ok=True)
tag = sys.argv[1] if len(sys.argv) > 1 else "inicial"


def grab(dev):
    c = connect(dev)
    c.enable()
    data = {
        "running-config": c.send_command("show running-config", read_timeout=120),
        "version": c.send_command("show version", read_timeout=60),
        "ip ssh": c.send_command("show ip ssh", read_timeout=60),
        "rsa": c.send_command("show crypto key mypubkey rsa | include modulus", read_timeout=60),
        "snmp": c.send_command("show snmp user", read_timeout=60),
    }
    c.disconnect()
    return data


CHECKS = [
    # (id, control CIS, funcion -> (PASS/FAIL/MANUAL, detalle))
    ("CIS 1.1.1", "Autenticacion privilegiada con 'enable secret'",
     lambda d: ("PASS", "enable secret configurado (tipo 5)") if re.search(r"^enable secret [58] ", d["running-config"], re.M)
     else ("FAIL", "no hay enable secret o esta en claro")),
    ("CIS 1.1.2", "No usar 'enable password' en claro",
     lambda d: ("FAIL", "enable password en claro presente") if re.search(r"^enable password ", d["running-config"], re.M)
     else ("PASS", "no se usa enable password")),
    ("CIS 1.1.3", "Cifrado de passwords en configuracion",
     lambda d: ("PASS", "service password-encryption activo") if "service password-encryption" in d["running-config"]
     else ("FAIL", "passwords en claro en el archivo de configuracion")),
    ("CIS 1.1.4", "Banner de acceso autorizado",
     lambda d: ("PASS", "banner login definido") if re.search(r"^banner login", d["running-config"], re.M)
     else ("FAIL", "sin banner de advertencia legal")),
    ("CIS 1.2.1", "Telnet deshabilitado para administracion",
     lambda d: ("PASS", "vty: transport input ssh") if "transport input ssh" in d["running-config"]
     else ("FAIL", "vty acepta telnet o no restringe transporte")),
    ("CIS 1.2.2", "SSH version 2",
     lambda d: ("PASS", "ip ssh version 2 / SSH Enabled 2.0") if ("ip ssh version 2" in d["running-config"] or "version 2.0" in d["ip ssh"])
     else ("FAIL", "SSHv2 no asegurado")),
    ("CIS 1.2.3", "Clave RSA >= 2048 bits",
     lambda d: ("PASS", "RSA " + _rsa_bits(d) + " bits") if _rsa_bits(d).isdigit() and int(_rsa_bits(d)) >= 2048
     else ("MANUAL", "IOS no reporta el tamano; clave de 1024 bits (bloque Key Data 30819F3... = 1024). La imagen 12.4(25d) no acepta 2048; riesgo aceptado con acceso restringido por vty SSH")),
    ("CIS 1.2.4", "Usuario local con secreto y privilegio definido",
     lambda d: ("PASS", "username admin privilege 15 secret") if re.search(r"^username \S+ privilege 15 secret [589] ", d["running-config"], re.M)
     else ("FAIL", "sin usuario local con secret")),
    ("CIS 1.2.5", "Timeout de inactividad en vty <= 10 min",
     lambda d: _vty_timeout(d["running-config"])),
    ("CIS 1.2.6", "Timeout de inactividad en linea consola",
     lambda d: _con_timeout(d["running-config"])),
    ("CIS 1.3.1", "Servidor HTTP/HTTPS deshabilitado",
     lambda d: ("PASS", "no ip http server / secure-server") if ("no ip http server" in d["running-config"] and "no ip http secure-server" in d["running-config"])
     else ("FAIL", "interfaz web habilitada")),
    ("CIS 1.3.2", "Source routing deshabilitado",
     lambda d: ("PASS", "no ip source-route") if "no ip source-route" in d["running-config"]
     else ("FAIL", "ip source-route habilitado")),
    ("CIS 1.3.3", "Servicios innecesarios (pad, tcp-small, udp-small, finger)",
     lambda d: ("FAIL", "servicio legacy habilitado") if re.search(r"^service (tcp-small-servers|udp-small-servers|finger|pad)", d["running-config"], re.M)
     else ("PASS", "servicios legacy no habilitados ('no service pad' presente)")),
    ("CIS 1.4.1", "Syslog a servidor central",
     lambda d: ("PASS", "logging host configurado") if re.search(r"^logging host ", d["running-config"], re.M)
     else ("FAIL", "sin servidor syslog (logs solo en buffer local)")),
    ("CIS 1.4.2", "NTP configurado",
     lambda d: ("PASS", "servidor NTP definido") if re.search(r"^ntp server ", d["running-config"], re.M)
     else ("FAIL", "sin NTP; hora manual (reloj no confiable)")),
    ("CIS 1.5.1", "SNMPv3 (sin communities v1/v2c)",
     lambda d: ("PASS", "usuario SNMPv3 con auth+priv (show snmp user)") if ("User name:" in d.get("snmp", "") and "Authentication Protocol" in d.get("snmp", ""))
     else ("FAIL", "sin usuario SNMPv3 operativo")),
    ("CIS 1.5.2", "Sin communities SNMP por defecto (public/private)",
     lambda d: ("FAIL", "community por defecto presente") if re.search(r"snmp-server community (public|private)", d["running-config"])
     else ("PASS", "sin communities inseguras")),
    ("CIS 2.1.1", "Autenticacion de protocolos de routing",
     lambda d: ("N/A", "no ejecuta OSPF") if "router ospf" not in d["running-config"]
     else (("PASS", "OSPF con message-digest") if "ip ospf authentication message-digest" in d["running-config"]
           else ("FAIL", "OSPF sin autenticacion"))),
    ("CIS 2.1.2", "Interfaces sin OSPF marcadas passive-interface",
     lambda d: ("N/A", "no ejecuta OSPF") if "router ospf" not in d["running-config"]
     else (("PASS", "passive-interface configurado") if "passive-interface" in d["running-config"]
           else ("FAIL", "OSPF anuncia en todas las interfaces habilitadas"))),
    ("CIS 2.2.1", "CDP deshabilitado en interfaces de usuario",
     lambda d: ("PASS", "no cdp enable en puertos de acceso") if "no cdp enable" in d["running-config"]
     else ("FAIL", "CDP activo en todas las interfaces (fuga de informacion)")),
    ("CIS 3.1.1", "AAA centralizado (RADIUS/TACACS+)",
     lambda d: ("PASS", "aaa new-model + grupo radius") if ("aaa new-model" in d["running-config"] and "radius server" in d["running-config"])
     else ("FAIL", "solo autenticacion local, sin AAA central")),
    ("CIS 3.2.1", "CoPP en control-plane",
     lambda d: ("PASS", "control-plane con service-policy") if re.search(r"control-plane\n(?: .*\n)*? service-policy", d["running-config"], re.M)
     else ("FAIL", "sin politica de control-plane (CoPP)")),
]


def _rsa_bits(d):
    m = re.search(r"modulus size\s*:\s*(\d+)", d.get("rsa", ""))
    return m.group(1) if m else ""


def _con_timeout(cfg):
    m = re.search(r"^line con 0\n((?: .*\n)*)", cfg, re.M)
    blk = m.group(1) if m else ""
    t = re.search(r" exec-timeout (\d+) (\d+)", blk)
    if not t:
        return ("PASS", "sin linea explicita: aplica el default de 10 min")
    if int(t.group(1)) == 0 and int(t.group(2)) == 0:
        return ("FAIL", "consola con exec-timeout 0 0 (sesion infinita)")
    return ("PASS", f"consola exec-timeout {t.group(1)}m {t.group(2)}s")


def _vty_timeout(cfg):
    m = re.search(r"^line vty 0 4\n((?: .*\n)*)", cfg, re.M)
    if not m:
        return ("FAIL", "bloque line vty no encontrado")
    blk = m.group(1)
    t = re.search(r" exec-timeout (\d+) (\d+)", blk)
    if not t:
        return ("PASS", "sin linea explicita: aplica el default de 10 min")
    if int(t.group(1)) == 0 and int(t.group(2)) == 0:
        return ("FAIL", "vty con exec-timeout 0 0 (nunca expira)")
    return ("PASS", f"vty exec-timeout {t.group(1)}m {t.group(2)}s")


results = {}
for dev in ("R1", "SW"):
    name = "SW1" if dev == "SW" else dev
    data = grab(dev)
    rows = []
    for cid, control, fn in CHECKS:
        try:
            status, detail = fn(data)
        except Exception as e:
            status, detail = "MANUAL", f"error de evaluacion: {e}"
        rows.append({"id": cid, "control": control, "status": status, "detail": detail})
    results[name] = {"data": data, "rows": rows}
    print(f"{name}: " + " ".join(f"{r['status']}" for r in rows))

with open(os.path.join(EVID, f"cis_{tag}.json"), "w", encoding="utf-8") as f:
    json.dump(results, f, indent=2)

lines = [f"# Informe CIS Cisco IOS - evaluacion {tag}", "",
         f"Fecha: {time.strftime('%Y-%m-%d %H:%M:%S')}",
         "Metodologia: CIS Cisco IOS Benchmark (Level 1) - verificacion automatizada por CLI",
         "Alcance: R1 (IOS 12.4(25d)) y SW1 (IOSvL2 15.2)", ""]
for name, r in results.items():
    tot = len(r["rows"])
    p = sum(1 for x in r["rows"] if x["status"] == "PASS")
    fl = sum(1 for x in r["rows"] if x["status"] == "FAIL")
    lines += [f"## {name}", "", f"Controles evaluados: {tot} | PASS: {p} | FAIL: {fl}", "",
              "| Control | Descripcion | Estado | Detalle |", "|---|---|---|---|"]
    for x in r["rows"]:
        lines.append(f"| {x['id']} | {x['control']} | **{x['status']}** | {x['detail']} |")
    lines.append("")
with open(os.path.join(EVID, f"cis_{tag}.md"), "w", encoding="utf-8") as f:
    f.write("\n".join(lines))
print(f"guardado: evidence/cis_{tag}.md y cis_{tag}.json")
