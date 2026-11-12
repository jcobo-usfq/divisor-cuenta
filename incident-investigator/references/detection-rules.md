# Reglas de detección — incident-investigator

Reglas de dominio para logs CSV con columnas `timestamp, ip, user, event, result,
detail`. Consulta este archivo antes de evaluar cualquier umbral o ventana.

## Convenciones comunes (aplican a todas las reglas)

1. **Numeración**: el encabezado es la fila 1; la primera fila de datos es la 2. Cita
   siempre el número de fila del archivo original, aunque hayas ordenado.
2. **Orden**: ordena por `timestamp` antes de evaluar ventanas. Si dos filas tienen el
   mismo `timestamp`, conserva el orden original del archivo.
3. **Ventana de 5 minutos**: un conjunto de filas está «dentro de 5 minutos» si
   `último timestamp − primer timestamp ≤ 5 min` (300 s). **Ambos extremos se
   incluyen**: una diferencia de exactamente 5:00 cuenta; 5:01 no.
4. **Coincidencia exacta**: cuenta solo filas cuyo `event` y `result` coincidan
   **exactamente** con el valor de la regla (`login` y `failed`, en minúsculas, sin
   espacios extra). Variantes como `Login`, `FAILED`, `login ` o `logon` **no
   cuentan**; menciónalas en «Incertidumbre y límites» si aparecen.
5. **Duplicados**: si hay filas idénticas en todas las columnas, no supongas que son
   un error de registro ni que son eventos distintos. Cuéntalas como aparecen,
   señálalas y explica si cambian el resultado de una regla (por ejemplo, si sin el
   duplicado no se alcanza el umbral). Si no puedes decidir de forma inequívoca, decláralo
   como limitación en lugar de inventar una regla de deduplicación.
6. **Una alerta por episodio**: si varias ventanas que se solapan cumplen la misma
   regla para la misma clave (IP/usuario), repórtalas como un único episodio con
   todas sus filas y el rango de tiempo completo.

## R1 — Fuerza bruta probable

- **Condición**: 6 o más filas `event=login`, `result=failed` desde la **misma IP**
  hacia el **mismo usuario** dentro de una ventana de 5 minutos.
- **Éxito posterior** (anótalo por separado, como agravante): un `login/success`
  para el **mismo usuario** en los 5 minutos siguientes al último fallo del episodio
  (`0 < t_éxito − t_último_fallo ≤ 5 min`).
  - Desde la misma IP: anótalo como «éxito posterior desde la misma IP».
  - Desde otra IP: anótalo como contexto, no como parte de la regla, e indica que
    el registro no permite relacionar ambas IP.
  - Un éxito posterior **no prueba** que la cuenta esté comprometida: el registro
    no distingue a un atacante de un usuario legítimo que recordó su contraseña.
- **Severidad orientativa**: media; **alta** si hay éxito posterior desde la misma IP.

## R2 — Password spraying probable

- **Condición**: filas `login/failed` desde la **misma IP** contra **al menos 5
  usuarios distintos** dentro de una ventana de 5 minutos.
- Cita todas las filas del episodio y la lista de usuarios afectados.
- Si la misma IP también cumple R1 contra uno de esos usuarios, repórtalo como dos
  alertas distintas: son patrones diferentes.
- **Severidad orientativa**: media; alta si alguno de los usuarios tiene un
  `login/success` desde esa IP en los 5 minutos siguientes.

## R3 — Token potencialmente expuesto

- **Condición**: la columna `detail` contiene la subcadena `token=`.
- **Nunca** imprimas el valor. Reemplaza todo lo que sigue a `token=` hasta el
  siguiente separador (espacio, `&`, `;`, `,` o fin de campo) por `[REDACTED]`. Haz
  lo mismo con `password=`, `secret=` y `apikey=` si aparecen, aunque no sean parte
  de la regla.
- Puedes indicar la longitud aproximada o un prefijo de 0 caracteres; no muestres ni
  siquiera los primeros caracteres del secreto.
- No afirmes que el token es válido ni que se usó: el registro solo muestra que
  quedó escrito en un log (posible registro de depuración).
- **Severidad orientativa**: alta (un secreto en logs es un problema por sí solo).

## R4 — Escalada no autorizada según el registro

- **Condición**: `event=role_change`, `result=success` y `detail` contiene
  `approved=false`.
- Reporta quién figura en `user`, la IP y lo que diga `detail` (rol de origen y
  destino, si aparece), con secretos ocultos.
- No infieras culpabilidad ni intención: «el registro muestra un cambio de rol
  exitoso marcado como no aprobado».
- `role_change` con `approved=true`, o con `result=failed`, **no** es alerta R4;
  menciónalo en «Descartado» si es relevante.
- **Severidad orientativa**: alta.

## Falsos positivos que debes descartar explícitamente

- **Fallos aislados bajo el umbral**: por ejemplo, 3 `login/failed` del mismo usuario
  e IP. No alcanzan los 6 de R1 ni los 5 usuarios de R2. Repórtalos en «Descartado»
  con sus filas.
- **Fallos dispersos**: 6 o más fallos de la misma IP y usuario que **no** caben en
  ninguna ventana de 5 minutos no cumplen R1.
- **`healthcheck`**: un `event=healthcheck` (aunque tenga `result=failed`) **no** es
  un `login/failed` y no cuenta para R1 ni R2.
- **Variantes de texto**: `Login/FAILED` y similares no cuentan (convención 4).

## Lo que estas reglas no cubren

Si observas algo llamativo que no encaja en R1–R4 (horarios inusuales, usuarios
inexistentes, IP nuevas), puedes mencionarlo como **observación**, separado de las
alertas y sin severidad, aclarando que no corresponde a ninguna regla definida.
