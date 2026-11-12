# Semana 12 — Cyber Detective: respuestas

Programación Asistida de Aplicaciones · USFQ · Jose Martin Cobo

## Entrega

- Rama `skills/cyber-detective`, entregada como pull request a `main` (sin `push` directo a `main`).
- Agente: **Claude Code 2.1.322**, modelo `claude-opus-5-5`, con soporte nativo de Agent Skills.
- Skill: `incident-investigator/` (`SKILL.md`, `references/detection-rules.md` y el script opcional
  `scripts/analyze_logs.py`).
- Informe: `hallazgos.md`. Comparación: `comparacion.md`. Trazas: `evidencias/`.
- `logs_sinteticos.csv` es el archivo entregado con el enunciado (en mi descarga se llamaba
  `CMP 2104 Logs.csv`). Solo cambié el nombre: SHA-256
  `7d8219e9f8c9dd995be0c2dc038f4f7e67f0f12446b4fdc07fadf508befb5da8` en ambos archivos.

## Instalación

Claude Code descubre los skills de proyecto en `.claude/skills/<nombre>/SKILL.md` al iniciar una
sesión en el repositorio. Para tener una sola copia, el skill vive en `incident-investigator/`
(como pide la entrega) y `.claude/skills/incident-investigator` es un enlace simbólico a esa
carpeta. Es un skill de proyecto: no se instaló nada a nivel de usuario.

Comprobé la instalación en el evento `init` de una sesión nueva (`claude -p … --output-format
stream-json --verbose`): la lista `skills` incluye `incident-investigator`. Ese mismo dato aparece al
inicio de cada traza en `evidencias/`.

## Cómo se hicieron las pruebas

Cada prueba es una **sesión independiente** de `claude -p` (modo no interactivo, contexto nuevo),
con el mismo modelo y estas restricciones: herramientas permitidas `Read, Grep, Glob, Bash, Skill`;
prohibidas `Write, Edit, NotebookEdit, WebFetch, WebSearch` (nadie podía modificar archivos del
repositorio ni usar la web). En lugar de capturas, guardé **trazas textuales reales**, como permite
el enunciado. Las trazas crudas incluyen datos de mi cuenta (lista de conectores, rutas personales)
y el valor del token del CSV, así que en el repositorio público están **filtradas**: conservan los
eventos reales (qué herramienta se llamó, con qué entrada, un extracto del resultado y la respuesta
final) y reemplazan secretos por `[REDACTED]`. No edité el contenido de los eventos.

## Pruebas A, B y C (Misión 3 y 4)

Lo que **vi** en cada traza (no lo que el modelo dijo de sí mismo):

| Prueba | Solicitud | `Skill` llamado | Cuerpo de `SKILL.md` inyectado | Leyó `detection-rules.md` | Resultado | Traza |
|---|---|---|---|---|---|---|
| A — explícita | «Utiliza `incident-investigator` para investigar `logs_sinteticos.csv` y entrega hallazgos con filas de evidencia.» | sí | sí | sí | Se activó, siguió el procedimiento y usó el formato de salida. Base de `hallazgos.md`. | `evidencias/activacion_explicita.md` |
| B — contextual | «Revisa estos registros de autenticación (logs_sinteticos.csv). ¿Ves intentos sospechosos, cambios no aprobados o posibles secretos expuestos? Cita las filas que respaldan cada alerta.» | sí | sí | sí | Se activó **sin nombrarlo**, solo por la `description`. Mismas 4 alertas que A. | `evidencias/activacion_contextual.md` |
| C — control negativo | «Muéstrame cuántos eventos hay por hora en este CSV (logs_sinteticos.csv); no investigues incidentes ni clasifiques amenazas.» | **no** | **no** | **no** | No se activó (resultado deseado). Contó 63 eventos en la hora 01 y 30 en la 02 con `cut`/`uniq` y aclaró que no buscó incidentes. | `evidencias/control_negativo.md` |

A B y C solo les añadí el nombre del archivo entre paréntesis, porque en una sesión no interactiva
«estos registros» no señala nada.

Cómo distingo lo visto de lo inferido:

- **Visto:** la llamada a la herramienta `Skill` con `"skill": "incident-investigator"`; el mensaje
  sintético que Claude Code inyecta justo después (`Base directory for this skill: …`, seguido del
  cuerpo de `SKILL.md`), y las llamadas `Read` y `Bash` a `detection-rules.md` y `analyze_logs.py`.
  Claude Code no abre `SKILL.md` con `Read`; lo carga la propia herramienta `Skill`, por eso no
  aparece como lectura de archivo.
