"""Ensambla informe_CIS.md (inicial + final) a partir de las evidencias generadas."""
import os
import re

BASE = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
EVID = os.path.join(BASE, "evidence")


def load(name):
    with open(os.path.join(EVID, name), encoding="utf-8") as f:
        return f.read()


ini, fin = load("cis_inicial.md"), load("cis_final.md")


def summary(md):
    out = {}
    for dev in ("R1", "SW1"):
        blk = md.split("## " + dev)[1].split("## ")[0]
        m = re.search(r"PASS: (\d+) \| FAIL: (\d+)", blk)
        out[dev] = (int(m.group(1)), int(m.group(2)))
    return out


si, sf = summary(ini), summary(fin)
head = f"""# Informe de Auditoría CIS — Cisco IOS

**Alumno:** Axel Enrique Vasquez Peña — **Matrícula:** 2024-2388
**Laboratorio:** GNS3 2.2.61 — "Segundo Parcial (Viernes)"
**Alcance:** R1 (Cisco IOS 12.4(25d), C2691) y SW1 (Cisco IOSvL2 15.2)
**Metodología:** CIS Cisco IOS Benchmark, controles de Nivel 1 verificados por CLI de forma
automatizada (`tools/cis_audit.py`), leyendo `show running-config`, `show version`,
`show ip ssh`, `show crypto key mypubkey rsa` y `show snmp user`.
**Fecha de evaluación:** 2026-11-13

> Los identificadores `CIS x.y.z` agrupan controles por dominio del benchmark
> (1 = Management Plane, 2 = Control Plane, 3 = Data Plane) y se numeran de forma
> consecutiva dentro de este informe; el nombre del control es el criterio evaluado.

## 1. Resumen ejecutivo

| Equipo | Controles | PASS inicial | FAIL inicial | PASS final | FAIL final | Mejora |
|---|---|---|---|---|---|---|
| R1 | 22 | {si['R1'][0]} | {si['R1'][1]} | {sf['R1'][0]} | {sf['R1'][1]} | +{sf['R1'][0]-si['R1'][0]} |
| SW1 | 22 | {si['SW1'][0]} | {si['SW1'][1]} | {sf['SW1'][0]} | {sf['SW1'][1]} | +{sf['SW1'][0]-si['SW1'][0]} |

(Además: 1 control MANUAL por equipo — tamaño de clave RSA — y 2 N/A en SW1 por no ejecutar OSPF.)

**Hallazgos críticos corregidos:** Telnet abierto en vty, ausencia de usuario local con secreto,
ausencia de `enable secret`, HTTP de administración habilitado, `exec-timeout 0 0` en consola,
source-routing habilitado, CDP expuesto en puertos de usuarios, OSPF sin autenticación,
ausencia de `passive-interface`, servicios legacy.

## 2. Remediaciones aplicadas

| Control | Remediación | Archivo |
|---|---|---|
| 1.1.1 / 1.1.3 | `enable secret` tipo 5 + `service password-encryption` | `configs/r1_ssh.cfg`, `r2_ssh.cfg`, `sw1_ssh.cfg` |
| 1.2.1 / 1.2.2 | `ip ssh version 2`, vty `login local` + `transport input ssh` | idem |
| 1.2.4 | `username admin privilege 15 secret` | idem |
| 1.2.6 | consola con `exec-timeout 10 0` | `configs/r1_cis.cfg`, `sw1_cis.cfg` |
| 1.3.1 | `no ip http server` / `no ip http secure-server` | `configs/*_ssh.cfg` |
| 1.3.2 | `no ip source-route` | idem |
| 1.3.3 | `no service pad`, keepalives TCP | `configs/*_cis.cfg` |
| 1.5.1 | SNMPv3 `auth sha` + `priv` (AES128 en SW1, DES en R1 por límite de imagen) | `configs/r1_snmp.cfg`, `sw1_snmp.cfg` |
| 2.1.1 | OSPF con `message-digest` MD5 en R1 y R2 | `configs/r2_base_ospf.cfg` |
| 2.1.2 | `passive-interface FastEthernet0/0` | `configs/r1_cis.cfg` |
| 2.2.1 | `no cdp enable` en puertos de usuario | `configs/r1_cis.cfg`, `sw1_cis.cfg` |

## 3. Hallazgos abiertos (con justificación)

| Control | Estado | Motivo / riesgo aceptado |
|---|---|---|
| 1.4.1 Syslog central | Abierto | El laboratorio está aislado y aún no existe colector syslog; se mitiga con `logging buffered 16384` y `no logging console`. Se resolverá apuntando a Zabbix/Kali si se habilita rsyslog. |
| 1.4.2 NTP | Abierto | No hay servidor NTP alcanzable en el segmento aislado; se ajustó el reloj manualmente a UTC (13-nov-2026) y se documenta como control compensatorio. |
| 3.1.1 AAA central | Abierto | Depende de R4 (Windows Server 2022 + NPS). El diseño ya prevé `aaa authentication login default group radius local` con fallback local. |
| 3.2.1 CoPP | Abierto | La imagen IOS 12.4(25d) del C2691 no soporta políticas de control-plane; SW1 (15.2) sí podría, queda como mejora. |
| 1.2.3 RSA 2048 | Manual / riesgo aceptado | La imagen 12.4(25d) genera 1024 bits y rechaza 2048; el acceso está limitado a SSHv2 con usuario local. |

## 4. Evidencia — evaluación inicial (antes de cambios)

{ini}

## 5. Evidencia — evaluación final (después de cambios)

{fin}
"""
with open(os.path.join(BASE, "informe_CIS.md"), "w", encoding="utf-8") as f:
    f.write(head)
print("generado: informe_CIS.md")
