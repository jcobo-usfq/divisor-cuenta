import 'dart:math' as math;

import 'package:divisor_cuenta/domain/estrategia_redondeo.dart';

/// Redondea el monto por persona hacia arriba, al entero siguiente.
///
/// Existe para quien prefiere no lidiar con centavos: 10.00 entre 3 da 4.00,
/// y así el grupo siempre cubre la cuenta. Es una implementación de
/// [EstrategiaRedondeo] que se agregó sin editar ninguna clase existente (OCP).
class RedondeoHaciaArriba implements EstrategiaRedondeo {
  /// Recibe el [montoPorPersona] sin redondear (finito y mayor o igual a 0) y
  /// devuelve el entero inmediatamente superior, salvo que ya sea entero:
  /// 3.3333 → 4.0, 30.0 → 30.0.
  ///
  /// Antes de subir, resta una tolerancia mínima para que el ruido de punto
  /// flotante (30.000000000000004) no convierta 30 en 31. La tolerancia crece
  /// con el monto porque el ruido también crece.
  ///
  /// No lanza errores con entradas válidas.
  @override
  double redondear(double montoPorPersona) {
    final tolerancia = math.max(1e-9, montoPorPersona.abs() * 1e-12);
    return (montoPorPersona - tolerancia).ceilToDouble();
  }
}
