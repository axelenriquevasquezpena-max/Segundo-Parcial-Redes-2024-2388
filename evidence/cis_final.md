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
