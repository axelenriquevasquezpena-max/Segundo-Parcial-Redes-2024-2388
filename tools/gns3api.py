"""Minimal GNS3 API client. Credentials are read from the local GNS3 server ini
at runtime; nothing secret is stored in this file."""
import configparser
import json
import os
import sys
import urllib.request
import urllib.error
import base64

INI = os.path.expandvars(r"%APPDATA%\GNS3\2.2\gns3_server.ini")
BASE = "http://127.0.0.1:3080/v2"


def _auth():
    cp = configparser.ConfigParser()
    cp.read(INI, encoding="utf-8")
    user = cp.get("Server", "user", fallback="admin")
    pwd = cp.get("Server", "password", fallback="")
    tok = base64.b64encode(f"{user}:{pwd}".encode()).decode()
    return {"Authorization": f"Basic {tok}"}


def call(method, path, body=None, timeout=60):
    url = BASE + path
    data = json.dumps(body).encode() if body is not None else None
    req = urllib.request.Request(url, data=data, method=method, headers=_auth())
    if data:
        req.add_header("Content-Type", "application/json")
    try:
        with urllib.request.urlopen(req, timeout=timeout) as r:
            raw = r.read().decode("utf-8", "replace")
            return json.loads(raw) if raw.strip().startswith(("{", "[")) else raw
    except urllib.error.HTTPError as e:
        return {"_http_error": e.code, "_body": e.read().decode("utf-8", "replace")}


if __name__ == "__main__":
    method = sys.argv[1]
    path = sys.argv[2]
    body = json.loads(sys.argv[3]) if len(sys.argv) > 3 else None
    print(json.dumps(call(method, path, body), indent=2))
