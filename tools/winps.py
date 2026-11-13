#!/usr/bin/env python3
"""Ejecuta un script PowerShell en el Windows del laboratorio.

Flujo: el script se copia a Kali (guest.py), Kali lo publica por HTTP en su IP
del laboratorio y Windows lo descarga y ejecuta via WinRM (nxc).
Los secretos de la boveda se enmascaran en la salida.
"""
import base64
import json
import os
import subprocess
import sys
import tempfile

BASE = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
TOOLS = os.path.join(BASE, "tools")
VAULT = os.path.join(BASE, ".vault", "vault.json")


def main():
    try:
        sys.stdout.reconfigure(encoding="utf-8", errors="replace")
    except Exception:
        pass
    if len(sys.argv) < 2:
        print("uso: python winps.py <script.ps1>")
        return 2
    ps_path = sys.argv[1]
    name = os.path.basename(ps_path).replace(" ", "_")
    v = json.load(open(VAULT, encoding="utf-8"))
    body = open(ps_path, encoding="utf-8").read()
    for key, val in v.items():
        if isinstance(val, str):
            body = body.replace("{{" + key.upper() + "}}", val)
    payload = base64.b64encode(body.encode("utf-8")).decode()

    win_cmd = (
        "powershell -NoProfile -ExecutionPolicy Bypass -Command "
        "\"Invoke-WebRequest -UseBasicParsing http://192.168.16.52:8000/%s "
        "-OutFile C:\\Windows\\Temp\\%s; & C:\\Windows\\Temp\\%s\"" % (name, name, name)
    )

    bash = f"""#!/bin/bash
exec > /tmp/out.txt 2>&1
mkdir -p /tmp/win/ps
echo '{payload}' | base64 -d > /tmp/win/ps/{name}
if ! pgrep -f "http.server 8000" >/dev/null; then
  cd /tmp/win/ps && nohup python3 -m http.server 8000 >/dev/null 2>&1 &
  sleep 2
fi
nxc winrm 192.168.16.51 -u '{v['windows_user']}' -p '{v['windows_pass']}' -x '{win_cmd}' 2>&1
"""
    tmp = tempfile.mkdtemp()
    runner = os.path.join(tmp, "run.sh")
    open(runner, "w", encoding="utf-8", newline="\n").write(bash)

    proc = subprocess.run([sys.executable, os.path.join(TOOLS, "guest.py"), "kali", runner],
                          capture_output=True, text=True, encoding="utf-8", errors="replace")
    out = (proc.stdout or "") + (proc.stderr or "")
    for key, val in v.items():
        if isinstance(val, str) and len(val) >= 4:
            out = out.replace(val, "********")
    print(out)
    return proc.returncode


if __name__ == "__main__":
    sys.exit(main())
