/// Convierte un monto en el texto que se muestra en pantalla.
///
/// Existe para que el formato viva en un solo lugar y el cálculo no tenga que
/// saber cómo se ve el número (SRP).
class FormateadorMoneda {
  /// Crea el formateador. No guarda estado, por eso es `const`.
  const FormateadorMoneda();

  /// Recibe un [monto] finito y devuelve el texto con exactamente dos
  /// decimales y punto decimal, sin símbolo de moneda: 27.5 → "27.50".
  ///
  /// No lanza errores.
  String formatear(double monto) => monto.toStringAsFixed(2);
}
