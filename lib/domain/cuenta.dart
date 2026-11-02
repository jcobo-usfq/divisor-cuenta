/// Los datos de una cuenta que ya pasaron por `ValidarEntrada`.
///
/// Existe para que el cálculo reciba un solo objeto con todo lo que necesita,
/// en lugar de tres números sueltos. No valida nada: confía en que quien la
/// crea ya comprobó que los valores son válidos.
class Cuenta {
  /// Crea una cuenta con el [monto] total, el número de [personas] y el
  /// porcentaje de [propina] (por ejemplo, 10 significa 10 %).
  ///
  /// No lanza errores; los valores inválidos se filtran antes, en
  /// `ValidarEntrada`.
  const Cuenta({
    required this.monto,
    required this.personas,
    required this.propina,
  });

  /// Monto total de la cuenta, sin propina. Mayor que 0.
  final double monto;

  /// Número de personas que pagan. Al menos 1.
  final int personas;

  /// Porcentaje de propina, entre 0 y 100.
  final double propina;
}
