"""Console access helper for the GNS3 lab (no secrets stored here).
Usage: python cisco.py <R1|R2|SW> "<show command>" [...]"""
import json
import os
import sys
from netmiko import ConnectHandler

HOST = "192.168.6.128"
VAULT = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), ".vault", "vault.json")


def vault_secret():
    if os.path.exists(VAULT):
        with open(VAULT, encoding="utf-8") as f:
            return json.load(f).get("enable_secret", "")
    return ""
DEVICES = {
    "R1": {"port": 5000},
    "SW": {"port": 5001},
    "R2": {"port": 5003},
}


def connect(dev, secret=None):
    p = DEVICES[dev]
    username, password = "", ""
    if dev == "R1" and os.path.exists(VAULT):
        with open(VAULT, encoding="utf-8") as f:
            v = json.load(f)
        username, password = "radius1", v.get("ad_user_pass", "")
    params = dict(
        device_type="cisco_ios_telnet",
        host=HOST,
        port=p["port"],
        username=username,
        password=password,
        secret=secret if secret is not None else vault_secret(),
        global_delay_factor=2,
        fast_cli=False,
        session_log=None,
    )
    return ConnectHandler(**params)


def main():
    dev = sys.argv[1]
    cmds = sys.argv[2:] or ["show running-config"]
    conn = connect(dev)
    conn.enable()
    for c in cmds:
        print(f"===== {dev}$ {c} =====")
        try:
            print(conn.send_command(c, read_timeout=60))
        except Exception:
            # log messages (CDP/OSPF) can interleave on the console; fall back to timing
            print(conn.send_command_timing(c, read_timeout=90))
    conn.disconnect()


if __name__ == "__main__":
    main()
