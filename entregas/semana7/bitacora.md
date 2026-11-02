# Bitácora: vibe coding vs. SDD (divisor de cuenta)

Fecha: 2026-10-01. Agente: Claude Code 2.1.287. Modelo: Claude Opus 5.5
(`claude-opus-5-5`) en las dos ramas, con la configuración de razonamiento por defecto
(no se cambió en ninguna). Archivo de instrucciones: `CLAUDE.md` (solo en la rama `sdd`).
Caso de Git (Parte 1.5): **C**.

## Métricas principales

| | rama vibe | rama sdd |
|---|---|---|
| Iteraciones (veces que le tuviste que volver a pedir algo) | 2 | 0 correcciones (más 11 pasos del flujo de la guía; ver nota) |
| Casos de aceptación que cumple (0–6) | 2 (casos 1 y 2) | 6 |
| Pruebas automatizadas que pasan | 12/12 propias; 0 de las de `sdd` (no compilan) | 33/33 (10 de la guía + 23 de casos borde) |
| Archivos en `lib/` | 4 | 11 |
| Líneas de código en `lib/` | 287 | 523 |
| ¿`domain/` depende de Flutter? | No existe `domain/` (`lib/logic/` sí es Dart puro, pero sin regla que lo exija) | No |
| ¿Existe separación `presentation/domain/data`? | No (`logic/`, `screens/`) | Sí |
| ¿El agente agregó algo que nadie pidió? | Sí (ver abajo) | Pocas cosas, todas escritas en la spec, el plan o las tareas |
| ¿Se puede agregar otra estrategia sin modificar el cálculo existente? | No | Sí (demostrado en el commit `bb1ae56`) |

| Métrica secundaria opcional | rama vibe | rama sdd |
|---|---:|---:|
| Tiempo aproximado hasta cumplir los 6 escenarios | nunca los cumplió (16 min hasta la versión final) | ~18 min (13:07 → 13:25) |

### Regla de conteo de iteraciones

- Se aplicó la regla de la guía: la solicitud inicial no cuenta; cada mensaje nuevo para
  pedir una corrección, cambio o explicación cuenta.
- En `sdd`, los mensajes que la guía prescribe como parte del flujo (instrucciones del
  agente, constitution, specify, clarify, plan, tasks, analyze, implement, converge y los
  dos pedidos de pruebas de la Parte 9) se reportan aparte (11) y no como iteraciones,
  porque no corrigen nada: son el método. No hubo que pedir ninguna corrección del
  código. Los dos problemas que aparecieron (hallazgo D1 de analyze y la tarea T028 de
  converge) se resolvieron dentro del flujo, corrigiendo artefactos.
- Si se cuenta cada mensaje sin excepción, `sdd` tendría 11 y `vibe` 2.

## Cómo se ejecutó (nota metodológica)

- Toda la práctica la ejecutó Claude Code de forma autónoma, a pedido del estudiante.
- La rama `vibe` la construyó **otra instancia del agente** (mismo modelo), que recibió
  solo la frase de la guía y la ruta del proyecto. No tuvo acceso a la guía, a los
  escenarios ni a la rama `sdd`. Trabajó en un `git worktree` aparte, en paralelo.
