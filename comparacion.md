# Comparación: sin skill frente a con skill (Misión 5)

## Cómo se hizo

Fueron dos sesiones **independientes** de `claude -p`. Cada una es un proceso nuevo, sin historial
compartido. Usaron el mismo modelo (`claude-opus-5-5`, Claude Code 2.1.322), el mismo CSV
(SHA-256 idéntico) y la misma solicitud:

> Investiga los logs sintéticos, identifica incidentes justificables y distingue señales de
> seguridad de actividad normal. Devuelve evidencia concreta. Archivo: logs_sinteticos.csv

Solo añadí el nombre del archivo, porque en una sesión no interactiva no hay otro modo de decir
cuál es.

- **Sin skill:** carpeta temporal fuera del repositorio que solo contiene una copia del CSV. El
  evento `init` confirma que `incident-investigator` **no** estaba entre los skills disponibles.
  Tampoco tenía acceso a `SKILL.md`, a `detection-rules.md` ni al script.
- **Con skill:** el repositorio, donde el evento `init` lista `incident-investigator`. La traza
  muestra la llamada a `Skill`, el cuerpo de `SKILL.md` inyectado en el contexto, la lectura de
  `references/detection-rules.md` y la ejecución de `scripts/analyze_logs.py`.

Ambas sesiones tenían las mismas herramientas permitidas y prohibidas (sin escritura de archivos
ni web). Trazas: `evidencias/m5_sin_skill.md` y `evidencias/m5_con_skill.md`.

## Tabla

| Dimensión | Sin skill | Con skill | Evidencia / comentario |
|---|---|---|---|
| ¿Usó un procedimiento reproducible? | Parcial. Un resumen en Python por IP y criterios propios («ritmo humano», «IP interna/externa», tasa de fallos de fondo). No declara umbrales ni ventanas. | Sí. Inspección del archivo, lectura de las reglas, script, revisión manual, relectura de filas y reporte en el formato fijo. Umbrales explícitos (6 fallos, 5 usuarios, ventana de 5 min). | La sesión sin skill sería difícil de repetir en otro CSV con el mismo criterio. |
| ¿Citó filas concretas? | Sí, pero en spraying cita «líneas 67 a 74», un rango que incluye las 69 y 72 (inicios de sesión normales de otros usuarios desde otras IP). | Sí, fila por fila (67, 68, 70, 71, 73, 74). Declara que releyó cada fila citada en el CSV original. | Comprobado con `sed -n '69p;72p'`: son `login/success` desde 192.0.2.10. |
| Alertas sustentadas | Las mismas 4 situaciones, pero con afirmaciones que el registro no sostiene: «compromiso probable», «qué hizo el atacante dentro», «abuso de la cuenta», «el atacante conoce la lista completa de usuarios». | 4 alertas, cada una con su regla y su limitación. Dice explícitamente que ninguna alerta prueba un compromiso ni una autoría. | El enunciado pide alertas justificadas, no conclusiones forenses ni culpables. |
| Falsos positivos detectados o evitados | Descarta bien los 3 fallos de `maria` y el `healthcheck`. **No detecta** las 3 filas idénticas de R1. Al contrario, usa «hasta 3 intentos en el mismo minuto» como agravante. | Descarta lo mismo y además señala que la alerta R1 depende de 3 pares de filas idénticas: sin ellos quedan 5 fallos, bajo el umbral. | Verificado: `sort \| uniq -d` devuelve exactamente esos 3 pares. |
| ¿Ocultó posibles tokens? | **No.** La respuesta final mostraba el valor completo del token. Además, razonó a partir del valor para bajar la severidad a «bajo». | Sí: `token=[REDACTED]` en la respuesta. Además, el valor crudo **no apareció en ningún resultado de herramienta**: leyó el CSV con un filtro `sed` y el script oculta el token por su cuenta, así que el secreto ni siquiera entró en su contexto. Severidad alta. | La traza sin skill está filtrada para no publicar el valor. Que lo mostraba lo comprobé sobre la traza cruda antes de filtrar (resumen automático al final de la traza). |
| ¿Reconoció incertidumbre? | Parcial. Advierte que las IP son de documentación y que no hay ID de sesión, pero recomienda «bloquear 203.0.113.0/24» y deduce «IP interna/externa». | Sí. Duplicados, precisión de minuto, lo que el registro no dice e IP de documentación no consultadas. | La recomendación de bloqueo trata IP de documentación como infraestructura real. |
| ¿Qué hizo gracias al skill? | — | Consultó `detection-rules.md`, contrastó el script con su revisión manual, aplicó la convención de duplicados, ocultó el token y usó la tabla estándar con «Descartado», «Verificación» e «Incertidumbre». | Visible en la traza: llamada `Skill`, mensaje con el cuerpo de `SKILL.md`, `Read` de `detection-rules.md` y `Bash` con `analyze_logs.py`. |

**Tiempo y costo** (reportados por Claude Code en el evento `result`; es una sola corrida y las
cinco sesiones corrieron en paralelo, así que el tiempo es orientativo):

| | Sin skill | Con skill |
|---|---|---|
| Turnos | 4 | 8 |
| Duración | 52 s | 39 s |
| Tokens de salida | 5133 | 4150 |
| Costo informado | 0.254 USD | 0.341 USD |

## Qué aportó el skill en concreto

**La detección no.** El modelo sin skill encontró las mismas cuatro situaciones. Con un CSV así de
pequeño y patrones así de claros, un modelo fuerte las ve solo. Una cosa la hizo mejor que lo que
pedí: no usó las etiquetas de `detail` como prueba.

Lo que cambió fue la **contención** y el **rigor**:

1. **Contención de secretos.** Sin skill, el token apareció completo en la respuesta. Es justo el
   fallo que la regla R3 existe para evitar.
2. **Contención de invenciones.** Sin skill, el informe pasa de «la regla se cumple» a «el atacante
   comprometió admin» y recomienda acciones sobre IP de documentación. Con skill, cada alerta dice
   lo que el registro muestra y lo que no.
3. **La referencia.** La convención de duplicados de `detection-rules.md` hizo que la sesión con skill
   notara que R1 depende de 3 pares de filas idénticas. Sin skill, esas filas se leyeron como un
   agravante. Es el hallazgo más fino del ejercicio y salió de la referencia, no del modelo.
4. **Procedimiento y formato.** Umbrales explícitos, relectura de filas, contraste con el script y
   una tabla que se puede comparar entre corridas y entre archivos distintos.

El costo fue mayor (0.34 frente a 0.25 USD), por leer la referencia y verificar. Lo que cambiaría:
el procedimiento ya cubre bien este CSV, pero para logs más grandes pediría que el script imprima
directamente los descartes completos (hoy omite pares de un solo fallo) para que la revisión manual
no tenga que reconstruirlos.

Es una **comparación didáctica** de una corrida por condición, no una prueba estadística.
