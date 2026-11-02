/// Lo que devuelve el cálculo: cuánto paga cada persona.
///
/// Existe para que el cálculo devuelva un tipo con nombre propio y no un
/// `double` suelto que podría confundirse con el monto total.
class Resultado {
  /// Crea un resultado con el [montoPorPersona] ya redondeado.
  const Resultado(this.montoPorPersona);

  /// Monto que paga cada persona, ya redondeado por la estrategia elegida.
  final double montoPorPersona;
}
