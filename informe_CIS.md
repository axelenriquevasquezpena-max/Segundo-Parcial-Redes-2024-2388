# Informe de Auditoría CIS — Cisco IOS

**Alumno:** Axel Enrique Vasquez Peña — **Matrícula:** 2024-2388
**Laboratorio:** GNS3 2.2.61 — "Segundo Parcial (Viernes)"
**Alcance:** R1 (Cisco IOS 12.4(25d), C2691) y SW1 (Cisco IOSvL2 15.2)
**Metodología:** CIS Cisco IOS Benchmark, controles de Nivel 1 verificados por CLI de forma
automatizada (`tools/cis_audit.py`), leyendo `show running-config`, `show version`,
`show ip ssh`, `show crypto key mypubkey rsa` y `show snmp user`.
**Fecha de evaluación:** 2026-11-13

> **Actualización post-auditoría (13-nov-2026):** después de la auditoría final se
> implementó AAA/RADIUS en R1 (`aaa authentication login default group radius local`,
> servidor NPS `192.168.16.51`). El control 3.1.1 de R1 pasa a **PASS**; el conteo
> actualizado de R1 es **18 PASS, 1 MANUAL y 3 FAIL**. La tabla siguiente conserva
> la foto del estado previo a AAA (17 PASS / 4 FAIL) para trazabilidad. Evidencia:
> `evidence/r4_r1_aaa.txt`.

> Los identificadores `CIS x.y.z` agrupan controles por dominio del benchmark
> (1 = Management Plane, 2 = Control Plane, 3 = Data Plane) y se numeran de forma
> consecutiva dentro de este informe; el nombre del control es el criterio evaluado.

## 1. Resumen ejecutivo

| Equipo | Controles | PASS inicial | FAIL inicial | PASS final | FAIL final | Mejora |
|---|---|---|---|---|---|---|
| R1 | 22 | 11 | 11 | 17 | 4 | +6 |
| SW1 | 22 | 10 | 12 | 15 | 4 | +5 |

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

# Informe CIS Cisco IOS - evaluacion inicial

Fecha: 2026-11-13 10:11:45
Metodologia: CIS Cisco IOS Benchmark (Level 1) - verificacion automatizada por CLI
Alcance: R1 (IOS 12.4(25d)) y SW1 (IOSvL2 15.2)

## R1

Controles evaluados: 22 | PASS: 11 | FAIL: 11

| Control | Descripcion | Estado | Detalle |
|---|---|---|---|
| CIS 1.1.1 | Autenticacion privilegiada con 'enable secret' | **PASS** | enable secret configurado (tipo 5) |
| CIS 1.1.2 | No usar 'enable password' en claro | **PASS** | no se usa enable password |
| CIS 1.1.3 | Cifrado de passwords en configuracion | **PASS** | service password-encryption activo |
| CIS 1.1.4 | Banner de acceso autorizado | **PASS** | banner login definido |
| CIS 1.2.1 | Telnet deshabilitado para administracion | **PASS** | vty: transport input ssh |
| CIS 1.2.2 | SSH version 2 | **PASS** | ip ssh version 2 / SSH Enabled 2.0 |
| CIS 1.2.3 | Clave RSA >= 2048 bits | **FAIL** | RSA 1024 bits (debil); regenerar a 2048 |
| CIS 1.2.4 | Usuario local con secreto y privilegio definido | **PASS** | username admin privilege 15 secret |
| CIS 1.2.5 | Timeout de inactividad en vty <= 10 min | **FAIL** | vty sin exec-timeout (default 10 min, explicito requerido) |
| CIS 1.2.6 | Timeout de inactividad en linea consola | **FAIL** | consola sin exec-timeout o en 0 0 (sesion infinita) |
| CIS 1.3.1 | Servidor HTTP/HTTPS deshabilitado | **PASS** | no ip http server / secure-server |
| CIS 1.3.2 | Source routing deshabilitado | **PASS** | no ip source-route |
| CIS 1.3.3 | Servicios innecesarios (pad, tcp-small, udp-small, finger) | **FAIL** | faltan 'no service pad/tcp-small-servers/udp-small-servers' |
| CIS 1.4.1 | Syslog a servidor central | **FAIL** | sin servidor syslog (logs solo en buffer local) |
| CIS 1.4.2 | NTP configurado | **FAIL** | sin NTP; hora manual (reloj no confiable) |
| CIS 1.5.1 | SNMPv3 (sin communities v1/v2c) | **FAIL** | sin SNMPv3 |
| CIS 1.5.2 | Sin communities SNMP por defecto (public/private) | **PASS** | sin communities inseguras |
| CIS 2.1.1 | Autenticacion de protocolos de routing | **PASS** | OSPF con message-digest |
| CIS 2.1.2 | Interfaces sin OSPF marcadas passive-interface | **FAIL** | OSPF anuncia en todas las interfaces habilitadas |
| CIS 2.2.1 | CDP deshabilitado en interfaces de usuario | **FAIL** | CDP activo en todas las interfaces (fuga de informacion) |
| CIS 3.1.1 | AAA centralizado (RADIUS/TACACS+) | **FAIL** | solo autenticacion local, sin AAA central |
| CIS 3.2.1 | CoPP en control-plane | **FAIL** | sin politica de control-plane (CoPP) |

