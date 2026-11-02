# Implementation Plan: Divisor de cuenta

**Branch**: `sdd` | **Date**: 2026-10-01 | **Spec**: [spec.md](spec.md)

**Input**: Feature specification from `/specs/001-divisor-cuenta/spec.md`

**Note**: This template is filled in by the `/speckit-plan` command; its definition describes the execution workflow.

## Summary

Pantalla única en Flutter donde el usuario escribe monto, personas y propina, elige un modo
de redondeo y toca "Calcular" para ver cuánto paga cada persona con dos decimales. El
cálculo vive en un `domain/` de Dart puro (Cuenta, Resultado, CalcularDivision,
ValidarEntrada y la interfaz EstrategiaRedondeo); las dos reglas de redondeo viven en
`data/`; la pantalla, el controlador y el formateo viven en `presentation/`; `main.dart`
es el único lugar donde se crean las implementaciones concretas.

Entrada del usuario para este plan:

> Flutter con el SDK estable, sin paquetes externos. Estado local con setState (es una
> sola pantalla). Capas, respetando la constitución: domain/: Cuenta, Resultado,
> CalcularDivision, ValidarEntrada, y la interfaz abstracta EstrategiaRedondeo (un solo
> método); data/: RedondeoExacto y RedondeoHaciaArriba (implementan la interfaz);
> presentation/: DivisorController (recibe sus dependencias por constructor),
> FormateadorMoneda, PantallaDivisor; main.dart: único punto de composición.

## Technical Context

**Language/Version**: Dart 3.13 con Flutter 3.47 (canal stable)

**Primary Dependencies**: solo el SDK de Flutter (`flutter`, `flutter_test`, `flutter_lints`
que ya trae la plantilla). Sin paquetes externos.

**Storage**: N/A (sin base de datos ni archivos; todo vive en memoria mientras la pantalla
está abierta)

**Testing**: `flutter test` con `package:test` vía `flutter_test` (pruebas de domain sin
widgets) y `testWidgets` (pruebas de la pantalla)

**Target Platform**: Android e iOS (también corre en macOS y web porque la plantilla
incluye esas plataformas)

**Project Type**: mobile-app (una sola pantalla)

**Performance Goals**: resultado visible en menos de 1 s después de tocar "Calcular"
(SC-003); el cálculo es una operación aritmética, muy por debajo de ese límite

**Constraints**: sin conexión (FR-009), sin paquetes externos (CLAUDE.md), `lib/domain/`
sin `package:flutter` (constitución II)

**Scale/Scope**: 1 pantalla, 3 campos, 2 modos de redondeo, 10 archivos en `lib/`

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Principio | Cómo lo cumple este plan | Estado |
|---|---|---|
| I. SRP | `CalcularDivision` solo calcula; `ValidarEntrada` solo valida; `FormateadorMoneda` solo formatea; `PantallaDivisor` solo dibuja; `DivisorController` solo coordina | PASA |
| I. OCP | un modo nuevo = clase nueva en `data/` + una línea en el mapa de `main.dart`; el controlador recibe el mapa y la pantalla lo recorre | PASA |
| I. LSP | `CalcularDivision.calcular(cuenta, estrategia)` usa solo `estrategia.redondear(...)`, sin `is`/`as` | PASA |
| I. ISP | `EstrategiaRedondeo` tiene un único método: `redondear` | PASA |
| I. DIP | `presentation/` importa solo `domain/`; recibe las estrategias como `EstrategiaRedondeo` | PASA |
| II. Capas | `presentation -> domain <- data`; `domain/` no importa Flutter; concretos solo en `main.dart` | PASA |
| III. Seguridad | no hay secretos, red ni almacenamiento | PASA |
| IV. Pruebas | cada escenario de aceptación tiene su prueba (`test/casos_de_prueba.dart` + `test/division_test.dart`, y `test/pantalla_test.dart` para la UI) | PASA |
| V. Regla de la materia | `public_member_api_docs` activado en `analysis_options.yaml`; cada miembro público lleva `///` | PASA |

Re-evaluación tras la Fase 1 (diseño): sin cambios, sigue pasando. No hay violaciones que
justificar en Complexity Tracking.

## Project Structure

### Documentation (this feature)

```text
specs/001-divisor-cuenta/
├── plan.md              # este archivo
├── research.md          # Fase 0: decisiones técnicas
├── data-model.md        # Fase 1: entidades y reglas de validación
├── quickstart.md        # Fase 1: cómo comprobar que funciona
├── contracts/
│   ├── domain.md        # contrato de las clases del domain
│   └── pantalla.md      # contrato de la pantalla (campos, textos, keys)
├── checklists/
│   └── requirements.md  # checklist de calidad de la spec
└── tasks.md             # Fase 2 (/speckit-tasks)
```

### Source Code (repository root)

```text
lib/
├── domain/
│   ├── cuenta.dart                    entidad: monto, personas, propina
│   ├── resultado.dart                 entidad: monto por persona
│   ├── estrategia_redondeo.dart       interfaz con un único método (ISP)
│   ├── calcular_division.dart         caso de uso: solo calcula (SRP)
│   └── validar_entrada.dart           caso de uso: solo valida (SRP)
├── data/
│   ├── redondeo_exacto.dart           implementa EstrategiaRedondeo (OCP/LSP)
│   └── redondeo_hacia_arriba.dart     implementa EstrategiaRedondeo (OCP/LSP)
├── presentation/
│   ├── divisor_controller.dart        coordina; recibe dependencias por constructor (DIP)
│   ├── formateador_moneda.dart        solo formatea a dos decimales (SRP)
│   └── pantalla_divisor.dart          solo dibuja (StatefulWidget + setState)
└── main.dart                          único punto de composición

test/
├── casos_de_prueba.dart               los 6 escenarios de la spec (lo escribe el estudiante)
├── division_test.dart                 recorre los casos + prueba de LSP (sin Flutter)
└── pantalla_test.dart                 3 pruebas de widget
```

**Structure Decision**: una sola app Flutter con tres capas dentro de `lib/`, tal como la
constitución exige. `android/` e `ios/` no se tocan (CLAUDE.md). El `widget_test.dart`
de la plantilla se reemplaza por las pruebas de arriba porque prueba el contador que ya
no existe.

## Complexity Tracking

Sin violaciones de la constitución: no aplica.
