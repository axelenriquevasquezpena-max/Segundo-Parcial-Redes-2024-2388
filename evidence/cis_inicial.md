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
