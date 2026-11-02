# Constitución de divisor_cuenta

## Core Principles

### I. Calidad de código (SOLID)

El código DEBE respetar los cinco principios SOLID, verificables así:

- **SRP (una clase, una razón de cambio):** cada clase tiene una sola responsabilidad.
  La clase que calcula la división NO valida la entrada NI formatea el resultado: no
  contiene `toStringAsFixed`, ni textos de mensajes de error, ni lógica de parseo.
- **OCP (abierto a extensión, cerrado a modificación):** agregar una nueva regla de
  redondeo DEBE hacerse creando una clase nueva que implemente la interfaz de redondeo
  y registrándola en `main.dart`. NO se edita ninguna clase existente de `lib/domain/`,
  `lib/data/` ni `lib/presentation/`.
- **LSP (sustitución de Liskov):** cualquier implementación de una interfaz DEBE poder
  sustituir a otra sin que quien la usa pregunte su tipo: prohibido `is` o `as` sobre
  una implementación concreta en el código que consume la interfaz.
- **ISP (segregación de interfaces):** las interfaces son pequeñas; la interfaz de
  redondeo tiene exactamente un método. Ninguna clase depende de métodos que no usa.
- **DIP (inversión de dependencias):** `lib/presentation/` depende de abstracciones de
  `lib/domain/` y NUNCA importa archivos de `lib/data/`.

Razón: estas reglas permiten cambiar o agregar comportamiento tocando un solo lugar, y
probar cada pieza por separado.

### II. Arquitectura por capas

- Capas obligatorias: `lib/presentation/`, `lib/domain/`, `lib/data/`.
- Regla de dependencia: `presentation -> domain <- data`. `domain` no importa de
  ninguna de las otras dos capas; `data` solo importa de `domain`.
- `lib/domain/` NO importa `package:flutter` (es Dart puro y se prueba sin Flutter).
- `lib/main.dart` es el ÚNICO archivo donde se instancian implementaciones concretas de
  `lib/data/` (por ejemplo, `RedondeoExacto()`).

Razón: el núcleo del cálculo queda aislado del framework y de los detalles concretos.

### III. Seguridad

- Nunca se guardan secretos, contraseñas, tokens ni API keys en el repositorio.

Razón: todo lo que entra al repositorio se considera público.

### IV. Calidad y pruebas

- Toda funcionalidad crítica (cálculo, validación de entrada y redondeo) tiene pruebas
  automatizadas.
- Cada escenario de aceptación de cada spec se convierte en al menos una prueba
  ejecutable cuyo nombre identifica el escenario.
- `flutter test` y `flutter analyze` DEBEN terminar sin fallos ni issues antes de dar
  una tarea por terminada.

Razón: un criterio de aceptación que no se ejecuta no se puede demostrar.

### V. Regla de la materia

- Toda función generada por el agente debe poder explicarla el estudiante: qué hace,
  por qué existe, qué recibe, qué devuelve y qué errores produce.
- Para que sea comprobable, toda clase y todo miembro público de `lib/` lleva un
  comentario de documentación `///` que responde esas cinco preguntas cuando aplican.

Razón: el estudiante es responsable del código que entrega, lo haya escrito o no.

## Verificación de cumplimiento

Cada regla anterior se comprueba con un comando, ejecutado desde la raíz del proyecto:

| Regla | Comando | Resultado esperado |
|---|---|---|
| II: domain sin Flutter | `grep -rn "package:flutter" lib/domain/` | sin salida |
| II/DIP: instancias concretas solo en main | `grep -rn -E "RedondeoExacto\(\)\|RedondeoHaciaArriba\(\)" lib/` | solo `lib/main.dart` |
| DIP: presentation no importa data | `grep -rn "data/" lib/presentation/` | sin salida |
| LSP/OCP: sin preguntar el tipo | `grep -n -E "is Redondeo\|as Redondeo" lib/domain/calcular_division.dart` | sin salida |
| SRP: el cálculo no formatea ni valida | `grep -n -E "toStringAsFixed\|inválido\|al menos una persona" lib/domain/calcular_division.dart` | sin salida |
| III: sin secretos | `grep -rniE "api[_-]?key\|secret\|password\|token" lib/` | sin salida |
| IV: pruebas | `flutter test` | todas en verde |
| IV/V: análisis y documentación | `flutter analyze` (con `public_member_api_docs`) | `No issues found!` |

## Governance

- Esta constitución está por encima de cualquier otra práctica del proyecto. Spec, plan
  y tareas DEBEN cumplirla; `/speckit-analyze` reporta cualquier contradicción.
- Si una verificación falla, se corrige desde el artefacto que define la regla
  incumplida (spec, plan o constitución), no parchando el código a mano.
- Las enmiendas se documentan en este archivo y suben la versión: MAJOR si se elimina o
  redefine un principio, MINOR si se agrega uno, PATCH si solo se aclara la redacción.

**Version**: 1.0.0 | **Ratified**: 2026-10-01 | **Last Amended**: 2026-10-01
