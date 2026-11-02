# Deber 3 — Respuestas

## 1. Rojo antes de verde

`flutter test` mostró que falló la prueba
*"la propina no puede superar el 100 % monto 100, 4 personas y propina 150 da el error de
propina máxima"*, con:

```text
Expected: 'La propina no puede superar el 100%'
  Actual: 'Propina inválida'
00:02 +34 -1: Some tests failed.
```

La app ya rechazaba una propina de 150, pero con el mensaje viejo, así que la prueba
detectó justo lo que faltaba: el mensaje nuevo. Ver la prueba fallar antes de escribir el
código demuestra que la prueba sí revisa algo; si hubiera pasado desde el inicio, no sabría
si prueba la regla o si está mal escrita y pasa con cualquier cosa. La segunda prueba
(propina 100 sin error) pasó desde el principio, y está bien: cuida el límite para que el
código nuevo no lo rompa.

Nota: una prueba vieja de `casos_borde_test.dart` esperaba "Propina inválida" para una
propina de 100.5. Con la regla nueva eso ya no es cierto, así que en el commit de rojo saqué
el 100.5 de esa lista (ahora lo cubre la prueba nueva). Así el commit de verde solo toca
`lib/`.

## 2. Linter vs. IA

- **Aviso de `flutter analyze`:** `unused_local_variable` — *"The value of the local
  variable 'variableSinUsar' isn't used"* en `lib/main.dart` (también salió `avoid_print`
  por el `print('hola')`). Mi código real no tenía avisos; esos los agregué a propósito y
  luego los borré.
- **Code smell de la IA:** el número mágico `100` en `lib/domain/calcular_division.dart`,
  en `monto * (100 + propina) / (100 * personas)`.

El linter no lo encontró porque solo revisa reglas fijas que se pueden comprobar
mecánicamente (una variable que no se usa, un `print`). Un `100` en una fórmula es código
válido y no rompe ninguna regla; saber que ese número representa "el 100 % de la cuenta" y
que debería tener nombre requiere entender qué significa el código, y eso es lo que hace la
IA.

## 3. Tu refactorización

Elegí el **número mágico** en `calcular_division.dart`. Agregué la constante
`static const double _cuentaCompleta = 100;` (con un comentario que dice que es el 100 % de
la cuenta) y la fórmula quedó
`monto * (_cuentaCompleta + propina) / (_cuentaCompleta * personas)`. El valor es el mismo
y el orden de las operaciones también (primero multiplica, después divide), así que el
resultado es idéntico.

Sé que la app hace exactamente lo mismo porque las 35 pruebas (las de la spec, las de casos
borde, las de pantalla y las dos nuevas de propina) siguieron en verde después del cambio,
sin tocar nada en `test/`, y `flutter analyze` siguió sin avisos.

## 4. Coverage

El archivo con el porcentaje más bajo es **`lib/main.dart`, con 44.4 %** (4 de 9 líneas).
Todos los demás archivos de `lib/` están en 100 %.

No significa que tenga errores. Las líneas sin cubrir son las de la función `main()`, la que
llama a `runApp` y arranca la app de verdad; las pruebas no ejecutan `main()`, sino que arman
la pantalla directamente con `crearControlador()`. El coverage solo dice qué líneas
ejecutaron las pruebas, no si el código está bien: un archivo puede tener 100 % y aun así
tener un error (si las pruebas no revisan el resultado correcto), y uno con poco coverage
puede funcionar perfecto, como `main.dart`, que se usa cada vez que se abre la app.
