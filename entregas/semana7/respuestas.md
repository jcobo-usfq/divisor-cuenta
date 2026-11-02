# Respuestas: Vibe coding vs. SDD con GitHub Spec Kit

Programación Asistida de Aplicaciones, USFQ. Participación de la semana 7.

> **Nota de método.** Toda la práctica la ejecutó Claude Code de forma autónoma, a
> pedido mío. La rama `vibe` la construyó una instancia nueva del agente que recibió
> solo la frase de la guía; las correcciones de `vibe` y las respuestas de
> `/speckit-clarify` las tomó el agente principal siguiendo la guía. El detalle está en
> `bitacora.md` y cada decisión en `DECISIONS.md`.

## 1. Métricas, configuración y qué quedó explícito

**Configuración.** Agente: Claude Code 2.1.287. Modelo: Claude Opus 5.5
(`claude-opus-5-5`) en las dos ramas, con el nivel de razonamiento por defecto (no se
cambió). Archivo de instrucciones: `CLAUDE.md`. Caso de Git: **C** (la carpeta del
curso, `Clase_Programacion_Asistida_de_Apps`, ya es un repositorio; se hizo `git init`
dentro de `divisor_cuenta` y se agregó `divisor_cuenta/` al `.gitignore` de arriba).

| | rama vibe | rama sdd |
|---|---|---|
| Iteraciones | 2 | 0 correcciones (11 pasos del flujo de la guía) |
| Casos de aceptación que cumple (0–6) | 2 | 6 |
| Pruebas automatizadas que pasan | 12/12 propias; las de `sdd` no compilan | 33/33 |
| Archivos en `lib/` | 4 | 11 |
| Líneas de código en `lib/` | 287 | 523 |
| ¿`domain/` depende de Flutter? | no existe `domain/` | No |
| ¿Existe separación `presentation/domain/data`? | No | Sí |
| ¿El agente agregó algo que nadie pidió? | Sí | Solo decisiones documentadas en spec/plan |
| ¿Otra estrategia sin modificar el cálculo existente? | No | Sí |

**Qué enfoque cumplió mejor.** `sdd` cumplió los 6 escenarios; `vibe`, 2 (los casos 1 y
2). `vibe` necesitó 2 iteraciones, las dos para **quitar** cosas: la primera respuesta
tenía modo "por consumo", nombres de personas, botón para copiar un resumen y tema
oscuro; la segunda dejó una línea extra que yo había dicho que no quería ("nada más").
En `sdd` no hubo que corregir código: los dos problemas que aparecieron se corrigieron
en los artefactos (ver pregunta 3).

**Qué quedó explícito en `sdd`:** los textos exactos de los mensajes, que "exacto" es
el centavo más cercano, que "hacia arriba" es al entero siguiente, los dos decimales,
qué pasa con el centavo que sobra, si 0.00 es válido, que el resultado se borra al
editar, los límites de entrada y la arquitectura completa (qué clase hace qué y dónde
vive). Todo está escrito en `spec.md`, `plan.md` y `research.md`.

