// test/casos_de_prueba.dart
// Los casos salen de la spec. Si cambia la spec, cambia este archivo.

class CasoDivision {
  final String nombre;
  final double monto;
  final int personas;
  final double propina;
  final String modo;          // 'exacto' o 'arriba'
  final double? esperado;     // null = se espera un error
  final String? errorEsperado;

  const CasoDivision({
    required this.nombre,
    required this.monto,
    required this.personas,
    required this.propina,
    required this.modo,
    this.esperado,
    this.errorEsperado,
  });
}

const casos = <CasoDivision>[
  CasoDivision(
    nombre: '1. reparto normal',
    monto: 100.00, personas: 4, propina: 10, modo: 'exacto',
    esperado: 27.50,
  ),
  CasoDivision(
    nombre: '2. sin propina',
    monto: 90.00, personas: 3, propina: 0, modo: 'exacto',
    esperado: 30.00,
  ),
  CasoDivision(
    nombre: '3. cero personas',
    monto: 50.00, personas: 0, propina: 0, modo: 'exacto',
    errorEsperado: 'Debe haber al menos una persona',
  ),
  CasoDivision(
    nombre: '4. monto no numerico',
    monto: double.nan, personas: 4, propina: 0, modo: 'exacto',
    errorEsperado: 'Monto inválido',
  ),
  CasoDivision(
    nombre: '5. redondeo exacto',
    monto: 10.00, personas: 3, propina: 0, modo: 'exacto',
    esperado: 3.33,
  ),
  CasoDivision(
    nombre: '6. redondeo hacia arriba',
    monto: 10.00, personas: 3, propina: 0, modo: 'arriba',
    esperado: 4.00,
  ),
];
