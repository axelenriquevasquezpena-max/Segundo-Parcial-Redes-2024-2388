# PROGRESO — Segundo Parcial de Redes (GNS3)

> Archivo de continuidad. Cualquier agente debe leer esto **primero**.
> Alumno: **Axel Enrique Vasquez Peña** — Matrícula **2024-2388**
> Última actualización: 2026-11-13 11:55 (hora local, UTC-4)

---

## 1. Proyecto y ubicación

| Dato | Valor |
|---|---|
| Proyecto GNS3 | `C:\Users\axele\GNS3\projects\Segundo Parcial (Viernes)` |
| Archivo | `Segundo Parcial (Viernes).gns3` |
| Project ID | `410510cd-f24d-4ed2-9650-0d5b20aa76cc` |
| API | `http://127.0.0.1:3080` (v2, GNS3 2.2.61, HTTP Basic) |
| Consolas | `192.168.6.128:5000` (R1), `:5001` (SW1), `:5003` (R2) |
| Carpeta de trabajo | `C:\Users\axele\Documents\ParcialRedes` |
| Backup inicial | `backups\20261113-094650\` (R1, R2, SW running-config) |

Credenciales: **no se almacenan aquí**. La API las lee en runtime desde
`%APPDATA%\GNS3\2.2\gns3_server.ini`. Los secretos están en `.vault\vault.json`
(excluido por `.gitignore`). Claves existentes (solo nombres):
`admin_ssh`, `enable_secret`, `snmp_auth`, `snmp_priv`, `zabbix_db_pass`,
`dsrm_pass`, `ad_user_pass`, `radius_secret`, `windows_user`, `windows_pass`,
`linux_user`, `linux_pass`.

Estado tras el apagón: configuraciones de R1, R2 y SW1 **persistieron** en NVRAM
(`show ip interface brief` → todas `NVRAM up/up`).

---

## 2. Inventario y conexiones

| Nodo | Tipo | Imagen / VMX | Acceso |
|---|---|---|---|
| R1 | Dynamips c2691 | IOS 12.4(25d) advsecurityk9 | 192.168.6.128:5000 |
| R2 | Dynamips c2691 | IOS 12.4(25d) advsecurityk9 | 192.168.6.128:5003 |
| SW1 | QEMU IOSvL2 15.2 | vios_l2-adventerprisek9 | 192.168.6.128:5001 |
| DC01 (WindowsServer2022-2) | VMware | `C:\Virtual Machines\Windows Server 2022\Windows Server 2022.vmx` | WinRM 5985 (VMware Tools no operativo) |
| KaliLinux-1 | VMware | `C:\Virtual Machines\Kali Linux\Kali Linux.vmx` | VMware Tools / `guest.py` |
| DB-P2-1 | VMware | `C:\Virtual Machines\Laboratorio-OneDrive\DB-P2.vmx` | VMware |

| Enlace | A | B | Rol |
|---|---|---|---|
| 1 | R1 f0/0 | SW1 Gi0/0 | LAN 192.168.16.0/24 |
| 2 | R1 f0/1 | R2 f0/0 | WAN 10.16.0.0/30 |
| 3 | SW1 Gi0/1 | DB-P2 e0 | Servidor BD |
| 4 | SW1 Gi0/2 | Kali e0 | Cliente / Zabbix / RADIUS test |
| 5 | SW1 Gi0/3 | WindowsServer e0 | AD DS / DNS / NPS |

MACs: Windows `000c.29f7.e0b0` (.51), Kali `000c.2927.4516` (.52),
DB-P2 `000c.29a7.54de` (.50).

---

## 3. Direccionamiento vigente

| Segmento | Uso | Gateway |
|---|---|---|
| 192.168.16.0/24 | LAN servidores/clientes | 192.168.16.1 (R1) |
| 10.16.0.0/30 | Enlace R1–R2 | — |
| 192.168.16.1 | R1 f0/0 | — |
| 192.168.16.2 | SW1 Vlan1 (gestión) | 192.168.16.1 |
| 192.168.16.10-49 | Excluidas de DHCP | — |
| 192.168.16.50 | DB-P2 (DHCP) | .1 |
| 192.168.16.51 | DC01 Windows (estática, ex-reserva DHCP) | .1 |
| 192.168.16.52 | Kali (DHCP) / Zabbix Server | .1 |
| 10.16.0.1 / .2 | R1 f0/1 / R2 f0/0 | — |
| 2.2.2.2/32 | Loopback R2 (router-id OSPF) | — |

> Se respeta el esquema `16` existente; no se renumeró.

---

## 4. Estado de requisitos

| Req | Estado | Evidencia real |
|---|---|---|
| **R1 DHCP** | ✅ COMPLETO | `evidence\r1_dhcp_test.txt`: SW1 como cliente obtuvo .52 (DISCOVER/REQUEST/OFFER/ACK), clientes reales .50 DB-P2, .51 Windows (reserva manual), .52 Kali |
| **R2 OSPF** | ✅ COMPLETO | R1↔R2 FULL (1.1.1.1 / 2.2.2.2), MD5, rutas `O 192.168.16.0/24` y `O 2.2.2.2` |
| **R3 CIS** | ✅ COMPLETO | `informe_CIS.md`: 22 controles; R1 17 PASS/1 MANUAL/4 FAIL (18 PASS tras AAA); SW1 15 PASS/1 MANUAL/4 FAIL/2 N/A. Pendientes documentados: syslog, NTP y CoPP |
| **R4 AAA/RADIUS** | ✅ COMPLETO | `evidence\r4_ad_nps.txt`, `r4_radius_tests.txt`, `r4_r1_aaa.txt`, `r4_ssh_radius.txt`. AD DS `parcial.local`, NPS con clientes R1/SW1, Access-Accept y Access-Reject reales, SSH a R1 con usuario del dominio |
| **R5 GitHub** | ✅ COMPLETO | https://github.com/axelenriquevasquezpena-max/Segundo-Parcial-Redes-2024-2388 — README con evidencias, configs saneadas, informe CIS y diagrama |
| **R6 Direccionamiento** | ✅ COMPLETO | hostnames R1/R2/SW1; SW1 Vlan1 .2/24 + ruta por defecto; 4/4 pings; duplex corregido |
| **R7 SSH** | ✅ COMPLETO | `evidence\r7_ssh_test.txt`: login SSH real R2→R1; `transport input ssh`; SSHv2 |
| **R8 Zabbix/SNMP** | ✅ COMPLETO | `evidence\r8_snmpv3_kali.txt` y `r8_zabbix_hosts.txt`: Zabbix 7.0.29 en Kali, hosts R1/SW1 por SNMPv3 con métricas reales |

---

## 5. Cambios realizados (además de los de la fase inicial)

1. **Kali**: perfil `LAB-DHCP` en eth0 (IP .52, gw .1, DNS .51/8.8.8.8);
   perfil `NAT-INTERNET` en eth1 (métrica 50) solo para instalar paquetes.
2. **Kali/Zabbix**: instalado Zabbix 7.0.29 (server, frontend PHP, agente, MariaDB),
   base `zabbix` con 203 tablas (`dbversion 7000000`), frontend en
   `http://192.168.16.52/zabbix`, servidor y agente activos.
