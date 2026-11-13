"""Ajusta el reloj de R1/R2/SW1 a la hora UTC real y muestra el resultado."""
import time
from cisco import connect

t = time.gmtime()
cmd = time.strftime("clock set %H:%M:%S %b %d %Y", t)
print("comando:", cmd)
for dev in ("R1", "R2", "SW"):
    c = connect(dev)
    c.enable()
    try:
        c.send_command_timing(cmd, read_timeout=30)
        print(dev, "->", c.send_command("show clock").strip())
    finally:
        c.disconnect()
