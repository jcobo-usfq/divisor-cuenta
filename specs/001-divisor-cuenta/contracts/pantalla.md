# Contrato: pantalla

Lo que el usuario ve y lo que las pruebas de widget buscan.

| Elemento | Widget | Key | Texto / comportamiento |
|---|---|---|---|
| Monto total | `TextField` | `campoMonto` | etiqueta "Monto total"; teclado numérico con decimales; acepta cualquier texto (para poder escribir "abc" y ver el error) |
| Personas | `TextField` | `campoPersonas` | etiqueta "Número de personas"; solo dígitos, máximo 6 |
| Propina | `TextField` | `campoPropina` | etiqueta "Propina (%)"; vacía = 0 |
| Modo | `SegmentedButton<String>` | `selectorModo` | un segmento por cada modo del mapa; inicial: "Exacto" |
| Calcular | `FilledButton` | `botonCalcular` | texto "Calcular" |
| Resultado | `Text` | `resultado` | solo el número con dos decimales, por ejemplo `27.50`; encima, la etiqueta "Cada persona paga" |
| Error | `Text` | `mensajeError` | el mensaje exacto de `ValidarEntrada` |

Reglas:

- Nunca se muestran a la vez `resultado` y `mensajeError`.
- Cambiar cualquier campo o el modo borra el resultado y el error (FR-011).

## DivisorController (plain Dart, en `presentation/`)

```dart
DivisorController({
  required ValidarEntrada validarEntrada,
  required CalcularDivision calcularDivision,
  required FormateadorMoneda formateador,
  required Map<String, EstrategiaRedondeo> estrategias, // no vacío
});
List<String> get modos;
String get modoSeleccionado;
String? get resultado;   // texto ya formateado, por ejemplo "27.50"
String? get error;
void seleccionarModo(String modo);
void calcular({required String monto, required String personas, required String propina});
void limpiar();
```
