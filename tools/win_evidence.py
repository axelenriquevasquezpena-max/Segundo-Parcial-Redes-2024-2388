#!/usr/bin/env python3
"""Ejecuta un PS en Windows y guarda la salida limpia en evidence/ sin secretos."""
import json
import os
import re
import subprocess
import sys

BASE = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
TOOLS = os.path.join(BASE, "tools")
v = json.load(open(os.path.join(BASE, ".vault", "vault.json"), encoding="utf-8"))


def main():
    try:
        sys.stdout.reconfigure(encoding="utf-8", errors="replace")
    except Exception:
        pass
    ps_path, dest = sys.argv[1], sys.argv[2]
    proc = subprocess.run([sys.executable, os.path.join(TOOLS, "winps.py"), ps_path],
                          capture_output=True, text=True, encoding="utf-8", errors="replace")
    raw = (proc.stdout or "") + (proc.stderr or "")
    lines = []
    for line in raw.splitlines():
        m = re.match(r"^WINRM\s+\S+\s+\d+\s+\S+\s{2,}(.*)$", line)
        lines.append(m.group(1) if m else line)
    out = "\n".join(lines)
    for key, val in v.items():
        if isinstance(val, str) and len(val) >= 4:
            out = out.replace(val, "********")
    out = re.sub(r"key 7 [0-9A-Fa-f]+", "key 7 <REDACTADO>", out)
    path = os.path.join(BASE, dest)
    open(path, "w", encoding="utf-8", newline="\n").write(out + "\n")
    print(out)
    print("\n[guardado en " + path + "]")


if __name__ == "__main__":
    main()
