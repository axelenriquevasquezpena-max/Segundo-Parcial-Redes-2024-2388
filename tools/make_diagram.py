"""Genera docs/topologia.svg a partir del archivo .gns3 real del proyecto."""
import json
import os

BASE = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
GNS3 = r"C:\Users\axele\GNS3\projects\Segundo Parcial (Viernes)\Segundo Parcial (Viernes).gns3"
OUT = os.path.join(BASE, "docs", "topologia.svg")
os.makedirs(os.path.dirname(OUT), exist_ok=True)

proj = json.load(open(GNS3, encoding="utf-8"))
nodes = {n["node_id"]: n for n in proj["topology"]["nodes"]}
links = proj["topology"]["links"]

IP = {
    "R1": ["f0/0 192.168.16.1/24", "f0/1 10.16.0.1/30"],
    "R2": ["f0/0 10.16.0.2/30", "Lo0 2.2.2.2/32"],
    "CiscoIOSvL215.2(20200924:215240)-1": ["Vlan1 192.168.16.2/24"],
    "WindowsServer2022-2": ["192.168.16.51 (DHCP)"],
    "DB-P2-1": ["192.168.16.50 (DHCP)"],
    "KaliLinux-1": ["Zabbix / DHCP"],
}
COLOR = {"dynamips": "#1f6feb", "qemu": "#8250df", "vmware": "#0a7d4f"}
LABEL = {"R1": "R1 (C2691)", "R2": "R2 (C2691)",
         "CiscoIOSvL215.2(20200924:215240)-1": "SW1 (IOSvL2)",
         "WindowsServer2022-2": "Windows Server 2022\nAD DS + NPS",
         "DB-P2-1": "DB-P2\n(Linux)", "KaliLinux-1": "Kali Linux\nZabbix"}

xs = [n["x"] for n in nodes.values()]
ys = [n["y"] for n in nodes.values()]
minx, maxx, miny, maxy = min(xs), max(xs), min(ys), max(ys)
W, H, M = 1100, 620, 110


def px(x):
    return M + (x - minx) / (maxx - minx or 1) * (W - 2 * M)


def py(y):
    return M + (y - miny) / (maxy - miny or 1) * (H - 2 * M - 40)


parts = [
    f'<svg xmlns="http://www.w3.org/2000/svg" width="{W}" height="{H}" viewBox="0 0 {W} {H}" font-family="Segoe UI,Arial,sans-serif">',
    f'<rect width="{W}" height="{H}" fill="#ffffff"/>',
    '<text x="24" y="34" font-size="20" font-weight="700" fill="#111">Segundo Parcial de Redes — Topología (GNS3 2.2.61)</text>',
    '<text x="24" y="56" font-size="12" fill="#555">Axel Enrique Vasquez Peña — 2024-2388 · generado desde el proyecto .gns3</text>',
]
# links
for l in links:
    a, b = l["nodes"]
    na, nb = nodes[a["node_id"]], nodes[b["node_id"]]
    x1, y1, x2, y2 = px(na["x"]), py(na["y"]), px(nb["x"]), py(nb["y"])
    parts.append(f'<line x1="{x1:.0f}" y1="{y1:.0f}" x2="{x2:.0f}" y2="{y2:.0f}" stroke="#333" stroke-width="2.5"/>')
    mx, my = (x1 + x2) / 2, (y1 + y2) / 2
    ia = a.get("label", {}).get("text", "")
    ib = b.get("label", {}).get("text", "")
    parts.append(f'<text x="{mx:.0f}" y="{my - 6:.0f}" font-size="10" fill="#666" text-anchor="middle">{ia} — {ib}</text>')
# nodes
for n in nodes.values():
    x, y = px(n["x"]), py(n["y"])
    c = COLOR.get(n["node_type"], "#666")
    w = 150 if n["node_type"] != "dynamips" else 120
    parts.append(f'<rect x="{x - w/2:.0f}" y="{y - 26:.0f}" width="{w}" height="52" rx="10" fill="#fff" stroke="{c}" stroke-width="2.5"/>')
    txt = LABEL.get(n["name"], n["name"])
    first = txt.split("\n")[0]
    parts.append(f'<text x="{x:.0f}" y="{y - 4:.0f}" font-size="12.5" font-weight="700" fill="#111" text-anchor="middle">{first}</text>')
    for i, line in enumerate(IP.get(n["name"], [])):
        parts.append(f'<text x="{x:.0f}" y="{y + 14 + i*13:.0f}" font-size="10" fill="#444" text-anchor="middle">{line}</text>')
    if "\n" in txt:
        parts.append(f'<text x="{x:.0f}" y="{y + 42:.0f}" font-size="10" fill="#0a7d4f" text-anchor="middle">{txt.split(chr(10))[1]}</text>')

parts += [
    '<text x="24" y="585" font-size="11" fill="#555">LAN: 192.168.16.0/24 (gw .1) · Enlace WAN: 10.16.0.0/30 · OSPF 1 area 0 con MD5</text>',
    '<text x="24" y="602" font-size="11" fill="#555">Azul = Dynamips IOS · Violeta = IOSvL2 (QEMU) · Verde = VM VMware Workstation</text>',
    '</svg>',
]
open(OUT, "w", encoding="utf-8").write("\n".join(parts))
print("generado:", OUT)
