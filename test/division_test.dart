// Corre y verifica los casos de test/casos_de_prueba.dart contra el domain.
// No usa widgets: CalcularDivision y ValidarEntrada son Dart puro. Se importa
// flutter_test solo como corredor de pruebas, porque el proyecto no admite
// paquetes externos (como package:test).

import 'package:divisor_cuenta/data/redondeo_exacto.dart';
import 'package:divisor_cuenta/data/redondeo_hacia_arriba.dart';
import 'package:divisor_cuenta/domain/calcular_division.dart';
import 'package:divisor_cuenta/domain/cuenta.dart';
import 'package:divisor_cuenta/domain/estrategia_redondeo.dart';
import 'package:divisor_cuenta/domain/validar_entrada.dart';
import 'package:flutter_test/flutter_test.dart';

import 'casos_de_prueba.dart';

/// Envuelve una estrategia real y cuenta cuántas veces se usó. Sirve para
/// comprobar que con un error de validación no se calcula nada.
class _EstrategiaEspia implements EstrategiaRedondeo {
  _EstrategiaEspia(this._real);

  final EstrategiaRedondeo _real;
  int llamadas = 0;

  @override
  double redondear(double montoPorPersona) {
    llamadas++;
    return _real.redondear(montoPorPersona);
  }
}

void main() {
  const validarEntrada = ValidarEntrada();
  const calcularDivision = CalcularDivision();
  final estrategiaPorModo = <String, EstrategiaRedondeo>{
    'exacto': RedondeoExacto(),
    'arriba': RedondeoHaciaArriba(),
  };

  group('escenarios de aceptación de la spec', () {
    for (final caso in casos) {
      test(caso.nombre, () {
        expect(
          (caso.esperado == null) != (caso.errorEsperado == null),
          isTrue,
          reason: 'cada caso espera un resultado o un error, no ambos',
        );
        final espia = _EstrategiaEspia(estrategiaPorModo[caso.modo]!);

        final error = validarEntrada.validar(
          monto: caso.monto,
          personas: caso.personas,
          propina: caso.propina,
        );
        final resultado = error == null
            ? calcularDivision.calcular(
                Cuenta(
                  monto: caso.monto,
                  personas: caso.personas,
                  propina: caso.propina,
                ),
                espia,
              )
            : null;

        if (caso.errorEsperado != null) {
          expect(error, caso.errorEsperado);
          expect(resultado, isNull);
          expect(espia.llamadas, 0, reason: 'con un error no se calcula nada');
        } else {
          expect(error, isNull);
          expect(resultado!.montoPorPersona, closeTo(caso.esperado!, 0.001));
          expect(espia.llamadas, 1);
        }
      });
    }
  });

  test(
    'LSP: la misma CalcularDivision funciona con cualquier EstrategiaRedondeo',
    () {
      const cuenta = Cuenta(monto: 10, personas: 3, propina: 0);
      final intercambiables = <EstrategiaRedondeo>[
        RedondeoExacto(),
        RedondeoHaciaArriba(),
      ];

      final montos = [
        for (final estrategia in intercambiables)
          calcularDivision.calcular(cuenta, estrategia).montoPorPersona,
      ];

      expect(montos[0], closeTo(3.33, 0.001));
      expect(montos[1], closeTo(4.00, 0.001));
    },
  );

  group('la propina no puede superar el 100 %', () {
    test(
      'monto 100, 4 personas y propina 150 da el error de propina máxima',
      () {
        final error = validarEntrada.validar(
          monto: 100,
          personas: 4,
          propina: 150,
        );

        expect(error, 'La propina no puede superar el 100%');
      },
    );

    test(
      'monto 100, 4 personas y propina 100 no da error (el límite sí vale)',
      () {
        final error = validarEntrada.validar(
          monto: 100,
          personas: 4,
          propina: 100,
        );

        expect(error, isNull);
      },
    );
  });
}
