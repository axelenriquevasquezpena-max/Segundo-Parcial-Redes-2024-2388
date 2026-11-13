"""Acceso a las VM: lee .vault/vm_creds.txt y prueba caminos de administracion.
No imprime credenciales. Uso: python vms.py probe"""
import os
import socket
import subprocess
import sys

BASE = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
CREDS = os.path.join(BASE, ".vault", "vm_creds.txt")
VMRUN = r"C:\Program Files (x86)\VMware\VMware Workstation\vmrun.exe"


def creds():
    d = {}
    if os.path.exists(CREDS):
        for ln in open(CREDS, encoding="utf-8", errors="replace"):
            if "=" in ln:
                k, v = ln.split("=", 1)
                d[k.strip()] = v.strip().strip('"').strip("'")
    return d


def probe():
    c = creds()
    print("claves disponibles:", ", ".join(sorted(c)))
    # alcanzabilidad desde el host (se espera NO ruteable: LAN dentro de GNS3)
    for ip in ("192.168.16.50", "192.168.16.51", "192.168.16.52"):
        for port in (22, 445, 5985, 3389):
            s = socket.socket()
            s.settimeout(1.0)
            try:
                s.connect((ip, port))
                print(f"{ip}:{port} ABIERTO")
            except Exception:
                pass
            finally:
                s.close()
    print("probe terminado")


if __name__ == "__main__":
    probe()