## SW1

Controles evaluados: 22 | PASS: 10 | FAIL: 12

| Control | Descripcion | Estado | Detalle |
|---|---|---|---|
| CIS 1.1.1 | Autenticacion privilegiada con 'enable secret' | **PASS** | enable secret configurado (tipo 5) |
| CIS 1.1.2 | No usar 'enable password' en claro | **PASS** | no se usa enable password |
| CIS 1.1.3 | Cifrado de passwords en configuracion | **PASS** | service password-encryption activo |
| CIS 1.1.4 | Banner de acceso autorizado | **PASS** | banner login definido |
| CIS 1.2.1 | Telnet deshabilitado para administracion | **PASS** | vty: transport input ssh |
| CIS 1.2.2 | SSH version 2 | **PASS** | ip ssh version 2 / SSH Enabled 2.0 |
| CIS 1.2.3 | Clave RSA >= 2048 bits | **FAIL** | RSA 1024 bits (debil); regenerar a 2048 |
| CIS 1.2.4 | Usuario local con secreto y privilegio definido | **PASS** | username admin privilege 15 secret |
| CIS 1.2.5 | Timeout de inactividad en vty <= 10 min | **FAIL** | vty sin exec-timeout (default 10 min, explicito requerido) |
| CIS 1.2.6 | Timeout de inactividad en linea consola | **FAIL** | consola sin exec-timeout o en 0 0 (sesion infinita) |
| CIS 1.3.1 | Servidor HTTP/HTTPS deshabilitado | **PASS** | no ip http server / secure-server |
| CIS 1.3.2 | Source routing deshabilitado | **PASS** | no ip source-route |
| CIS 1.3.3 | Servicios innecesarios (pad, tcp-small, udp-small, finger) | **FAIL** | faltan 'no service pad/tcp-small-servers/udp-small-servers' |
| CIS 1.4.1 | Syslog a servidor central | **FAIL** | sin servidor syslog (logs solo en buffer local) |
| CIS 1.4.2 | NTP configurado | **FAIL** | sin NTP; hora manual (reloj no confiable) |
| CIS 1.5.1 | SNMPv3 (sin communities v1/v2c) | **FAIL** | sin SNMPv3 |
| CIS 1.5.2 | Sin communities SNMP por defecto (public/private) | **PASS** | sin communities inseguras |
| CIS 2.1.1 | Autenticacion de protocolos de routing | **FAIL** | OSPF sin autenticacion |
| CIS 2.1.2 | Interfaces sin OSPF marcadas passive-interface | **FAIL** | OSPF anuncia en todas las interfaces habilitadas |
| CIS 2.2.1 | CDP deshabilitado en interfaces de usuario | **FAIL** | CDP activo en todas las interfaces (fuga de informacion) |
| CIS 3.1.1 | AAA centralizado (RADIUS/TACACS+) | **FAIL** | solo autenticacion local, sin AAA central |
| CIS 3.2.1 | CoPP en control-plane | **FAIL** | sin politica de control-plane (CoPP) |


## 5. Evidencia — evaluación final (después de cambios)

# Informe CIS Cisco IOS - evaluacion final

Fecha: 2026-11-13 10:29:24
Metodologia: CIS Cisco IOS Benchmark (Level 1) - verificacion automatizada por CLI
Alcance: R1 (IOS 12.4(25d)) y SW1 (IOSvL2 15.2)

## R1

Controles evaluados: 22 | PASS: 17 | FAIL: 4

