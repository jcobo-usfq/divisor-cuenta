# Contrato: domain

Firmas públicas que usan `presentation/`, `data/` y las pruebas. Cambiar una de estas
firmas obliga a revisar las tres.

```dart
// lib/domain/estrategia_redondeo.dart
abstract interface class EstrategiaRedondeo {
  double redondear(double montoPorPersona);
}

// lib/domain/cuenta.dart
class Cuenta {
  const Cuenta({required double monto, required int personas, required double propina});
  final double monto;
  final int personas;
  final double propina;
}

// lib/domain/resultado.dart
class Resultado {
  const Resultado(double montoPorPersona);
  final double montoPorPersona;
}

// lib/domain/calcular_division.dart
class CalcularDivision {
  const CalcularDivision();
  /// Precondición: la cuenta ya pasó por ValidarEntrada.
  Resultado calcular(Cuenta cuenta, EstrategiaRedondeo estrategia);
}

// lib/domain/validar_entrada.dart
class ValidarEntrada {
  const ValidarEntrada();
  static const String montoInvalido = 'Monto inválido';
  static const String personasInsuficientes = 'Debe haber al menos una persona';
  static const String propinaInvalida = 'Propina inválida';
  /// null = válido; si no, el mensaje exacto del primer error (monto → personas → propina).
  String? validar({required double monto, required int personas, required double propina});
}
```

Implementaciones en `lib/data/` (solo se instancian en `lib/main.dart`):

```dart
class RedondeoExacto implements EstrategiaRedondeo { const RedondeoExacto(); ... }
class RedondeoHaciaArriba implements EstrategiaRedondeo { const RedondeoHaciaArriba(); ... }
```
