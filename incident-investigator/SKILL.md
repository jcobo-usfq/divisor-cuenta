---
name: incident-investigator
description: Investiga incidentes de seguridad en logs CSV de autenticación y administración (columnas timestamp, ip, user, event, result, detail) y entrega alertas justificadas con número de fila como evidencia. Úsalo cuando pidan revisar registros buscando fuerza bruta, password spraying, accesos o intentos sospechosos, tokens o secretos expuestos, cambios de rol o privilegios no aprobados, o distinguir señales de seguridad de actividad normal. No lo uses para conteos, estadísticas, agrupaciones por hora ni gráficos descriptivos de un CSV cuando no se pide investigar incidentes, ni cuando el usuario dice explícitamente que no investigues ni clasifiques amenazas.
---

# incident-investigator

Guía para investigar, de forma reproducible, logs CSV de autenticación y seguridad.
El resultado son **alertas justificadas por filas del CSV**, no conclusiones forenses
ni atribuciones de culpa.

## Alcance y límites (léelos antes de empezar)

- Trabaja solo con los archivos locales que te indiquen. **Sin red**: no consultes,
  geolocalices ni hagas ping a las IP. Las IP de rangos de documentación
  (192.0.2.0/24, 198.51.100.0/24, 203.0.113.0/24, 2001:db8::/32) no son
  infraestructura real.
- **No modifiques el CSV original.** Si necesitas transformar datos, hazlo en memoria
  o en un archivo aparte.
- **No inventes eventos, filas, IP ni usuarios.** Toda alerta debe poder rastrearse a
  filas concretas. Si algo no está en los datos, dilo.
- **Nunca muestres secretos completos.** Cualquier valor después de `token=` (o
  `password=`, `secret=`, `apikey=`) se reemplaza por `[REDACTED]` en todo lo que
  escribas: respuesta, informe, tablas y comandos que imprimas.
- Una alerta indica que una regla se cumple, **no** que alguien sea culpable.

## Procedimiento

1. **Inspecciona el archivo.** Lee el encabezado y unas pocas filas. Confirma que
   existen las columnas `timestamp, ip, user, event, result, detail` y el formato de
   `timestamp`. Cuenta las filas de datos. Si faltan columnas o hay timestamps que no
   se pueden interpretar, anótalo como limitación y sigue con lo que sí se pueda
   analizar.
2. **Lee las reglas.** Abre `references/detection-rules.md` **siempre** antes de
   evaluar umbrales o ventanas, y vuelve a abrirlo si dudas de un caso límite
   (ventana exacta de 5 minutos, coincidencia exacta de `event`/`result`, duplicados,
   éxito posterior a una ráfaga). No apliques umbrales de memoria.
3. **Numera las filas** según el archivo original: el encabezado es la fila 1 y la
   primera fila de datos es la 2. Conserva ese número aunque luego ordenes.
4. **Ordena por `timestamp`** (sin perder el número de fila original) y evalúa cada
   regla de la referencia. Puedes usar `scripts/analyze_logs.py` como apoyo
   reproducible (ver abajo), pero el script **no reemplaza** la verificación.
5. **Verifica contra el CSV.** Para cada alerta, relee al menos las filas citadas en
   el archivo original (por ejemplo con `sed -n '<fila>p' archivo.csv`) y confirma que
   `event`, `result`, `ip`, `user` y `timestamp` coinciden con lo que afirmas.
6. **Distingue alerta de hecho confirmado.** Una alerta es «la regla X se cumple en
   estas filas». Un hecho confirmado es solo lo que el registro dice literalmente
   (por ejemplo, «la fila 14 registra `role_change/success` con `approved=false`»).
   No afirmes intenciones, autores ni compromisos de cuentas.
7. **Revisa falsos positivos.** Indica explícitamente qué patrones parecían
   sospechosos pero **no** alcanzan una regla (fallos aislados bajo el umbral,
   `healthcheck`, valores de `event`/`result` que no coinciden exactamente) y por qué.
8. **Reporta** con el formato de salida de abajo.
9. **Declara la incertidumbre**: datos ausentes, timestamps ambiguos, posibles
   duplicados que no se pueden identificar de forma inequívoca, zonas horarias.

## Script auxiliar (opcional)

`scripts/analyze_logs.py` aplica las reglas de la referencia con la biblioteca
estándar de Python, sin red y en solo lectura:

```bash
python3 <ruta-del-skill>/scripts/analyze_logs.py logs.csv
```

Imprime las alertas con números de fila originales y con los tokens ya ocultos.
Úsalo para hacer el análisis reproducible y para contrastar tu revisión manual. Si el
script y tu revisión no coinciden, investiga la diferencia en las filas y repórtala;
no elijas el resultado que «suena mejor».

## Formato de salida

Empieza con una línea de contexto: archivo analizado, número de filas de datos y rango
de `timestamp`. Después, una tabla de alertas:

| alerta | severidad orientativa | regla | timestamp (inicio–fin) | ip | usuario | filas / evidencia | limitaciones |
|---|---|---|---|---|---|---|---|

- **severidad orientativa**: alta, media o baja según la referencia; es una
  orientación, no una calificación de riesgo formal.
- **filas / evidencia**: números de fila del CSV original y, si ayuda, un extracto
  corto del `detail` (siempre con secretos en `[REDACTED]`).

Luego, tres apartados breves:

1. **Descartado (no es alerta)**: patrones revisados que no cumplen ninguna regla, con
   sus filas y el motivo.
2. **Verificación**: qué filas releíste en el archivo original y qué comprobaste.
3. **Incertidumbre y límites**: lo que el registro no permite afirmar.

Si te piden guardar el informe, escríbelo en Markdown (`hallazgos.md`) con la misma
estructura, salvo que pidan JSON.
