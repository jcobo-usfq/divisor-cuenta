import 'package:divisor_cuenta/domain/estrategia_redondeo.dart';

/// Redondea el monto por persona al centavo más cercano (mitad hacia arriba).
///
/// Existe porque es el modo de redondeo por defecto de la app: 10.00 entre 3
/// da 3.33. Es una implementación de [EstrategiaRedondeo] que puede sustituir
/// a cualquier otra sin que el cálculo lo note (LSP).
class RedondeoExacto implements EstrategiaRedondeo {
  /// Margen que absorbe el ruido de punto flotante: 1.005 se guarda como
  /// 1.00499999..., y sin este margen bajaría a 1.00 en vez de subir a 1.01.
  static const double _tolerancia = 1e-6;

  /// Recibe el [montoPorPersona] sin redondear (finito y mayor o igual a 0) y
  /// devuelve ese monto redondeado al centavo más cercano. Ejemplos:
  /// 3.3333 → 3.33, 27.5 → 27.5, 1.005 → 1.01.
  ///
  /// No lanza errores con entradas válidas.
  @override
  double redondear(double montoPorPersona) =>
      (montoPorPersona * 100 + _tolerancia).round() / 100;
}