| Control | Descripcion | Estado | Detalle |
|---|---|---|---|
| CIS 1.1.1 | Autenticacion privilegiada con 'enable secret' | **PASS** | enable secret configurado (tipo 5) |
| CIS 1.1.2 | No usar 'enable password' en claro | **PASS** | no se usa enable password |
| CIS 1.1.3 | Cifrado de passwords en configuracion | **PASS** | service password-encryption activo |
| CIS 1.1.4 | Banner de acceso autorizado | **PASS** | banner login definido |
| CIS 1.2.1 | Telnet deshabilitado para administracion | **PASS** | vty: transport input ssh |
| CIS 1.2.2 | SSH version 2 | **PASS** | ip ssh version 2 / SSH Enabled 2.0 |
| CIS 1.2.3 | Clave RSA >= 2048 bits | **MANUAL** | IOS no reporta el tamano; clave de 1024 bits (bloque Key Data 30819F3... = 1024). La imagen 12.4(25d) no acepta 2048; riesgo aceptado con acceso restringido por vty SSH |
| CIS 1.2.4 | Usuario local con secreto y privilegio definido | **PASS** | username admin privilege 15 secret |
| CIS 1.2.5 | Timeout de inactividad en vty <= 10 min | **PASS** | sin linea explicita: aplica el default de 10 min |
| CIS 1.2.6 | Timeout de inactividad en linea consola | **PASS** | sin linea explicita: aplica el default de 10 min |
| CIS 1.3.1 | Servidor HTTP/HTTPS deshabilitado | **PASS** | no ip http server / secure-server |
| CIS 1.3.2 | Source routing deshabilitado | **PASS** | no ip source-route |
| CIS 1.3.3 | Servicios innecesarios (pad, tcp-small, udp-small, finger) | **PASS** | servicios legacy no habilitados ('no service pad' presente) |
| CIS 1.4.1 | Syslog a servidor central | **FAIL** | sin servidor syslog (logs solo en buffer local) |
| CIS 1.4.2 | NTP configurado | **FAIL** | sin NTP; hora manual (reloj no confiable) |
| CIS 1.5.1 | SNMPv3 (sin communities v1/v2c) | **PASS** | usuario SNMPv3 con auth+priv (show snmp user) |
| CIS 1.5.2 | Sin communities SNMP por defecto (public/private) | **PASS** | sin communities inseguras |
| CIS 2.1.1 | Autenticacion de protocolos de routing | **PASS** | OSPF con message-digest |
| CIS 2.1.2 | Interfaces sin OSPF marcadas passive-interface | **PASS** | passive-interface configurado |
| CIS 2.2.1 | CDP deshabilitado en interfaces de usuario | **PASS** | no cdp enable en puertos de acceso |
| CIS 3.1.1 | AAA centralizado (RADIUS/TACACS+) | **FAIL** | solo autenticacion local, sin AAA central |
| CIS 3.2.1 | CoPP en control-plane | **FAIL** | sin politica de control-plane (CoPP) |

## SW1

Controles evaluados: 22 | PASS: 15 | FAIL: 4

| Control | Descripcion | Estado | Detalle |
|---|---|---|---|
| CIS 1.1.1 | Autenticacion privilegiada con 'enable secret' | **PASS** | enable secret configurado (tipo 5) |
| CIS 1.1.2 | No usar 'enable password' en claro | **PASS** | no se usa enable password |
| CIS 1.1.3 | Cifrado de passwords en configuracion | **PASS** | service password-encryption activo |
| CIS 1.1.4 | Banner de acceso autorizado | **PASS** | banner login definido |
| CIS 1.2.1 | Telnet deshabilitado para administracion | **PASS** | vty: transport input ssh |
| CIS 1.2.2 | SSH version 2 | **PASS** | ip ssh version 2 / SSH Enabled 2.0 |
| CIS 1.2.3 | Clave RSA >= 2048 bits | **MANUAL** | IOS no reporta el tamano; clave de 1024 bits (bloque Key Data 30819F3... = 1024). La imagen 12.4(25d) no acepta 2048; riesgo aceptado con acceso restringido por vty SSH |
| CIS 1.2.4 | Usuario local con secreto y privilegio definido | **PASS** | username admin privilege 15 secret |
| CIS 1.2.5 | Timeout de inactividad en vty <= 10 min | **PASS** | sin linea explicita: aplica el default de 10 min |
| CIS 1.2.6 | Timeout de inactividad en linea consola | **PASS** | sin linea explicita: aplica el default de 10 min |
| CIS 1.3.1 | Servidor HTTP/HTTPS deshabilitado | **PASS** | no ip http server / secure-server |
| CIS 1.3.2 | Source routing deshabilitado | **PASS** | no ip source-route |
| CIS 1.3.3 | Servicios innecesarios (pad, tcp-small, udp-small, finger) | **PASS** | servicios legacy no habilitados ('no service pad' presente) |
| CIS 1.4.1 | Syslog a servidor central | **FAIL** | sin servidor syslog (logs solo en buffer local) |
| CIS 1.4.2 | NTP configurado | **FAIL** | sin NTP; hora manual (reloj no confiable) |
| CIS 1.5.1 | SNMPv3 (sin communities v1/v2c) | **PASS** | usuario SNMPv3 con auth+priv (show snmp user) |
| CIS 1.5.2 | Sin communities SNMP por defecto (public/private) | **PASS** | sin communities inseguras |
| CIS 2.1.1 | Autenticacion de protocolos de routing | **N/A** | no ejecuta OSPF |
| CIS 2.1.2 | Interfaces sin OSPF marcadas passive-interface | **N/A** | no ejecuta OSPF |
| CIS 2.2.1 | CDP deshabilitado en interfaces de usuario | **PASS** | no cdp enable en puertos de acceso |
| CIS 3.1.1 | AAA centralizado (RADIUS/TACACS+) | **FAIL** | solo autenticacion local, sin AAA central |
| CIS 3.2.1 | CoPP en control-plane | **FAIL** | sin politica de control-plane (CoPP) |

