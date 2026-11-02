---

description: "Lista de tareas para implementar el divisor de cuenta"
---

# Tasks: Divisor de cuenta

**Input**: Design documents from `/specs/001-divisor-cuenta/`

**Prerequisites**: plan.md, spec.md, research.md, data-model.md, contracts/

**Tests**: la constitución (principio IV) exige que cada escenario de aceptación sea una
prueba ejecutable, así que hay tareas de prueba. `CLAUDE.md` prohíbe tocar `test/` sin
que el estudiante lo pida: las pruebas van en la Fase 6 y se ejecutan cuando el
estudiante las pide (Parte 9 de la guía).

**Organization**: tareas agrupadas por historia de usuario.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: se puede hacer en paralelo (archivo distinto, sin dependencias pendientes)
- **[Story]**: historia a la que pertenece (US1, US2, US3)

## Path Conventions

- App Flutter única: `lib/domain/`, `lib/data/`, `lib/presentation/`, `lib/main.dart`,
  `test/` en la raíz del repositorio.

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: dejar la estructura y las herramientas listas.

- [X] T001 Crear las carpetas `lib/domain/`, `lib/data/` y `lib/presentation/`
- [X] T002 [P] Activar la regla `public_member_api_docs` en `analysis_options.yaml` (constitución V)
- [X] T003 [P] Quitar la dependencia no usada `cupertino_icons` y poner una descripción real en `pubspec.yaml` (CLAUDE.md: sin paquetes externos)
- [X] T004 Borrar `test/widget_test.dart` de la plantilla: prueba el contador que ya no existe y, en cuanto cambie `main.dart`, rompe `flutter analyze` y `flutter test` (constitución IV). CLAUDE.md exige permiso para tocar `test/`: autorizado por el estudiante en la remediación de `/speckit-analyze` (hallazgo D1)

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: entidades e interfaz del domain que usan todas las historias.

**⚠️ CRITICAL**: ninguna historia puede empezar antes de terminar esta fase.

- [X] T005 [P] Crear la entidad `Cuenta` (campos `monto` double, `personas` int, `propina` double, inmutable, `const`) en `lib/domain/cuenta.dart`
- [X] T006 [P] Crear la entidad `Resultado` (campo `montoPorPersona` double) en `lib/domain/resultado.dart`
- [X] T007 [P] Crear la interfaz `EstrategiaRedondeo` con un único método `double redondear(double montoPorPersona)` en `lib/domain/estrategia_redondeo.dart`

**Regla para todas las tareas de código**: cada clase y miembro público lleva `///` con qué hace, por qué existe, qué recibe, qué devuelve y qué errores produce (constitución V; lo verifica `public_member_api_docs`).

**Checkpoint**: domain base listo; `grep -rn "package:flutter" lib/domain/` sin salida.

---

## Phase 3: User Story 1 - Calcular cuánto paga cada persona (Priority: P1) 🎯 MVP

**Goal**: con monto, personas y propina válidos, la pantalla muestra el monto por
persona con dos decimales (modo exacto).

**Independent Test**: escenarios 1, 2 y 5 de `test/casos_de_prueba.dart` y la prueba de
widget 1 (100, 4, 10 → "27.50").

