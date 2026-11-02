# Bitácora — Deber 2 (SDD: cambiar la tecnología sin cambiar la especificación)

Proyecto Flutter: `divisor_cuenta`, rama `sdd`
Proyecto React: `divisor_cuenta_web` (repositorio aparte)

## Cómo se midió

- **Inicio del cronómetro:** al enviar el primer prompt de `/speckit-plan` de React
  (Parte 5) — 2026-10-09 18:04:39.
- **Primera compilación:** cuando `npm run build` terminó correctamente por primera vez.
- **Fin:** cuando los 6 casos de aceptación pasaron en React
  (`npx vitest run test/division.test.js`) — 2026-10-09 18:13:05.
- **Iteración:** cada mensaje nuevo enviado al agente, después del prompt inicial, para
  pedir una corrección o un cambio. No cuentan los comandos que el agente ejecuta por su
  cuenta.
- **Línea escrita a mano:** línea de código modificada directamente por el estudiante, no
  generada por el agente.

> **Orden real de los hitos.** El enunciado supone que la primera compilación ocurre antes
> de que pasen las pruebas. En esta corrida fue al revés: la suite del domain se ejecutó
> antes de la primera compilación de producción, así que los 6 casos (8 min 26 s) quedaron
> **antes** de `npm run build` (9 min 08 s). Se reporta el orden real, no el supuesto.

## La tabla

| Métrica | Flutter (laboratorio) | React (este deber) |
|---|---:|---:|
| Minutos hasta la primera versión que compila | `no registrado` | **9 min 08 s** |
| **Minutos hasta que pasan los 6 casos** | `no registrado` | **8 min 26 s** |
| Iteraciones con el agente | `no registrado` | **0** (ver nota 1) |
| Líneas de código escritas a mano | `no registrado` | **0** (ver nota 2) |
| Enunciados modificados en la spec | — | **0 de 53 (0 %)** |
| Enunciados modificados en la Constitution | — | **18 de 31 (58,1 %)** |
| Líneas modificadas en el plan | — | **95 añadidas / 58 eliminadas**; **25 de 30 enunciados (83,3 %)** |
| Casos de aceptación que pasan (0–6) | **6 de 6** | **6 de 6** |

En el laboratorio de Flutter no se llevó bitácora, así que esas cuatro casillas van como
`no registrado`. **No se estiman**: inventar un número de Flutter para que la comparación
se vea mejor arruinaría la única métrica honesta que tiene este deber.

Lo único que sí quedó registrado del laboratorio es el historial de Git de la rama `sdd`:
**16 commits**, de `proyecto base de flutter, sin tocar` a
`docs: el modo nuevo tambien necesita su import en main.dart`. Los commits no son
iteraciones (un commit puede agrupar varias, y una iteración puede no dejar commit), así
que se anota como contexto, no como la métrica.

## Notas sobre las métricas que no son comparables

### Nota 1 — Las 0 iteraciones no significan "salió perfecto a la primera"

Con la definición del enunciado (mensajes del estudiante después del prompt inicial), esta
corrida tuvo **0 iteraciones**: todo el deber se ejecutó en una sola sesión del agente, a
partir de una única instrucción. Las correcciones intermedias las detectó y aplicó el
agente por su cuenta, y el enunciado dice explícitamente que eso no cuenta.

Por eso **este número no es comparable** con el de una corrida normal de laboratorio, donde
el estudiante va revisando y corrigiendo. Hubo dos correcciones reales durante el trabajo,
y conviene dejarlas anotadas aunque no cuenten como iteración:

1. `useDivisor` recibía `crearCuenta` como dependencia inyectada. El controlador de Flutter
   importaba `Cuenta` directamente (`presentation -> domain` está permitido), así que se
   corrigió para que la lista de dependencias fuera idéntica a la de Flutter.
2. `test/pantalla.test.jsx` armaba la vista nombrando `redondeoExacto` y
   `redondeoHaciaArriba`, duplicando la composición de `src/main.jsx`. Lo detectó
   `/speckit-converge` (hallazgo G3) y se corrigió exportando `App` desde `src/main.jsx`,
   igual que `pantalla_test.dart` usaba `crearControlador()` de `main.dart`.

