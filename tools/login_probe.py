import json
import os
import sys

from netmiko import ConnectHandler

BASE = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
v = json.load(open(os.path.join(BASE, ".vault", "vault.json"), encoding="utf-8"))

combos = [
    ("admin", v.get("admin_ssh", "")),
    ("admin", v.get("enable_secret", "")),
    ("radius1", v.get("ad_user_pass", "")),
]
for user, pwd in combos:
    try:
        c = ConnectHandler(device_type="cisco_ios_telnet", host="192.168.6.128", port=5000,
                           username=user, password=pwd, secret=v["enable_secret"],
                           global_delay_factor=2, fast_cli=False)
        print("LOGIN OK con usuario:", user)
        c.disconnect()
        break
    except Exception as e:
        print("fallo con", user, "->", type(e).__name__)
