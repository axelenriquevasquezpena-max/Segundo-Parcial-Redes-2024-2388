"""Ejecuta scripts dentro de las VM via VMware Guest Operations (sin red, sin exponer secretos).
Uso:
  python guest.py kali   <script_local.sh>     -> ejecuta bash y devuelve stdout
  python guest.py win    <script_local.ps1>    -> ejecuta PowerShell y devuelve stdout
"""
import os
import subprocess
import sys
import tempfile

BASE = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
VMRUN = r"C:\Program Files (x86)\VMware\VMware Workstation\vmrun.exe"
VM = {
    "kali": r"C:\Virtual Machines\Kali Linux\Kali Linux.vmx",
    "win": r"C:\Virtual Machines\Windows Server 2022\Windows Server 2022.vmx",
    "db": r"C:\Virtual Machines\Laboratorio-OneDrive\DB-P2.vmx",
}


def creds():
    d = {}
    p = os.path.join(BASE, ".vault", "vm_creds.txt")
    for ln in open(p, encoding="utf-8", errors="replace"):
        if "=" in ln:
            k, v = ln.split("=", 1)
            d[k.strip()] = v.strip().strip('"').strip("'")
    return d


def run(args, mask=()):
    r = subprocess.run(args, capture_output=True, text=True, errors="replace")
    out = (r.stdout or "") + (r.stderr or "")
    for m in mask:
        if m:
            out = out.replace(m, "********")
    return r.returncode, out


def main():
    try:
        sys.stdout.reconfigure(encoding="utf-8", errors="replace")
    except Exception:
        pass
    target, script = sys.argv[1], sys.argv[2]
    root = "--root" in sys.argv
    c = creds()
    vmx = VM[target]
    is_py = script.lower().endswith(".py")
    is_win = target == "win"
    user = c.get("windows_user" if is_win else "linux_user", "")
    pwd = c.get("windows_pass" if is_win else "linux_pass", "")
    mask = [pwd]
    tmp = tempfile.mkdtemp()
    ext = ".ps1" if is_win else (".py" if is_py else ".sh")
    host_script = os.path.join(tmp, "task" + ext)
    body = open(script, encoding="utf-8").read()
    # sustituir placeholders {{CLAVE}} por valores de la boveda (nunca se imprimen)
    vault_file = os.path.join(BASE, ".vault", "vault.json")
    if os.path.exists(vault_file):
        import json as _json
        for k, v in _json.load(open(vault_file, encoding="utf-8")).items():
            body = body.replace("{{" + k.upper() + "}}", str(v))
            if isinstance(v, str) and len(v) >= 6:
                mask.append(v)
    if root and not is_win:
        prologue = (
            "umask 077\n"
            "cat > /tmp/.p <<'__PWEOF__'\n" + pwd + "\n__PWEOF__\n"
            "cat > /tmp/.askpass <<'__ASEOF__'\n#!/bin/sh\ncat /tmp/.p\n__ASEOF__\n"
            "chmod 600 /tmp/.p\n"
            "chmod 700 /tmp/.askpass\n"
            "trap 'rm -f /tmp/.p /tmp/.askpass' EXIT\n"
            "export SUDO_ASKPASS=/tmp/.askpass\n"
            "sudo() { command sudo -A \"$@\"; }\n"
        )
        body = prologue + body
    with open(host_script, "w", encoding="utf-8", newline="\n") as f:
        f.write(body)
    if is_win:
        host_script = host_script.replace("\n", "\r\n") if False else host_script
    gpath = ("C:\\Windows\\Temp\\task.ps1" if is_win else ("/tmp/task.py" if is_py else "/tmp/task.sh"))
    gpath_out = ("C:\\Windows\\Temp\\out.txt" if is_win else "/tmp/out.txt")
    host_out = os.path.join(tmp, "out.txt")

    rc, out = run([VMRUN, "-T", "ws", "-gu", user, "-gp", pwd,
                   "copyFileFromHostToGuest", vmx, host_script, gpath], mask)
    if rc != 0:
        print("ERROR copy-in:", out)
        return 1
    if is_win:
        prog = ["-interactive", r"C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe",
                "-NoProfile", "-ExecutionPolicy", "Bypass", "-File", gpath]
    elif is_py:
        prog = ["/bin/bash", "-c", "python3 " + gpath + " > /tmp/out.txt 2>&1"]
    else:
        prog = ["/bin/bash", gpath]
    rc, out = run([VMRUN, "-T", "ws", "-gu", user, "-gp", pwd, "runProgramInGuest", vmx] + prog, mask)
    if out.strip():
        print(out.strip())
    rc2, out2 = run([VMRUN, "-T", "ws", "-gu", user, "-gp", pwd,
                    "copyFileFromGuestToHost", vmx, gpath_out, host_out], mask)
    if rc2 == 0 and os.path.exists(host_out):
        txt = open(host_out, encoding="utf-8", errors="replace").read()
        for m in mask:
            txt = txt.replace(m, "********")
        print(txt)
    if rc != 0:
        print("ERROR run (codigo %d)" % rc)
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
