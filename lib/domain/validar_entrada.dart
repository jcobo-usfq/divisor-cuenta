/// Caso de uso: decide si los números que ingresó el usuario permiten
/// calcular, y si no, qué mensaje mostrar.
///
/// Existe para que todas las reglas de entrada y todos los mensajes de error
/// vivan en un solo lugar. Solo valida: no calcula ni formatea (SRP).
class ValidarEntrada {
  /// Crea el validador. No guarda estado, por eso es `const`.
  const ValidarEntrada();

  /// Mensaje cuando el monto no es un número, es 0 o menos, o pasa del máximo.
  static const String montoInvalido = 'Monto inválido';

  /// Mensaje cuando hay menos de una persona.
  static const String personasInsuficientes = 'Debe haber al menos una persona';

  /// Mensaje cuando la propina no es un número o es negativa.
  static const String propinaInvalida = 'Propina inválida';

  /// Mensaje cuando la propina pasa de [propinaMaxima].
  static const String propinaExcedida = 'La propina no puede superar el 100%';

  /// Monto máximo aceptado. Con este tope, el monto por persona cabe en las
  /// cifras exactas de un `double` y los centavos siempre son correctos.
  static const double montoMaximo = 1000000000;

  /// Propina máxima aceptada, en porcentaje. Una propina mayor que la cuenta
  /// se toma como error de tipeo.
  static const double propinaMaxima = 100;

  /// Recibe el [monto] total (`double.nan` si el usuario escribió algo que no
  /// es un número), el número de [personas] y el porcentaje de [propina].
  ///
  /// Devuelve `null` si los tres son válidos. Si no, devuelve el mensaje del
  /// primer error, revisando en este orden: monto, personas, propina.
  ///
  /// No lanza errores: un dato inválido es un resultado esperado, no una
  /// excepción.
  String? validar({
    required double monto,
    required int personas,
    required double propina,
  }) {
    if (!monto.isFinite || monto <= 0 || monto > montoMaximo) {
      return montoInvalido;
    }
    if (personas < 1) {
      return personasInsuficientes;
    }
    if (!propina.isFinite || propina < 0) {
      return propinaInvalida;
    }
    if (propina > propinaMaxima) {
      return propinaExcedida;
    }
    return null;
  }
}