3. **Windows DC01**: zona horaria `SA Western Standard Time` (UTC-4), IP estática
   `192.168.16.51/24`, DNS 127.0.0.1, renombrado a **DC01**, roles AD DS + DNS + NPS.
4. **AD DS**: bosque **parcial.local** (NetBIOS PARCIAL), DNS integrado; OU
   `Laboratorio` con `Usuarios`, `Grupos`, `Equipos`; grupos
   `GRP-Administradores-TI` (vasquez) y `GRP-Usuarios-RADIUS` (radius1);
   usuarios `vasquez` y `radius1` con `msNPAllowDialin = True`.
5. **NPS/RADIUS**: servicio IAS automático, clientes `R1 192.168.16.1`,
   `SW1 192.168.16.2` y `KALI-TEST 192.168.16.52`; regla de firewall
   **solo** UDP 1812/1813 desde `192.168.16.0/24`; auditoría NPS activa.
6. **NPS política**: la política por defecto no permitía PAP (motivo 66). Se
   agregó el tipo de autenticación PAP (1) al perfil de la política
   `Connections to other access servers` editando el XML exportado y
   reimportando con `netsh nps import`.
7. **R1 AAA**: `aaa new-model`, `radius-server host 192.168.16.51` (1812/1813,
   retransmit 2, timeout 5, deadtime 1), `ip radius source-interface f0/0`,
   `aaa authentication login default group radius local` y VTY/consola con
   `login authentication default`. Se guardó con `write memory`.

Todos los cambios se guardaron (`write memory` / configuración persistente).

---

## 6. Comandos y resultados de verificación (R4 y R8)

```
# RADIUS desde Kali (radtest)
radius1@parcial.local + password correcta -> Received Access-Accept
radius1@parcial.local + password errónea  -> Received Access-Reject
noexiste@parcial.local                    -> Received Access-Reject

# R1 (AAA)
show aaa servers        -> RADIUS host 192.168.16.51:1812/1813, State current UP
test aaa group radius radius1 *** new-code -> User successfully authenticated
SSH radius1@192.168.16.1 -> banner + show clock (login correcto por dominio)
SSH radius1 con password errónea / usuario inexistente -> Permission denied

# NPS
Get-NpsRadiusClient     -> R1 .1, SW1 .2, KALI-TEST .52 (Enabled True)
Get-NetUDPEndpoint 1812 -> escucha en 192.168.16.51 y loopback IPv6
netsh nps show np       -> NP-Authentication-Type incluye 0x1 (PAP)
Evento 6273 (prueba negativa) -> Reason Code 66 antes del ajuste; luego Reject por credenciales

# Zabbix
sysDescr/sysName/sysUpTime de R1 y SW1 con estado=0 y fecha real
R1: sysUpTime=123494, SW1: sysUpTime=120992 (timeticks)
```

