"""Back up running-config from all Cisco devices into backups/<timestamp>/."""
import os
import re
import time
from cisco import connect

BASE = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
STAMP = time.strftime("%Y%m%d-%H%M%S")
OUT = os.path.join(BASE, "backups", STAMP)
os.makedirs(OUT, exist_ok=True)

results = {}
for dev in ("R1", "R2", "SW"):
    try:
        c = connect(dev)
        c.enable()
        cfg = c.send_command("show running-config", read_timeout=120)
        c.disconnect()
        p = os.path.join(OUT, f"{dev}_running-config.txt")
        with open(p, "w", encoding="utf-8") as f:
            f.write(cfg)
        results[dev] = f"OK {len(cfg)} bytes -> {p}"
    except Exception as e:
        results[dev] = f"FAIL {type(e).__name__}: {e}"

print(f"backup dir: {OUT}")
for k, v in results.items():
    print(k, v)
