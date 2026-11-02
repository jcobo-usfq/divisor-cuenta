// Pruebas de widget de la pantalla, armada igual que en la app real
// (con crearControlador() de main.dart).

import 'package:divisor_cuenta/main.dart';
import 'package:divisor_cuenta/presentation/pantalla_divisor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> _abrirPantalla(WidgetTester tester) {
  return tester.pumpWidget(
    MaterialApp(home: PantallaDivisor(controlador: crearControlador())),
  );
}

void main() {
  testWidgets('100, 4 personas y 10 % muestran 27.50', (tester) async {
    await _abrirPantalla(tester);

    await tester.enterText(find.byKey(const Key('campoMonto')), '100');
    await tester.enterText(find.byKey(const Key('campoPersonas')), '4');
    await tester.enterText(find.byKey(const Key('campoPropina')), '10');
    await tester.tap(find.text('Calcular'));
    await tester.pump();

    expect(find.text('27.50'), findsOneWidget);
  });

  testWidgets('50 y 0 personas muestran el error y ningún resultado', (
    tester,
  ) async {
    await _abrirPantalla(tester);

    await tester.enterText(find.byKey(const Key('campoMonto')), '50');
    await tester.enterText(find.byKey(const Key('campoPersonas')), '0');
    await tester.tap(find.text('Calcular'));
    await tester.pump();

    expect(find.text('Debe haber al menos una persona'), findsOneWidget);
    expect(find.byKey(const Key('resultado')), findsNothing);
    expect(find.text('Cada persona paga'), findsNothing);
  });

  testWidgets('"abc" en el monto muestra "Monto inválido"', (tester) async {
    await _abrirPantalla(tester);

    await tester.enterText(find.byKey(const Key('campoMonto')), 'abc');
    await tester.tap(find.text('Calcular'));
    await tester.pump();

    expect(find.text('Monto inválido'), findsOneWidget);
  });
}