### Nota 2 — Las 0 líneas escritas a mano

El código de `src/` y de `test/` lo generó el agente. El enunciado pide que
`test/casosDePrueba.js` lo escriba el estudiante a mano (Parte 7.2); está transcrito
literalmente del enunciado del deber y sus 6 casos coinciden valor por valor con
`test/casos_de_prueba.dart` (verificado con `diff` sobre los valores normalizados).

La **regla de la materia** (principio V de las dos constituciones) dice que el estudiante
debe poder explicar cada función que genere el agente: qué hace, por qué existe, qué
recibe, qué devuelve y qué errores produce. Esa es la casilla que ningún cronómetro mide y
que queda pendiente de la revisión del estudiante.

### Nota 3 — `flutter test` en la rama `sdd`: verificado

La Parte 1 del deber pide comprobar que `flutter test` termina con `All tests passed!` en
la rama `sdd` **antes** de empezar. En la máquina donde se hizo este deber Flutter no
estaba instalado, así que se instaló el SDK (Flutter 3.47.7, Dart 3.13.5 — las mismas
versiones que declara `plan.md`) y se ejecutó:

```console
$ flutter test
00:00 +33: All tests passed!

$ flutter analyze
Analyzing divisor_cuenta...
No issues found! (ran in 8.7s)
```

**33 pruebas en verde y el análisis estático sin issues**, que es exactamente lo que exige
el principio IV de la constitución de Flutter. Las 33 son: el bucle de los 6 escenarios de
aceptación de la spec, la prueba de LSP, 3 de pantalla, 19 de casos borde del domain y 4 de
casos borde de la pantalla.

La tabla de "Verificación de cumplimiento" de la constitución también pasa entera:

```console
$ grep -rn "package:flutter" lib/domain/                                  # sin salida
$ grep -rn -E "RedondeoExacto\(\)|RedondeoHaciaArriba\(\)" lib/
lib/main.dart:22:    'Exacto': RedondeoExacto(),
lib/main.dart:23:    'Hacia arriba': RedondeoHaciaArriba(),               # solo main.dart
$ grep -rn "data/" lib/presentation/                                      # sin salida
$ grep -n -E "is Redondeo|as Redondeo" lib/domain/calcular_division.dart  # sin salida
$ grep -n -E "toStringAsFixed|inválido|al menos una persona" \
       lib/domain/calcular_division.dart                                  # sin salida
$ grep -rniE "api[_-]?key|secret|password|token" lib/                     # sin salida
```

Es decir: la rama de partida cumplía su propia especificación antes de migrar, que es la
precondición que el deber exige para que la comparación tenga sentido.

## Resumen de lo que viajó

| Artefacto | Resultado medido |
|---|---|
| **Especificación** | **0 % modificada.** Diff vacío, mismo SHA-256 (`423d0f60…`). 53 enunciados: 52 QUÉ, 1 MIXTO, 0 CÓMO |
| **Criterios de aceptación** | **100 % conservados.** Los 6 escenarios mantienen entradas, valores esperados y mensajes literales |
| **Casos de prueba** | **Significado conservado, sintaxis nueva.** Mismos valores; `double.nan` → `NaN`, `closeTo` → `toBeCloseTo` |
| **Constitución** | **Principios conservados, redacción adaptada.** 13 idénticas, 17 adaptadas, 1 reemplazada (de 31) |
| **Plan** | **83,3 % de enunciados modificados.** Aquí se concentró todo el cambio de tecnología |
| **Tareas** | **Rehechas.** 35 tareas nuevas + 3 de convergencia |
| **Código** | **Rehecho al 100 %.** 523 líneas de Dart → 555 de JavaScript; 0 líneas reutilizables |

El detalle enunciado por enunciado está en `analisis_spec.md`, y las respuestas a las seis
preguntas en `respuestas.md`, las dos en el repositorio `divisor_cuenta_web`.