- [X] T008 [P] [US1] Implementar `RedondeoExacto` ("al centavo más cercano, mitad hacia arriba", con tolerancia `1e-6`, research R3) en `lib/data/redondeo_exacto.dart`
- [X] T009 [P] [US1] Implementar `CalcularDivision.calcular(Cuenta, EstrategiaRedondeo)` con `monto × (100 + propina) / (100 × personas)` y sin `is`/`as`, sin validar ni formatear, en `lib/domain/calcular_division.dart`
- [X] T010 [P] [US1] Implementar `FormateadorMoneda.formatear(double)` → texto con exactamente dos decimales en `lib/presentation/formateador_moneda.dart`
- [X] T011 [US1] Implementar `DivisorController` (recibe `ValidarEntrada`, `CalcularDivision`, `FormateadorMoneda` y `Map<String, EstrategiaRedondeo>` por constructor; expone `modos`, `modoSeleccionado`, `resultado`, `error`, `seleccionarModo`, `calcular`, `limpiar`) en `lib/presentation/divisor_controller.dart` (depende de T009, T010)
- [X] T012 [US1] Implementar `PantallaDivisor` (StatefulWidget con setState; campos `campoMonto`, `campoPersonas`, `campoPropina`; `SegmentedButton` `selectorModo` con un segmento por cada modo del mapa; `botonCalcular`; `Text` `resultado` bajo la etiqueta "Cada persona paga") según `contracts/pantalla.md` en `lib/presentation/pantalla_divisor.dart` (depende de T011)
- [X] T013 [US1] Reescribir `lib/main.dart` como único punto de composición: `crearControlador()` con el mapa `{'Exacto': RedondeoExacto()}` y `runApp(MaterialApp(home: PantallaDivisor(...)))` (depende de T008, T012)

**Nota (analyze F2)**: el selector de modo se construye ya en US1 aunque solo haya un modo; así US3 agrega el segundo modo sin editar la pantalla (OCP).

**Checkpoint**: la app calcula 27.50, 30.00 y 3.33.

---

## Phase 4: User Story 2 - Aviso claro con entrada inválida (Priority: P2)

**Goal**: entradas inválidas muestran un único mensaje exacto y ningún resultado.

**Independent Test**: escenarios 3 y 4 de `test/casos_de_prueba.dart` y las pruebas de
widget 2 y 3.

- [X] T014 [P] [US2] Implementar `ValidarEntrada.validar(monto, personas, propina)` → `String?` con las reglas de `data-model.md`: monto "finito, > 0 y ≤ 1 000 000 000" → "Monto inválido"; personas "≥ 1" → "Debe haber al menos una persona"; propina "finito entre 0 y 100" → "Propina inválida"; orden monto → personas → propina; en `lib/domain/validar_entrada.dart`
- [X] T015 [US2] En `DivisorController.calcular`, convertir el texto (coma → punto; monto vacío o no numérico → `double.nan`; propina vacía → 0; personas vacías → 0), validar con `ValidarEntrada` y NO calcular si hay error; el error borra el resultado anterior (FR-007) en `lib/presentation/divisor_controller.dart`
- [X] T016 [US2] En `PantallaDivisor`: mostrar el `Text` `mensajeError`; campo de personas solo dígitos (máximo 6); cualquier cambio en un campo o en el modo llama a `limpiar()` (FR-011) en `lib/presentation/pantalla_divisor.dart`
- [X] T017 [US2] Agregar `ValidarEntrada()` a `crearControlador()` en `lib/main.dart`

**Checkpoint**: "Debe haber al menos una persona" y "Monto inválido" aparecen sin resultado.

---

## Phase 5: User Story 3 - Redondear hacia arriba (Priority: P3)

**Goal**: el usuario elige "Hacia arriba" y ve el monto por persona redondeado al entero
superior.

**Independent Test**: escenario 6 (10, 3, 0, arriba → 4.00) y la prueba de LSP.

- [X] T018 [P] [US3] Implementar `RedondeoHaciaArriba` ("al entero superior, salvo que ya sea entero", tolerancia `max(1e-9, |valor| × 1e-12)`, research R4) en `lib/data/redondeo_hacia_arriba.dart`
- [X] T019 [US3] Registrar `'Hacia arriba': RedondeoHaciaArriba()` en el mapa de `crearControlador()` en `lib/main.dart`. Esta historia NO debe editar ningún otro archivo de `lib/` (prueba de OCP).

**Checkpoint**: las tres historias funcionan.

---

## Phase 6: Pruebas ejecutables (cuando el estudiante las pida, Parte 9)

