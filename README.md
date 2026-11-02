# divisor_cuenta

App Flutter de una sola pantalla para dividir la cuenta de un restaurante. Escribes el
monto total, el número de personas y el porcentaje de propina, eliges el modo de
redondeo (exacto o hacia arriba) y al tocar **Calcular** ves cuánto paga cada persona,
con dos decimales. Funciona sin conexión: no usa red ni guarda datos.

Proyecto de Programación Asistida de Aplicaciones (USFQ). La spec, el plan y las tareas están en
[`specs/001-divisor-cuenta/`](specs/001-divisor-cuenta/) y las reglas del proyecto en
[`.specify/memory/constitution.md`](.specify/memory/constitution.md). Las entregas anteriores
están en [`entregas/`](entregas/).

## Requisitos

- Flutter estable (probado con Flutter 3.47 y Dart 3.13).
- Para Android: Android Studio con el Android SDK instalado.
- Para iOS o macOS: Xcode.
- No hace falta ninguna API key ni cuenta.

## Instalar

```bash
git clone <url-del-repositorio>
cd divisor_cuenta
flutter pub get
```

## Correr

```bash
flutter run              # elige el dispositivo de la lista
flutter run -d chrome    # en el navegador
flutter run -d macos     # como app de escritorio en una Mac
```

## Probar

```bash
flutter test                       # 33 pruebas
flutter test --reporter expanded   # con el nombre de cada caso
flutter analyze                    # debe decir "No issues found!"
```

| Archivo | Qué prueba |
|---|---|
| `test/casos_de_prueba.dart` | los 6 escenarios de la spec, como datos |
| `test/division_test.dart` | recorre esos 6 casos contra el domain, más una prueba de LSP |
| `test/pantalla_test.dart` | 3 pruebas de widget: 27.50, cero personas y "abc" |
| `test/casos_borde_test.dart` | límites, ruido de punto flotante, coma decimal, errores |
| `test/pantalla_borde_test.dart` | modo "Hacia arriba", borrar el resultado al editar, campo de personas |

### Verificar la arquitectura (SOLID)

```bash
grep -rn "package:flutter" lib/domain/                                     # sin salida
grep -rn -E "RedondeoExacto\(\)|RedondeoHaciaArriba\(\)" lib/              # solo lib/main.dart
grep -n -E "is Redondeo|as Redondeo" lib/domain/calcular_division.dart     # sin salida
grep -n -E "toStringAsFixed|inválido|al menos una persona" lib/domain/calcular_division.dart  # sin salida
grep -rn "data/" lib/presentation/                                         # sin salida
```

## Estructura

```text
lib/
├── domain/          Dart puro: Cuenta, Resultado, EstrategiaRedondeo,
│                    CalcularDivision, ValidarEntrada
├── data/            RedondeoExacto, RedondeoHaciaArriba
├── presentation/    DivisorController, FormateadorMoneda, PantallaDivisor
└── main.dart        único lugar donde se crean las piezas concretas
```

Regla de dependencia: `presentation -> domain <- data`.

## Agregar un modo de redondeo

1. Crea `lib/data/redondeo_multiplo_cinco.dart` con una clase que implemente
   `EstrategiaRedondeo` (un solo método: `redondear`).
2. En `lib/main.dart`, importa el archivo nuevo y agrega una entrada al mapa de
   `crearControlador()`: `'Múltiplo de 5': RedondeoMultiploCinco(),`

No hace falta tocar ningún otro archivo: la pantalla dibuja un botón por cada modo del
mapa.

## Reglas de entrada

| Entrada | Válido | Si no |
|---|---|---|
| Monto | número mayor que 0 y hasta 1 000 000 000; acepta coma o punto | "Monto inválido" |
| Personas | entero desde 1 (el campo solo admite dígitos, hasta 6) | "Debe haber al menos una persona" |
| Propina | de 0 a 100; vacía = 0 | "Propina inválida" |