---

## 7. Errores encontrados y soluciones (fase R4/R8)

| Error | Causa | Solución |
|---|---|---|
| `vmrun checkToolsState` = `unknown` | VMware Tools no instalado en Windows | Administración por **WinRM 5985** con `netexec` desde Kali |
| Zabbix API: `Config file does not exist` | El paquete espera `/etc/zabbix/zabbix.conf.php`, no `/etc/zabbix/web/...` | Config en la ruta correcta y formato `$DB[...]` |
| NPS sin respuesta a radtest | Cliente RADIUS no recargado / falta regla de firewall | Reiniciar IAS y regla UDP 1812/1813 acotada a la LAN |
| Access-Reject con motivo 66 | Política sin PAP | Agregar `msNPAuthenticationType2 = 1` al perfil y reimportar XML |
| `netsh nps set np ... profiledata` alteró los tipos | sintaxis no documentada para listas | Editar XML exportado e importar |
| Consola IOS pedía login tras `aaa new-model` | Lista por defecto aplica a console/VTY | Acceso con usuario de dominio `radius1`; `admin` local como respaldo si NPS no responde |
| `login local` rechazado en 12.4(25d) | variante de IOS | Se usó `login authentication default` en `line con 0` |
| SSH desde Kali: “no matching key exchange” | R1 solo ofrece `diffie-hellman-group1-sha1` | `-oKexAlgorithms=+diffie-hellman-group1-sha1` |
| `netsh nps show client` vacío tras `add client` | orden/quoting de parámetros | Usar `New-NpsRadiusClient` |

---

## 8. Evidencias y archivos

```
evidence\
├─ r1_dhcp_test.txt
├─ r7_ssh_test.txt
├─ cis_inicial.md / cis_final.md
├─ health_check.txt
├─ r4_ad_nps.txt          (dominio, OU, usuarios, grupos, DNS, NPS, firewall)
├─ r4_radius_tests.txt    (Access-Accept / Access-Reject)
├─ r4_r1_aaa.txt          (configuración AAA y test aaa; clave tipo 7 redactada)
├─ r4_ssh_radius.txt      (SSH con usuario del dominio y rechazo)
├─ r8_snmpv3_kali.txt     (snmpwalk/snmpget reales)
└─ r8_zabbix_hosts.txt    (hosts y métricas en Zabbix)
```

Herramientas nuevas: `tools\guest.py` (ejecuta scripts en Kali/Windows vía
VMware), `tools\winps.py` (PowerShell remoto por WinRM),
`tools\win_evidence.py`, `tools\r1_aaa.py`, `tools\ui.ps1`.

---

## 9. Próximos pasos exactos

1. **R3**: los pendientes (syslog centralizado, NTP cliente y CoPP) quedan
   documentados en `informe_CIS.md`; no se aplicaron para no modificar las
   configuraciones ya verificadas.
2. **R5**: repositorio publicado en
   https://github.com/axelenriquevasquezpena-max/Segundo-Parcial-Redes-2024-2388
   con README, evidencias, configuraciones saneadas, informe CIS y diagrama.
3. **Video**: grabación privada de 8–9.5 min mostrando fecha/hora real, comandos
   y resultados; el guion no se publica en el repositorio.
4. **Entrega**: `Nombre_Matricula_P2.txt` con nombre, matrícula, URL del repo y
   “Video de YouTube: pendiente de publicar”. Al subir el video se actualizan el
   TXT y la sección 8 del README.
5. Rotar contraseñas locales al final si el docente lo solicita.

---

## 10. Cómo continuar (otro agente)

1. Leer este archivo completo antes de actuar.
2. `cd C:\Users\axele\Documents\ParcialRedes\tools`
3. `python backup_all.py` antes de cambios en equipos.
4. `python cisco.py <R1|R2|SW> "<comando>"` para verificar (R1 usa `radius1` por AAA).
5. `python guest.py kali <script> [--root]` para Kali; `python winps.py <script.ps1>`
   para Windows; nunca imprimir secretos.
6. No renumerar: 192.168.16.0/24 y 10.16.0.0/30 están en uso y verificados.
7. Actualizar las tablas de las secciones 4 y 5 tras cada requisito, con la ruta
   de la evidencia real.
