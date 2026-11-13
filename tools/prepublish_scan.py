"""Escaneo previo a la publicación: busca secretos y archivos prohibidos.
No imprime valores sensibles; solo ruta, línea y tipo de hallazgo."""
import json
import os
import re
import sys

BASE = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
EXCLUIR_DIRS = {".git", ".vault", "backups", "__pycache__", "vm"}
EXCLUIR_FILES = {"prepublish_scan.py"}
TEXT_EXT = {".md", ".txt", ".cfg", ".json", ".py", ".ps1", ".sh", ".svg", ".yml", ".yaml", ".ini", ".log"}

PATRONES = [
    ("hash tipo 5", re.compile(r"secret\s+5\s+\$")),
    ("secreto tipo 7", re.compile(r"secret\s+7\s+\S+")),
    ("clave OSPF tipo 7", re.compile(r"key\s+7\s+[0-9A-Fa-f]{6,}")),
    ("password tipo 7", re.compile(r"password\s+7\s+\S+")),
    ("hash MD5", re.compile(r"\$1\$[^\s]+")),
    ("hash scrypt", re.compile(r"\$9\$[^\s]+")),
    ("usuario SNMPv3", re.compile(r"snmp-server\s+user\s+\S+\s+\S+\s+v3")),
    ("community SNMP", re.compile(r"snmp-server\s+community\s+(?!<)\S+")),
    ("clave RADIUS", re.compile(r"radius-server\s+host.*?\bkey\s+[0-9A-Fa-f]")),
    ("clave privada", re.compile(r"BEGIN .*PRIVATE KEY")),
    ("token GitHub", re.compile(r"gh[pousr]_[A-Za-z0-9]{20,}|github_pat_[A-Za-z0-9_]{20,}")),
    ("token AWS", re.compile(r"AKIA[0-9A-Z]{16}")),
    ("token Google", re.compile(r"AIza[0-9A-Za-z_\-]{35}")),
    ("token Slack", re.compile(r"xox[baprs]-[A-Za-z0-9-]{10,}")),
]

PERMITIDOS = ("{{", "<REDACTADO>", "<clave>", "***", "placeholder", "REDACTADO")


def es_texto(path):
    return os.path.splitext(path)[1].lower() in TEXT_EXT


def leer(path):
    for enc in ("utf-8", "utf-8-sig", "latin-1"):
        try:
            with open(path, encoding=enc) as f:
                return f.read()
        except UnicodeDecodeError:
            continue
    return ""


def main():
    secretos = []
    vault = os.path.join(BASE, ".vault", "vault.json")
    if os.path.exists(vault):
        with open(vault, encoding="utf-8") as f:
            datos = json.load(f)
        for v in datos.values():
            if isinstance(v, str) and len(v) >= 4:
                secretos.append(v)

    hallazgos = []
    archivos = 0
    for raiz, dirs, files in os.walk(BASE):
        dirs[:] = [d for d in dirs if d not in EXCLUIR_DIRS]
        for nombre in files:
            path = os.path.join(raiz, nombre)
            rel = os.path.relpath(path, BASE)
            if nombre in EXCLUIR_FILES or not es_texto(path):
                continue
            archivos += 1
            texto = leer(path)
            lineas = texto.splitlines()
            for i, linea in enumerate(lineas, 1):
                if any(p in linea for p in PERMITIDOS):
                    continue
                for etiqueta, pat in PATRONES:
                    if pat.search(linea):
                        hallazgos.append((rel, i, etiqueta))
                for s in secretos:
                    if s in linea:
                        hallazgos.append((rel, i, "VALOR DE LA BOVEDA"))
                        break

    print("archivos de texto revisados:", archivos)
    print("valores de boveda cargados:", len(secretos))
    if not hallazgos:
        print("RESULTADO: sin secretos detectados")
        return 0
    print("RESULTADO: HALLAZGOS")
    for rel, i, etiqueta in hallazgos:
        print(f"  {rel}:{i}  -> {etiqueta}")
    return 1


if __name__ == "__main__":
    sys.exit(main())