- Las dos correcciones de `vibe` las escribió el agente principal en el papel del
  estudiante, usando solo la descripción de "La app" del enunciado ("monto total,
  número de personas, porcentaje de propina → cuánto paga cada uno. Nada más"), sin
  mencionar los 6 escenarios.
- Las respuestas a `/speckit-clarify` también las eligió el agente principal (aceptó la
  opción recomendada). Están en `DECISIONS.md` para que el estudiante las revise.

## Rama vibe: qué pasó

| Momento | Mensaje | Resultado |
|---|---|---|
| Solicitud inicial | "Hazme una app en Flutter para dividir la cuenta entre varias personas." | 12 archivos, 1499 líneas, 19 pruebas. Modo "partes iguales" y modo "por consumo" con platos, nombres de personas, atajos de propina (0/10/15/20 %), nota sobre el 10 % de servicio en Ecuador, botón "Copiar resumen", reinicio con confirmación, tema oscuro, nombre "Divide la cuenta" en Android, iOS y web. Commit `01340e6`. |
| Iteración 1 | "Está muy completa, pero no es lo que tenía en mente. Quiero algo más simple: una sola pantalla donde escribo el monto total, el número de personas y el porcentaje de propina, y me dice cuánto paga cada uno. Nada más…" | Simplificó a 3 campos, pero dejó por su cuenta una línea extra ("Para que cuadre exacto: 2 pagan $17.53 y 1 paga $17.52") y lo avisó. |
| Iteración 2 | "Sí, quita la línea de 'para que cuadre exacto'. Solo quiero ver cuánto paga cada uno." | Versión final: 4 archivos, 287 líneas, 12 pruebas. Recalcula mientras se escribe (sin botón) y redondea al centavo **hacia arriba**. Commit `f6b3d7e`. |

`flutter analyze` en la versión final: `No issues found!`

## Rama sdd: qué pasó

| Paso | Resultado |
|---|---|
| `CLAUDE.md` | 30 líneas, ningún archivo nuevo en `lib/`. |
| `specify init . --integration claude --script sh` | Spec Kit 1.0.13; skills en `.claude/skills/`, `.specify/` versionada. |
| `/speckit-constitution` | 5 principios (SOLID, capas, seguridad, pruebas, regla de la materia) y una tabla con el comando que comprueba cada regla. |
| `/speckit-specify` | `specs/001-divisor-cuenta/spec.md`: 3 historias (P1 cálculo, P2 validación, P3 hacia arriba), 10 requisitos funcionales. |
| `/speckit-clarify` | 3 preguntas, integradas como FR-011, FR-012 y FR-013. |
| `/speckit-plan` | `plan.md`, `research.md` (10 decisiones), `data-model.md`, `contracts/`, `quickstart.md`. Al investigar el plan se agregaron límites de entrada a la spec. |
| `/speckit-tasks` | **27 tareas** (T001–T027). |
| `/speckit-analyze` | 1 hallazgo CRITICAL (D1: `test/widget_test.dart` de la plantilla rompe `flutter analyze` en cuanto cambia `main.dart`) y 4 menores. Se corrigieron en `tasks.md` y `data-model.md`. |
| `/speckit-implement` | Fases 1–5 en 5 commits. US3 solo agregó un archivo y 5 líneas en `main.dart`. |
| `/speckit-converge` | 1 tarea nueva, T028: `grep "RedondeoExacto()"` también encontraba el constructor `const RedondeoExacto();` en `lib/data/`. Se quitó el constructor explícito. Total: 28 tareas. |
| Parte 9 | `flutter test`: 33/33. `flutter analyze`: sin issues. `flutter build apk --debug`: falla porque esta Mac no tiene Android SDK. `flutter build macos --debug`: construye. |

### Qué inventó la spec que el estudiante no dijo (Parte 6.1)

- Mensaje "Propina inválida" y propina vacía = 0 %.
- Orden de prioridad cuando hay varios errores (monto, personas, propina).
- Coma aceptada como separador decimal (FR-010).
- "Exacto" = centavo más cercano, mitad hacia arriba (FR-004).
- En modo hacia arriba, un valor que ya es entero no sube (30.00 sigue en 30.00).
- Criterios de éxito con tiempos (SC-002: menos de 30 s; SC-003: menos de 1 s) y modo
  avión (SC-004).
- Sin símbolo de moneda; fuera de alcance: historial y división desigual.
- Después del plan: monto hasta 1 000 000 000, propina hasta 100 %, personas solo
  dígitos (hasta 6).

## Parte 10: las pruebas de sdd en vibe

- `git checkout sdd -- test/` y `flutter test`: **no compiló**. Resumen:
  `+12 -4: Some tests failed.` (las 12 propias de vibe pasan; los 4 archivos traídos de
  `sdd` fallan al cargar).
- Primer error:

  ```text
  test/division_test.dart:6:8: Error: Error when reading 'lib/data/redondeo_exacto.dart': No such file or directory
  import 'package:divisor_cuenta/data/redondeo_exacto.dart';
  ```

- Después se devolvió `test/` a su estado con `git restore --source=HEAD --staged --worktree test/`.

### Los 6 escenarios a mano (las dos apps, corriendo en Chrome)

| # | Entrada | Esperado | vibe | sdd |
|---|---|---|---|---|
| 1 | 100, 4, 10 %, exacto | 27.50 | $27.50 ✓ | 27.50 ✓ |
| 2 | 90, 3, 0 %, exacto | 30.00 | $30.00 ✓ | 30.00 ✓ |
| 3 | 50, 0 personas | "Debe haber al menos una persona", sin resultado | "Debe ser al menos 1" bajo el campo, sin resultado ✗ | ✓ |
| 4 | monto "abc" | "Monto inválido" | el campo no deja escribir letras; no aparece ningún mensaje ✗ | ✓ |
| 5 | 10, 3, 0 %, exacto | 3.33 | $3.34 ✗ (redondea al centavo hacia arriba) | 3.33 ✓ |
| 6 | 10, 3, 0 %, hacia arriba | 4.00 | no existe el modo; muestra $3.34 ✗ | 4.00 ✓ |

## Verificaciones de SOLID (Parte 9.5 y 10)

```text
# rama sdd
$ grep -rn "package:flutter" lib/domain/
(sin salida)
$ grep -rn -E "RedondeoExacto\(\)|RedondeoHaciaArriba\(\)" lib/
lib/main.dart:22:    'Exacto': RedondeoExacto(),
lib/main.dart:23:    'Hacia arriba': RedondeoHaciaArriba(),
$ grep -n -E "is Redondeo|as Redondeo" lib/domain/calcular_division.dart
(sin salida)
$ grep -n -E "toStringAsFixed|inválido|al menos una persona" lib/domain/calcular_division.dart
(sin salida)

# rama vibe
$ grep -rn "package:flutter" lib/
lib/main.dart:1:import 'package:flutter/material.dart';
lib/screens/home_screen.dart:3:import 'package:flutter/material.dart';
lib/screens/home_screen.dart:4:import 'package:flutter/services.dart';
$ ls lib/
logic  main.dart  screens
$ grep -rn "package:flutter" lib/domain/
ugrep: warning: lib/domain/: No such file or directory
$ grep -rn -E "RedondeoExacto\(\)|RedondeoHaciaArriba\(\)" lib/
(sin salida: no existe ninguna estrategia de redondeo)
```

## `git diff vibe sdd --stat` (resumen)

`71 files changed, 7108 insertions(+), 438 deletions(-)`. La mayor parte son los
archivos de Spec Kit (`.specify/`, `.claude/skills/`) y los artefactos de `specs/`.
En `lib/`: `sdd` agrega `domain/`, `data/` y `presentation/` (11 archivos) y quita
`logic/` y `screens/` de vibe. Además aparecen `android/app/src/main/AndroidManifest.xml`,
`ios/Runner/Info.plist`, `web/index.html` y `web/manifest.json`, que vibe modificó para
cambiar el nombre visible de la app.
