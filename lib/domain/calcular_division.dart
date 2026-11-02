import 'package:divisor_cuenta/domain/cuenta.dart';
import 'package:divisor_cuenta/domain/estrategia_redondeo.dart';
import 'package:divisor_cuenta/domain/resultado.dart';

/// Caso de uso: calcula cuánto paga cada persona.
///
/// Existe para que la fórmula viva en un solo lugar. Solo calcula: no revisa
/// la entrada ni le da formato al número (SRP). Tampoco pregunta qué tipo de
/// estrategia recibe: cualquier [EstrategiaRedondeo] sirve (LSP/OCP).
class CalcularDivision {
  /// Crea el caso de uso. No guarda estado, por eso es `const`.
  const CalcularDivision();

  /// El 100 % de la cuenta: la propina es un porcentaje sobre esta base.
  static const double _cuentaCompleta = 100;

  /// Recibe una [cuenta] ya revisada por `ValidarEntrada` y la [estrategia]
  /// de redondeo elegida, y devuelve el [Resultado] con el monto por persona:
  /// `monto × (100 + propina) / (100 × personas)`, redondeado por la
  /// estrategia. Multiplica antes de dividir para no arrastrar el error de
  /// representar 1.1 en binario.
  ///
  /// No lanza errores con una cuenta válida. Con 0 personas el resultado no
  /// tiene sentido; por eso la cuenta debe venir revisada.
  Resultado calcular(Cuenta cuenta, EstrategiaRedondeo estrategia) {
    final montoSinRedondear =
        cuenta.monto *
        (_cuentaCompleta + cuenta.propina) /
        (_cuentaCompleta * cuenta.personas);
    return Resultado(estrategia.redondear(montoSinRedondear));
  }
}
