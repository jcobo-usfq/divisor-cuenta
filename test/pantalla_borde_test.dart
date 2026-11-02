// Comportamientos de la pantalla que la spec pide además de los 3 escenarios
// de pantalla_test.dart: modo "Hacia arriba", FR-011 y el campo de personas.

import 'package:divisor_cuenta/main.dart';
import 'package:divisor_cuenta/presentation/pantalla_divisor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> _abrirPantalla(WidgetTester tester) {
  return tester.pumpWidget(
    MaterialApp(home: PantallaDivisor(controlador: crearControlador())),
  );
}

Future<void> _escribir(
  WidgetTester tester, {
  required String monto,
  required String personas,
  String propina = '',
}) async {
  await tester.enterText(find.byKey(const Key('campoMonto')), monto);
  await tester.enterText(find.byKey(const Key('campoPersonas')), personas);
  await tester.enterText(find.byKey(const Key('campoPropina')), propina);
}

void main() {
  testWidgets('el modo inicial es "Exacto" y "Hacia arriba" da 4.00', (
    tester,
  ) async {
    await _abrirPantalla(tester);
    await _escribir(tester, monto: '10', personas: '3', propina: '0');

    await tester.tap(find.text('Calcular'));
    await tester.pump();
    expect(find.text('3.33'), findsOneWidget);

    await tester.tap(find.text('Hacia arriba'));
    await tester.pump();
    expect(find.text('3.33'), findsNothing, reason: 'cambiar el modo lo borra');

    await tester.tap(find.text('Calcular'));
    await tester.pump();
    expect(find.text('4.00'), findsOneWidget);
  });

  testWidgets('editar un campo después de calcular borra el resultado', (
    tester,
  ) async {
    await _abrirPantalla(tester);
    await _escribir(tester, monto: '100', personas: '4', propina: '10');
    await tester.tap(find.text('Calcular'));
    await tester.pump();
    expect(find.text('27.50'), findsOneWidget);

    await tester.enterText(find.byKey(const Key('campoPersonas')), '5');
    await tester.pump();
    expect(find.byKey(const Key('resultado')), findsNothing);
  });

  testWidgets('el campo de personas solo acepta hasta 6 dígitos', (
    tester,
  ) async {
    await _abrirPantalla(tester);
    final campo = find.byKey(const Key('campoPersonas'));

    await tester.enterText(campo, '3a-.,');
    expect(tester.widget<TextField>(campo).controller!.text, '3');

    await tester.enterText(campo, '12345678');
    expect(tester.widget<TextField>(campo).controller!.text, '123456');
  });

  testWidgets('nunca se ven a la vez el resultado y un error', (tester) async {
    await _abrirPantalla(tester);
    await _escribir(tester, monto: '100', personas: '4');
    await tester.tap(find.text('Calcular'));
    await tester.pump();

    await tester.enterText(find.byKey(const Key('campoMonto')), '-5');
    await tester.tap(find.text('Calcular'));
    await tester.pump();

    expect(find.text('Monto inválido'), findsOneWidget);
    expect(find.byKey(const Key('resultado')), findsNothing);
  });
}
