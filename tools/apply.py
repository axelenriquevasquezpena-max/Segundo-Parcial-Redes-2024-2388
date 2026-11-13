"""Apply a config snippet to a device, with save and verification.
Usage: python apply.py <R1|R2|SW> <config_file.cfg> [--save]
Lines starting with # are ignored. {{CLAVE}} placeholders are resolved from .vault/vault.json.
"""
import json
import os
import sys
from cisco import connect

BASE = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
VAULT = os.path.join(BASE, ".vault", "vault.json")


def load_vault():
    if os.path.exists(VAULT):
        with open(VAULT, encoding="utf-8") as f:
            return json.load(f)
    return {}


def build(path, vault):
    with open(path, encoding="utf-8") as f:
        raw = f.read()
    for k, v in vault.items():
        raw = raw.replace("{{" + k.upper() + "}}", str(v))
    cmds = [ln.rstrip() for ln in raw.splitlines() if ln.strip() and not ln.strip().startswith("#")]
    return cmds


def main():
    dev, cfg = sys.argv[1], sys.argv[2]
    save = "--save" in sys.argv
    vault = load_vault()
    for key in vault:
        if "{{" + key.upper() + "}}" in open(cfg, encoding="utf-8").read() and not vault[key]:
            print(f"ERROR: falta {{${key}}} en la bóveda")
            return 1
    cmds = build(cfg, vault)
    conn = connect(dev)
    conn.enable()
    out = conn.send_config_set(cmds, read_timeout=180, cmd_verify=False)
    # ocultar cualquier secreto de la boveda que aparezca en el eco de la consola
    for k, v in vault.items():
        if v:
            out = out.replace(str(v), "********")
    print(out)
    if save:
        print("== write memory ==")
        print(conn.send_command("write memory", read_timeout=60))
    conn.disconnect()
    return 0


if __name__ == "__main__":
    sys.exit(main())
