# divisor_cuenta

App Flutter de una sola pantalla para dividir una cuenta entre varias personas.

## Estructura

- `lib/presentation/`: widgets, controlador y formato para mostrar.
- `lib/domain/`: entidades, casos de uso e interfaces (Dart puro).
- `lib/data/`: implementaciones concretas de las interfaces del domain.
- Regla de dependencia: `presentation -> domain <- data`.
- `lib/domain/` NO importa nada de `package:flutter`.

## Estándares

- Null safety en todo el código.
- Nombres de clases, métodos y variables en español.
- Sin paquetes externos: solo el SDK de Flutter y Dart.

## Qué NO tocar

- No modifiques `test/` sin que te lo pida.
- No agregues dependencias al `pubspec.yaml` sin avisar antes.
- No toques `android/` ni `ios/`.

## Comandos

- `flutter pub get`: instala dependencias.
- `flutter run`: corre la app.
- `flutter analyze`: análisis estático; debe quedar sin issues.
- `flutter test`: corre las pruebas.
