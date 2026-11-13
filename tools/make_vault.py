"""Create the local secret vault (.vault/vault.json) with strong random passwords.
Nothing is printed; secrets never go into PROGRESO.md or the repo (.gitignore)."""
import json
import os
import secrets
import string

BASE = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
VAULT = os.path.join(BASE, ".vault", "vault.json")


def gen(n=18):
    alpha = string.ascii_letters + string.digits + "!@#%^*-_+="
    while True:
        p = "".join(secrets.choice(alpha) for _ in range(n))
        if (any(c.islower() for c in p) and any(c.isupper() for c in p)
                and any(c.isdigit() for c in p) and any(c in "!@#%^*-_+=" for c in p)):
            return p


os.makedirs(os.path.dirname(VAULT), exist_ok=True)
data = {}
if os.path.exists(VAULT):
    with open(VAULT, encoding="utf-8") as f:
        data = json.load(f)
for k in ("admin_ssh", "enable_secret"):
    data.setdefault(k, gen())
with open(VAULT, "w", encoding="utf-8") as f:
    json.dump(data, f, indent=2)
os.chmod(VAULT, 0o600)
print("vault listo:", VAULT, "| claves:", ", ".join(sorted(data)))
