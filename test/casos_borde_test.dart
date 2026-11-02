// Casos borde de la spec (sección Edge Cases) que no están entre los 6
// escenarios de aceptación. Sin widgets.

import 'package:divisor_cuenta/data/redondeo_exacto.dart';
import 'package:divisor_cuenta/data/redondeo_hacia_arriba.dart';
import 'package:divisor_cuenta/domain/calcular_division.dart';
import 'package:divisor_cuenta/domain/cuenta.dart';
import 'package:divisor_cuenta/domain/estrategia_redondeo.dart';
import 'package:divisor_cuenta/domain/validar_entrada.dart';
import 'package:divisor_cuenta/presentation/divisor_controller.dart';
import 'package:divisor_cuenta/presentation/formateador_moneda.dart';
import 'package:flutter_test/flutter_test.dart';

DivisorController _nuevoControlador() => DivisorController(
  validarEntrada: const ValidarEntrada(),
  calcularDivision: const CalcularDivision(),
  formateador: const FormateadorMoneda(),
  estrategias: {
    'Exacto': RedondeoExacto(),
    'Hacia arriba': RedondeoHaciaArriba(),
  },
);

void main() {
  const validar = ValidarEntrada();

  group('ValidarEntrada', () {
    String? validarMonto(double monto) =>
        validar.validar(monto: monto, personas: 2, propina: 10);

    test('monto 0, negativo, infinito o mayor al máximo es inválido', () {
      for (final monto in [
        0.0,
        -5.0,
        double.infinity,
        double.negativeInfinity,
        double.nan,
        1000000000.01,
      ]) {
        expect(validarMonto(monto), 'Monto inválido', reason: '$monto');
      }
    });

    test('el monto máximo y montos pequeños son válidos', () {
      expect(validarMonto(1000000000), isNull);
      expect(validarMonto(0.01), isNull);
    });

    test('personas negativas piden al menos una persona', () {
      expect(
        validar.validar(monto: 10, personas: -3, propina: 0),
        'Debe haber al menos una persona',
      );
    });

    // Mayor a 100 ya no es "Propina inválida": tiene su propio mensaje
    // (ver 'la propina no puede superar el 100 %' en division_test.dart).
    test('propina negativa o no numérica es inválida', () {
      for (final propina in [-1.0, double.nan, double.infinity]) {
        expect(
          validar.validar(monto: 10, personas: 2, propina: propina),
          'Propina inválida',
          reason: '$propina',
        );
      }
      expect(validar.validar(monto: 10, personas: 2, propina: 100), isNull);
    });

    test('con varios errores gana el primero: monto, personas, propina', () {
      expect(
        validar.validar(monto: double.nan, personas: 0, propina: -1),
        'Monto inválido',
      );
      expect(
        validar.validar(monto: 10, personas: 0, propina: -1),
        'Debe haber al menos una persona',
      );
    });
  });

  group('estrategias de redondeo', () {
    final EstrategiaRedondeo exacto = RedondeoExacto();
    final EstrategiaRedondeo arriba = RedondeoHaciaArriba();

    test('exacto redondea la mitad hacia arriba pese al ruido binario', () {
      expect(exacto.redondear(1.005), 1.01);
      expect(exacto.redondear(2.675), 2.68);
      expect(exacto.redondear(3.3333333), 3.33);
      expect(exacto.redondear(0.004), 0.0);
    });

    test('hacia arriba no sube un valor que ya es entero', () {
      expect(arriba.redondear(30.000000000000004), 30.0);
      expect(arriba.redondear(30.0), 30.0);
      expect(arriba.redondear(0.0), 0.0);
    });

    test('hacia arriba sí sube una fracción real, aunque sea pequeña', () {
      expect(arriba.redondear(12.0033), 13.0);
      expect(arriba.redondear(1999999999.5), 2000000000.0);
    });
  });

  group('CalcularDivision con valores grandes', () {
    const calcular = CalcularDivision();

    test('monto máximo con 100 % de propina y 1 persona', () {
      const cuenta = Cuenta(monto: 1000000000, personas: 1, propina: 100);
      final monto = calcular.calcular(cuenta, RedondeoExacto()).montoPorPersona;
      expect(const FormateadorMoneda().formatear(monto), '2000000000.00');
    });

    test('999 999 personas', () {
      const cuenta = Cuenta(monto: 999999, personas: 999999, propina: 0);
      final monto = calcular.calcular(cuenta, RedondeoExacto()).montoPorPersona;
      expect(monto, 1.0);
    });

    test('decimales de monto y propina no dejan ruido visible', () {
      const cuenta = Cuenta(monto: 33.33, personas: 3, propina: 12.5);
      final monto = calcular.calcular(cuenta, RedondeoExacto()).montoPorPersona;
      expect(const FormateadorMoneda().formatear(monto), '12.50');
    });
  });

  group('DivisorController', () {
    test('acepta coma como separador decimal en monto y propina', () {
      final controlador = _nuevoControlador()
        ..calcular(monto: '100,00', personas: '4', propina: '10,0');
      expect(controlador.resultado, '27.50');
      expect(controlador.error, isNull);
    });

    test('propina vacía cuenta como 0 %', () {
      final controlador = _nuevoControlador()
        ..calcular(monto: '90', personas: '3', propina: '');
      expect(controlador.resultado, '30.00');
    });

    test('monto vacío, con dos separadores o con espacios internos', () {
      for (final monto in ['', '   ', '1.2.3', '1,234.50', '12 50']) {
        final controlador = _nuevoControlador()
          ..calcular(monto: monto, personas: '2', propina: '0');
        expect(controlador.error, 'Monto inválido', reason: '"$monto"');
        expect(controlador.resultado, isNull);
      }
    });

    test('personas vacías piden al menos una persona', () {
      final controlador = _nuevoControlador()
        ..calcular(monto: '50', personas: '', propina: '0');
      expect(controlador.error, 'Debe haber al menos una persona');
    });

    test('un error borra el resultado anterior', () {
      final controlador = _nuevoControlador()
        ..calcular(monto: '100', personas: '4', propina: '10');
      expect(controlador.resultado, '27.50');

      controlador.calcular(monto: '100', personas: '0', propina: '10');
      expect(controlador.resultado, isNull);
      expect(controlador.error, 'Debe haber al menos una persona');
    });

    test(
      'cambiar de modo borra el resultado y el siguiente cálculo lo usa',
      () {
        final controlador = _nuevoControlador()
          ..calcular(monto: '10', personas: '3', propina: '0');
        expect(controlador.resultado, '3.33');

        controlador.seleccionarModo('Hacia arriba');
        expect(controlador.resultado, isNull);

        controlador.calcular(monto: '10', personas: '3', propina: '0');
        expect(controlador.resultado, '4.00');
      },
    );

    test('el primer modo del mapa es el inicial', () {
      expect(_nuevoControlador().modoSeleccionado, 'Exacto');
      expect(_nuevoControlador().modos, ['Exacto', 'Hacia arriba']);
    });

    test('rechaza un mapa de estrategias vacío y un modo desconocido', () {
      expect(
        () => DivisorController(
          validarEntrada: const ValidarEntrada(),
          calcularDivision: const CalcularDivision(),
          formateador: const FormateadorMoneda(),
          estrategias: const {},
        ),
        throwsArgumentError,
      );
      expect(
        () => _nuevoControlador().seleccionarModo('Al múltiplo de 5'),
        throwsArgumentError,
      );
    });
  });
}
