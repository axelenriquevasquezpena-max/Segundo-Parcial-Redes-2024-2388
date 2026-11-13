"""Sanea evidencias JSON que contienen running-config antes de publicar.
Reemplaza secretos, hashes y claves por <REDACTADO> sin alterar la estructura."""
import json
import os
import re
import sys

BASE = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
TARGETS = [
    os.path.join(BASE, "evidence", "cis_inicial.json"),
    os.path.join(BASE, "evidence", "cis_final.json"),
]

PATTERNS = [
    (r"^(\s*enable secret(?:\s+\d+)?)\s+.*$", r"\1 <REDACTADO>"),
    (r"^(\s*enable password(?:\s+\d+)?)\s+.*$", r"\1 <REDACTADO>"),
    (r"^(\s*username \S+.*?\bsecret(?:\s+\d+)?)\s+.*$", r"\1 <REDACTADO>"),
    (r"^(\s*username \S+.*?\bpassword(?:\s+\d+)?)\s+.*$", r"\1 <REDACTADO>"),
    (r"^(\s*ip ospf message-digest-key \d+ md5(?:\s+\d+)?)\s+.*$", r"\1 <REDACTADO>"),
    (r"^(\s*ip ospf authentication-key(?:\s+\d+)?)\s+.*$", r"\1 <REDACTADO>"),
    (r"^(\s*radius-server host .*?\bkey(?:\s+\d+)?)\s+.*$", r"\1 <REDACTADO>"),
    (r"^(\s*radius server .*?\bkey(?:\s+\d+)?)\s+.*$", r"\1 <REDACTADO>"),
    (r"^(\s*radius-server key(?:\s+\d+)?)\s+.*$", r"\1 <REDACTADO>"),
    (r"^(\s*snmp-server user)\s+.*$", r"\1 <REDACTADO>"),
    (r"^(\s*snmp-server community)\s+.*$", r"\1 <REDACTADO>"),
    (r"^(\s*key-string)\s+.*$", r"\1 <REDACTADO>"),
    (r"^(\s*ntp authentication-key \d+ md5)\s+.*$", r"\1 <REDACTADO>"),
    (r"^(\s*crypto isakmp key)\s+.*$", r"\1 <REDACTADO>"),
    (r"^(\s*password(?:\s+\d+)?)\s+.*$", r"\1 <REDACTADO>"),
]


def clean_text(texto):
    lineas = texto.splitlines()
    salida = []
    for linea in lineas:
        for pat, rep in PATTERNS:
            nueva = re.sub(pat, rep, linea, flags=re.I)
            if nueva != linea:
                linea = nueva
                break
        linea = re.sub(r"\$1\$[^\s]+", "<REDACTADO>", linea)
        linea = re.sub(r"\$9\$[^\s]+", "<REDACTADO>", linea)
        salida.append(linea)
    return "\n".join(salida)


def walk(obj):
    if isinstance(obj, dict):
        return {k: walk(v) for k, v in obj.items()}
    if isinstance(obj, list):
        return [walk(v) for v in obj]
    if isinstance(obj, str):
        return clean_text(obj)
    return obj


def main():
    for path in TARGETS:
        with open(path, encoding="utf-8") as f:
            data = json.load(f)
        limpio = walk(data)
        with open(path, "w", encoding="utf-8", newline="\n") as f:
            json.dump(limpio, f, ensure_ascii=False, indent=2)
        print("saneado:", os.path.relpath(path, BASE))

    # Verificacion posterior
    malos = 0
    for path in TARGETS:
        texto = open(path, encoding="utf-8").read()
        for pat in (r"secret\s+5\s+\$", r"\$1\$", r"key\s+7\s+[0-9A-Fa-f]{6,}",
                    r"password\s+7\s+\S+", r"snmp-server user\s+\S+\s+CIS"):
            if re.search(pat, texto, re.I):
                print("RESTO EN", path, "->", pat)
                malos += 1
    print("restos:", malos)
    return 0 if malos == 0 else 1


if __name__ == "__main__":
    sys.exit(main())