**Qué tuvo que completar el agente en `vibe`, por su cuenta:** redondear al centavo
**hacia arriba** (por eso 10/3 da $3.34 y no 3.33), recalcular mientras se escribe en
vez de usar un botón "Calcular", los textos de error ("Debe ser al menos 1", "Monto no
válido"), bloquear las letras en el campo del monto, aceptar 0.00 como monto válido,
mostrar el símbolo `$`, limitar las personas a 3 dígitos y la propina a 0–100.

**Tiempo (dato secundario).** `vibe`: unos 16 minutos de trabajo del agente hasta la
versión final, sin llegar nunca a los 6 escenarios. `sdd`: unos 18 minutos hasta tener
los 6 escenarios en verde (13:07 → 13:25 según los commits). El tiempo no basta para
decidir: las dos ramas corrieron en paralelo en la misma máquina, el agente escribió
los artefactos de `sdd` sin pausas para leer, y el tiempo no mide si el resultado
cumple la spec ni si se puede mantener. `vibe` fue "rápido" para producir algo, pero
ese algo no era lo pedido.

## 2. Las pruebas de `sdd` en `vibe` (Parte 10)

**No compilaron.** `flutter test` terminó con `+12 -4: Some tests failed.`: pasaron las
12 pruebas propias de `vibe` y los 4 archivos traídos de `sdd` no pudieron cargarse.
Primer error:

```text
test/division_test.dart:6:8: Error: Error when reading 'lib/data/redondeo_exacto.dart': No such file or directory
import 'package:divisor_cuenta/data/redondeo_exacto.dart';
```

Ese error **no demuestra un fallo funcional**: demuestra una diferencia de
arquitectura y de testabilidad. `vibe` no tiene `lib/data/`, ni `ValidarEntrada`, ni
`CalcularDivision`, ni una interfaz de redondeo; su cálculo es una función
(`sharePerPerson`) que recibe centavos enteros y su validación está mezclada dentro del
widget de la pantalla. Para que las pruebas corrieran habría que reescribir casi todo
`lib/`: crear las capas, separar la validación de la pantalla y agregar las
estrategias.

**Los seis escenarios a mano** (las dos apps corriendo en Chrome):

| # | Esperado | vibe | sdd |
|---|---|---|---|
| 1 | 27.50 | $27.50 ✓ | 27.50 ✓ |
| 2 | 30.00 | $30.00 ✓ | 30.00 ✓ |
| 3 | "Debe haber al menos una persona", sin resultado | "Debe ser al menos 1", sin resultado ✗ | ✓ |
| 4 | "Monto inválido" | no deja escribir "abc"; no hay mensaje ✗ | ✓ |
| 5 | 3.33 | $3.34 ✗ | 3.33 ✓ |
| 6 | 4.00 (hacia arriba) | no existe el modo; $3.34 ✗ | 4.00 ✓ |

En comportamiento, `vibe` funciona para el caso común (1 y 2) y falla en todo lo que la
frase inicial no decía: textos exactos, redondeo y modos.

## 3. Verificaciones de SOLID

**Rama `sdd`: pasa todas.**

```text
$ grep -rn "package:flutter" lib/domain/
(sin salida)
$ grep -rn -E "RedondeoExacto\(\)|RedondeoHaciaArriba\(\)" lib/
lib/main.dart:22:    'Exacto': RedondeoExacto(),
lib/main.dart:23:    'Hacia arriba': RedondeoHaciaArriba(),
$ grep -n -E "is Redondeo|as Redondeo" lib/domain/calcular_division.dart
(sin salida)
$ grep -n -E "toStringAsFixed|inválido|al menos una persona" lib/domain/calcular_division.dart
(sin salida)
```

**Rama `vibe`: no hay capas que verificar.**

```text
$ grep -rn "package:flutter" lib/
lib/main.dart:1:import 'package:flutter/material.dart';
lib/screens/home_screen.dart:3:import 'package:flutter/material.dart';
lib/screens/home_screen.dart:4:import 'package:flutter/services.dart';
$ ls lib/
logic  main.dart  screens
$ grep -rn "package:flutter" lib/domain/
ugrep: warning: lib/domain/: No such file or directory
$ grep -rn -E "RedondeoExacto\(\)|RedondeoHaciaArriba\(\)" lib/
(sin salida, porque no existe ninguna estrategia)
```

Para ser justo: `lib/logic/` de `vibe` no importa Flutter y su función de cálculo no
formatea. Pero nada lo exige, y `home_screen.dart` lee el texto, valida, decide los
mensajes, calcula y dibuja, todo en la misma clase.

**Qué regla de la constitución explica cada diferencia:**

- **Principio II (arquitectura):** "Capas obligatorias: presentation, domain, data" y
  "`lib/domain/` NO importa `package:flutter`". Por eso `sdd` tiene las tres carpetas y
  `vibe` no tiene ninguna.
- **Principio II:** "`lib/main.dart` es el ÚNICO archivo donde se instancian
  implementaciones concretas". Esta regla incluso destapó un falso positivo: el primer
  `grep` también encontraba `const RedondeoExacto();` (el constructor) en `lib/data/`.
  `/speckit-converge` lo convirtió en la tarea T028 y se corrigió quitando el
  constructor explícito.
- **Principio I, SRP:** "La clase que calcula la división NO valida la entrada NI
  formatea el resultado". En `sdd`, `CalcularDivision`, `ValidarEntrada` y
  `FormateadorMoneda` son tres clases; en `vibe`, la validación y los mensajes viven en
  el widget.
- **Principio I, OCP y LSP:** "agregar una nueva regla de redondeo DEBE hacerse creando
  una clase nueva" y "prohibido `is` o `as`". En `sdd` el modo "Hacia arriba" se agregó
  con un archivo nuevo y 5 líneas en `main.dart` (commit `bb1ae56`). En `vibe` no hay
  estrategias: agregar un modo obliga a editar `sharePerPerson` y la pantalla.
- **Principio I, DIP:** "`presentation` NUNCA importa archivos de `data`".
  `grep -rn "data/" lib/presentation/` no devuelve nada en `sdd`.

## 4. Preguntas de `/speckit-clarify`

Hizo tres preguntas. Las dos más relevantes:

1. *"En modo exacto, 10.00 entre 3 da 3.33 por persona y la suma (9.99) no llega al
   total; ¿la app debe hacer algo con ese centavo de diferencia?"* Respuesta: no, solo
   se muestra el monto por persona. **Ambigüedad que destapó:** "cuánto paga cada uno"
   no dice si todos pagan lo mismo o si alguien paga un centavo más para cuadrar. Era
   relevante: es justo lo que hizo diferente a `vibe`, que primero repartió los centavos
   entre personas ($17.53 / $17.53 / $17.52) y al final redondeó todo hacia arriba
   ($3.34).
2. *"¿Un monto total de 0.00 es una entrada válida?"* Respuesta: no, muestra "Monto
   inválido". **Ambigüedad que destapó:** el escenario 4 solo cubre "abc"; no decía qué
   hacer con un número válido pero sin sentido. `vibe` acepta 0.00 y muestra $0.00.

La tercera preguntó si el resultado se borra cuando el usuario edita un campo después de
calcular (respuesta: sí, para no mostrar un resultado que ya no corresponde).

**Quién tomó esas decisiones en `vibe`:** el agente, por su cuenta y sin preguntar.
Nadie le dijo cómo tratar el centavo, ni si 0.00 era válido, ni si usar un botón; lo
decidió en silencio (redondeo hacia arriba, 0.00 válido, cálculo en vivo). En `sdd` las
tres decisiones quedaron escritas en la spec como FR-011, FR-012 y FR-013.

## 5. `git diff vibe sdd --stat`: cosas que nadie pidió

`71 files changed, 7108 insertions(+), 438 deletions(-)`. La mayor parte es
infraestructura de Spec Kit (`.specify/`, `.claude/skills/`) y los artefactos de
`specs/`.

**`vibe` sí agregó cosas que nadie pidió.** Ejemplo concreto: en su primera respuesta
(commit `01340e6`) creó `lib/widgets/items_section.dart` para dividir **por plato**,
con personas por nombre, además de un botón "Copiar resumen" y un reinicio con
confirmación. Nada de eso estaba en la frase. Otro ejemplo que sigue en la versión
final y aparece en el diff: cambió el nombre visible de la app en
`android/app/src/main/AndroidManifest.xml`, `ios/Runner/Info.plist`, `web/index.html`
y `web/manifest.json`.

**`sdd` también agregó cosas que no estaban en mi descripción, pero quedaron escritas y
justificadas:** límites de entrada (monto hasta 1 000 000 000, propina hasta 100 %),
coma como separador decimal, borrar el resultado al editar (vino de clarify), 23
pruebas de casos borde en dos archivos aparte, la regla `public_member_api_docs` para
que `flutter analyze` compruebe la regla de la materia, y quitar la dependencia
`cupertino_icons`, que no se usaba. La diferencia es que cada una se puede rastrear
hasta una línea de `spec.md`, `research.md` o `tasks.md`.

## 6. Otra herramienta de SDD: OpenSpec

**OpenSpec** (de Fission AI) organiza el trabajo por **cambios** y no por features
completas. Cada cambio es una carpeta en `openspec/changes/` con una propuesta, un
diseño, una lista de tareas y "deltas" de la spec (requisitos agregados, modificados o
quitados). El flujo es propuesta → aplicar (`/opsx:apply`) → archivar. Al archivar, los
deltas se fusionan con las specs principales y el cambio pasa a `changes/archive/`.
A diferencia de Spec Kit, no tiene constitución, ni pasos separados de plan, analyze y
converge, y está pensado para proyectos que ya existen.

**Cuándo la preferiría:** para mantener una app que ya está en uso y recibe cambios
pequeños y frecuentes (por ejemplo, agregar el redondeo "al múltiplo de 5" a este
divisor cuando ya está publicado). Ahí conviene ver exactamente qué requisito cambia y
dejar historial. Spec Kit me parece mejor para arrancar algo nuevo, donde la
constitución y el plan fijan la arquitectura desde el principio.

**Una situación real en la que elegiría `vibe`:** un script de una sola vez para
renombrar las 200 fotos de un informe de laboratorio con la fecha y el número de
muestra. Si sale mal, lo veo en segundos, nadie más lo va a mantener y se tira después
de usarlo; escribir una constitución y una spec costaría más que el script.

Fuente: [Fission-AI/OpenSpec en GitHub](https://github.com/Fission-AI/OpenSpec) y su
[documentación de conceptos](https://github.com/Fission-AI/OpenSpec/blob/main/docs/concepts.md).
