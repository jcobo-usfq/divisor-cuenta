/// Una regla para redondear el monto que paga cada persona.
///
/// Existe para que agregar un modo de redondeo nuevo sea crear una clase que
/// implemente esta interfaz, sin editar el cálculo (OCP). Tiene un único
/// método para que nadie dependa de algo que no usa (ISP).
abstract interface class EstrategiaRedondeo {
  /// Recibe el [montoPorPersona] sin redondear (finito y mayor o igual a 0) y
  /// devuelve el monto redondeado según la regla de la implementación.
  ///
  /// No lanza errores con entradas válidas.
  double redondear(double montoPorPersona);
}