- **Inferido:** que la activación de B se debió a la `description`. Es la única información del
  skill que el agente ve antes de llamarlo, pero el razonamiento interno del modelo no se ve en la
  traza.

**Ajuste de la `description`:** no hizo falta. B se activó y C no en el primer intento, así que no
repetí las pruebas. La `description` ya incluía señales positivas (fuerza bruta, password spraying,
tokens expuestos, cambios de rol no aprobados) y el límite que C pone a prueba («no lo uses para
conteos, estadísticas, agrupaciones por hora…» y «cuando el usuario dice explícitamente que no
investigues»).

Las sesiones con skill mencionaron al final que el servidor `mcp-detective` (del deber 5,
registrado en este repositorio) no se pudo conectar. No afecta a esta práctica: todo se hizo con
lectura local del CSV.

## Archivos de la entrega

- `incident-investigator/`: el skill. Lo evaluado es `SKILL.md` y la referencia. El script es
  opcional: aplica las mismas reglas con la biblioteca estándar, no usa red, no escribe nada y oculta
  secretos antes de imprimir. Lo probé además con un CSV de casos límite (ventana de exactamente
  5:00 frente a 5:01, variantes `Login/FAILED`, filas duplicadas y `healthcheck` con `failed`), que no
  forma parte de la entrega.
- `hallazgos.md`: alertas con filas, verificación manual con los comandos ejecutados y por qué los 3
  fallos aislados no son fuerza bruta.
- `comparacion.md`: sin skill frente a con skill.
- `evidencias/`: cinco trazas filtradas (A, B, C y las dos de la Misión 5).
- El material de deberes anteriores que estaba en `evidencias/` pasó a `entregas/deber3/evidencias/`,
  igual que en las ramas `deber4` y `deber5`.

## Misión 6 — Plugin Detective

### 1. Skill frente a plugin

`incident-investigator` es un skill porque lo que aporta es **criterio y procedimiento**: cuándo
investigar, qué reglas aplicar, cómo citar evidencia y qué no afirmar. El agente lo carga solo cuando
la petición lo amerita (por su `description`) y abre `detection-rules.md` solo al evaluar umbrales.
No reacciona a eventos del entorno (eso sería un hook) ni da acceso a un sistema externo (eso sería
MCP).

Para distribuirlo como **plugin de Claude Code** se empaquetaría con:

- **Manifiesto** `.claude-plugin/plugin.json` (nombre, versión, descripción, autor) y una entrada en
  un `marketplace.json` para instalarlo con `/plugin install`.
- **El skill** en `skills/incident-investigator/`, igual que ahora.
- **Un comando** `/investigar <archivo.csv>` que lance el skill de forma explícita con una salida
  fija hacia `hallazgos.md`.
- **Un hook** `PreToolUse` sobre `Write`/`Edit` que bloquee cualquier escritura con `token=` seguido
  de algo que no sea `[REDACTED]`. Eso convierte la regla «no muestres tokens» de una instrucción
  que el modelo puede olvidar en un control que se cumple siempre.
- **Un subagente** «verificador» que relea en el CSV cada fila citada antes de cerrar el informe.
- **Un servidor MCP** (opcional) para leer logs desde un almacenamiento real en vez de un CSV local,
  con acceso de solo lectura.

### 2. Ralph Loop (máximo 3 iteraciones)

Un Ralph Loop vuelve a ejecutar al agente con la misma tarea mientras no se cumpla una condición. Lo
usaría solo contra **comprobaciones verificables por programa**, no contra la opinión del modelo:

1. **Iteración 1:** el agente produce `hallazgos.md` con el skill.
2. **Comprobaciones** (un script, sin modelo):
   - cada fila citada existe y su `event`, `result`, `ip` y `user` coinciden con lo que afirma el
     informe;
   - ningún `token=` va seguido de algo distinto de `[REDACTED]`;
   - los conteos de R1 y R2 coinciden con `scripts/analyze_logs.py`;
   - los fallos bajo el umbral aparecen en «Descartado»;
   - el SHA-256 de `logs_sinteticos.csv` no cambió.
3. **Iteraciones 2 y 3:** si algo falla, el agente recibe **solo la lista de fallos** y corrige el
   informe. Puede quitar o corregir afirmaciones, pero no puede añadir filas, eventos ni alertas que
   no salgan del CSV.

**Criterio de parada:** se detiene cuando todas las comprobaciones pasan, cuando se cumplen 3
iteraciones (entonces entrega el informe con las comprobaciones pendientes marcadas como no
resueltas) o cuando dos iteraciones seguidas dejan exactamente los mismos fallos (no hay progreso).
Nunca se da por buena una iteración porque el modelo diga que terminó.
