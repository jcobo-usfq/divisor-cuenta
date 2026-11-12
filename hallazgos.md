# Hallazgos — `logs_sinteticos.csv`

Informe producido con el skill `incident-investigator` (Prueba A, traza en
`evidencias/activacion_explicita.md`) y verificado a mano contra el CSV original (sección
«Verificación manual»). Los números de fila son los del archivo original: el encabezado es la
fila 1. Son **alertas justificadas**, no conclusiones forenses.

**Archivo:** `logs_sinteticos.csv`, 93 filas de datos (filas 2 a 94), de
`2026-11-05T01:01:00-05:00` a `2026-11-05T02:29:00-05:00`. Todas las filas tienen 6 columnas y
todos los timestamps usan la zona `-05:00`.

## Alertas

| alerta | severidad orientativa | regla | timestamp (inicio–fin) | ip | usuario | filas / evidencia | limitaciones |
|---|---|---|---|---|---|---|---|
| Fuerza bruta probable | alta | R1 | 01:14:00 – 01:18:00 | 198.51.100.77 | admin | 17, 19, 20, 22, 23, 25, 26, 27: 8 `login/failed` (`incorrect password`) en 4 min. **Éxito posterior desde la misma IP: fila 28** (01:19, `login after multiple failures`) | Las filas 19=20, 22=23 y 25=26 son idénticas. Sin esas repeticiones quedan 5 fallos, por debajo del umbral de 6. El éxito no prueba que la cuenta esté comprometida. |
| Password spraying probable | media | R2 | 02:01:00 – 02:03:00 | 203.0.113.89 | ana, carlos, luisa, diego, maria, sofia | 67, 68, 70, 71, 73, 74: un `login/failed` por usuario, 6 usuarios distintos en 2 min | Ningún `login/success` desde esa IP después. Los éxitos de esos usuarios desde otras IP (69, 72, 75, 76) no se pueden relacionar con el intento. |
| Token potencialmente expuesto | alta | R3 | 01:27:00 | 192.0.2.44 | api_service | 33: `debug/warning`, `token=[REDACTED]; debug output` | Solo muestra que el token quedó escrito en un log de depuración. No indica si es válido ni si se usó. |
| Escalada no autorizada según el registro | alta | R4 | 01:50:00 | 203.0.113.42 | guest | 59: `role_change/success`, `role=user->admin; approved=false` | El registro no dice quién ejecutó el cambio ni con qué intención. |

**Observación fuera de las reglas (sin severidad):** la fila 57 (01:49) registra `access/denied`
a `resource=/admin` del mismo `guest` desde la misma IP, un minuto antes de la fila 59. Es contexto
para R4, no una alerta.

## Descartado (no es alerta)

- **maria desde 192.0.2.25 (filas 38, 39, 41):** 3 fallos y un éxito en la fila 42. Ver la
  explicación abajo.
- **maria desde 192.0.2.12 (filas 24, 31):** 2 fallos separados por 8 minutos.
- **maria en total:** 7 fallos (24, 31, 34, 38, 39, 41, 87), pero desde 4 IP distintas y a lo largo
  de unos 70 minutos. R1 exige misma IP, mismo usuario y 5 minutos.
- **Fallos sueltos (filas 3, 7, 14, 46, 47, 51, 60):** 1 o 2 por par IP-usuario.
- **healthbot desde 192.0.2.200 (filas 78, 80–84):** `healthcheck/success`. Un healthcheck no es un
  `login/failed` y no cuenta para R1 ni R2.

## Verificación manual

No confié solo en el texto del modelo. Releí las filas en el CSV original con `awk`, cuyo `NR` es
el número de fila con el encabezado como fila 1:

```text
$ awk -F, '$2=="198.51.100.77" {print NR": "$0}' logs_sinteticos.csv
17: 2026-11-05T01:14:00-05:00,198.51.100.77,admin,login,failed,incorrect password
19: 2026-11-05T01:15:00-05:00,198.51.100.77,admin,login,failed,incorrect password
20: 2026-11-05T01:15:00-05:00,198.51.100.77,admin,login,failed,incorrect password
22: 2026-11-05T01:16:00-05:00,198.51.100.77,admin,login,failed,incorrect password
23: 2026-11-05T01:16:00-05:00,198.51.100.77,admin,login,failed,incorrect password
25: 2026-11-05T01:17:00-05:00,198.51.100.77,admin,login,failed,incorrect password
26: 2026-11-05T01:17:00-05:00,198.51.100.77,admin,login,failed,incorrect password
27: 2026-11-05T01:18:00-05:00,198.51.100.77,admin,login,failed,incorrect password
28: 2026-11-05T01:19:00-05:00,198.51.100.77,admin,login,success,login after multiple failures
```

- **R1 confirmado contra las filas:** 8 filas `login/failed`, misma IP y mismo usuario. Primera a
  las 01:14 y última a las 01:18: 4 minutos, dentro de la ventana de 5. El éxito de la fila 28
  llega 1 minuto después del último fallo, dentro de los 5 minutos siguientes.
- **Duplicados:** `tail -n +2 logs_sinteticos.csv | sort | uniq -d | wc -l` devuelve `3`. Son los
  tres pares de arriba. Los timestamps tienen precisión de minuto, así que dos intentos reales en el
  mismo minuto son posibles. No se puede decidir de forma inequívoca si son duplicados, y por eso la
  alerta se mantiene con la limitación declarada en lugar de inventar una regla de deduplicación.

### Por qué los 3 fallos aislados no son fuerza bruta

```text
$ awk -F, '$2=="192.0.2.25" {print NR": "$0}' logs_sinteticos.csv
38: 2026-11-05T01:35:00-05:00,192.0.2.25,maria,login,failed,mistyped password
39: 2026-11-05T01:36:00-05:00,192.0.2.25,maria,login,failed,mistyped password
41: 2026-11-05T01:37:00-05:00,192.0.2.25,maria,login,failed,mistyped password
42: 2026-11-05T01:38:00-05:00,192.0.2.25,maria,login,success,legitimate user
```

R1 exige **6 o más** `login/failed` de la misma IP contra el mismo usuario en 5 minutos. Aquí hay
**3**, la mitad del umbral, y no hay otros fallos de esa IP en todo el archivo. Tampoco es spraying
(R2): todos los intentos van contra un solo usuario, no contra 5 distintos. El patrón (pocos fallos
seguidos de un éxito) es compatible con una persona que se equivocó al escribir su contraseña.
Marcarlo como alerta sería un falso positivo. El `detail` (`mistyped password`, `legitimate user`)
coincide con esa lectura, pero no lo usé como prueba: la conclusión sale del conteo, no de la
etiqueta.

## Incertidumbre y límites

- La alerta R1 depende de cómo se interpreten las 3 filas repetidas (ver arriba).
- Los timestamps tienen precisión de minuto: no se conoce el orden real dentro de un mismo minuto.
- El registro no permite afirmar si alguna cuenta está comprometida, quién está detrás de cada IP ni
  si el token de la fila 33 es válido.
- Todas las IP pertenecen a rangos de documentación (192.0.2.0/24, 198.51.100.0/24,
  203.0.113.0/24). No se consultaron ni se trataron como infraestructura real.
