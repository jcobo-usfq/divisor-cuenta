import 'package:divisor_cuenta/data/redondeo_exacto.dart';
import 'package:divisor_cuenta/data/redondeo_hacia_arriba.dart';
import 'package:divisor_cuenta/domain/calcular_division.dart';
import 'package:divisor_cuenta/domain/validar_entrada.dart';
import 'package:divisor_cuenta/presentation/divisor_controller.dart';
import 'package:divisor_cuenta/presentation/formateador_moneda.dart';
import 'package:divisor_cuenta/presentation/pantalla_divisor.dart';
import 'package:flutter/material.dart';

/// Arma el [DivisorController] con todas sus piezas concretas.
///
/// Este archivo es el ÚNICO lugar donde se crean implementaciones concretas
/// (constitución II). Para agregar un modo de redondeo nuevo se crea su clase
/// y se agrega una línea al mapa de estrategias; nada más cambia (OCP).
/// Las estrategias no declaran constructor propio, así que la única
/// aparición de `Nombre()` en `lib/` es la de este archivo.
DivisorController crearControlador() => DivisorController(
  validarEntrada: const ValidarEntrada(),
  calcularDivision: const CalcularDivision(),
  formateador: const FormateadorMoneda(),
  estrategias: {
    'Exacto': RedondeoExacto(),
    'Hacia arriba': RedondeoHaciaArriba(),
  },
);

/// Punto de entrada: arranca la app con la pantalla del divisor.
void main() {
  runApp(
    MaterialApp(
      title: 'Divisor de cuenta',
      theme: ThemeData(colorSchemeSeed: Colors.teal),
      home: PantallaDivisor(controlador: crearControlador()),
    ),
  );
}