- [X] T020 Escribir a mano `test/casos_de_prueba.dart` con los 6 escenarios de la spec (lo hace el estudiante, tal cual la guía 9.1)
- [X] T021 [P] Crear `test/division_test.dart`: un `test()` por caso (con `ValidarEntrada` y `CalcularDivision`, `closeTo(esperado, 0.001)`) y una prueba aparte de LSP con la misma instancia de `CalcularDivision` usando `RedondeoExacto` y `RedondeoHaciaArriba`, sin widgets
- [X] T022 [P] Crear `test/pantalla_test.dart` con 3 pruebas de widget: "27.50"; "Debe haber al menos una persona" sin resultado; "Monto inválido"

---

## Phase 7: Polish & Cross-Cutting Concerns

- [X] T023 `dart format lib test` y `flutter analyze` sin issues
- [X] T024 Correr los comandos de "Verificación de cumplimiento" de `.specify/memory/constitution.md`
- [X] T025 Validar a mano los 6 escenarios de `quickstart.md` corriendo la app, y comprobar que el resultado aparece en menos de 1 s (SC-003)
- [X] T026 [P] Reemplazar `README.md` de la plantilla por uno que explique qué es, cómo instalar, correr y probar
- [X] T027 Construir la app (`flutter build apk --debug`; si no hay Android SDK, `flutter build macos --debug` y dejar el APK como paso pendiente)

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Fase 1)**: sin dependencias.
- **Foundational (Fase 2)**: depende de la Fase 1; bloquea todas las historias.
- **US1 (Fase 3)**: depende de la Fase 2.
- **US2 (Fase 4)**: depende de la Fase 2; toca `divisor_controller.dart` y
  `pantalla_divisor.dart`, así que va después de US1.
- **US3 (Fase 5)**: depende de la Fase 2 y de T013 (el mapa en `main.dart`).
- **Pruebas (Fase 6)**: T021 y T022 dependen de T020 y de las Fases 3-5.
- **Polish (Fase 7)**: al final.

### Parallel Opportunities

- T002 y T003; T005, T006 y T007; T008, T009 y T010; T014 con T018; T021 con T022.

## Parallel Example: User Story 1

```bash
Task: "Implementar RedondeoExacto en lib/data/redondeo_exacto.dart"
Task: "Implementar CalcularDivision en lib/domain/calcular_division.dart"
Task: "Implementar FormateadorMoneda en lib/presentation/formateador_moneda.dart"
```

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Fases 1 y 2.
2. Fase 3 (US1) → la app ya divide la cuenta.
3. Validar US1 con los escenarios 1, 2 y 5.

### Incremental Delivery

1. US1 → MVP.
2. US2 → validación y mensajes.
3. US3 → segundo modo de redondeo, agregado sin editar clases existentes.

## Notes

- Total: 27 tareas (T001-T027).
- Commit después de cada fase.
- T025: validado en Chrome (build web servido en localhost) con los 6 escenarios; se alineó
  el formulario arriba porque centrado verticalmente quedaba a media pantalla.
- T027: `flutter build apk --debug` falla porque esta Mac no tiene Android SDK
  ("No Android SDK found"); `flutter build macos --debug` construye bien. El APK queda
  como paso pendiente del estudiante.
- Hallazgo durante implement: T011 listaba `ValidarEntrada` en el constructor del
  controlador, pero esa clase no existe hasta T014 (US2). Se implementó T011 sin ella y
  se agregó en T015. `/speckit-analyze` no lo detectó.

---

## Phase 8: Convergence

- [X] T028 CRITICAL: quitar los constructores `const` explícitos de `RedondeoExacto` y `RedondeoHaciaArriba` (y el `const` del mapa en `lib/main.dart`) para que `grep -rn -E "RedondeoExacto\(\)|RedondeoHaciaArriba\(\)" lib/` devuelva solo `lib/main.dart`; hoy también devuelve `lib/data/redondeo_exacto.dart:10` y `lib/data/redondeo_hacia_arriba.dart:12` per Constitution II (contradicts)
