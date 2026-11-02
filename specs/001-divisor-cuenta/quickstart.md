# Quickstart: comprobar el divisor de cuenta

## Requisitos

- Flutter estable (`flutter doctor` sin errores en la plataforma que vas a usar).
- Estar parado en la raíz del proyecto (`divisor_cuenta/`).

## 1. Pruebas automáticas

```bash
flutter pub get
flutter test --reporter expanded
```

Esperado: los 6 casos de `test/casos_de_prueba.dart`, la prueba de LSP y las 3 pruebas
de widget en verde.

## 2. Análisis estático

```bash
flutter analyze
```

Esperado: `No issues found!`

## 3. Verificaciones de la constitución

Corre los comandos de la tabla "Verificación de cumplimiento" de
`.specify/memory/constitution.md`. Todos deben dar el resultado esperado.

## 4. A mano, en la app

```bash
flutter run            # elige un dispositivo: macOS, Chrome, iPhone o Android
```

| # | Entradas | Modo | Esperado en pantalla |
|---|---|---|---|
| 1 | 100, 4, 10 | Exacto | 27.50 |
| 2 | 90, 3, 0 | Exacto | 30.00 |
| 3 | 50, 0, (vacío) | Exacto | "Debe haber al menos una persona", sin resultado |
| 4 | abc, 4, 0 | Exacto | "Monto inválido", sin resultado |
| 5 | 10, 3, 0 | Exacto | 3.33 |
| 6 | 10, 3, 0 | Hacia arriba | 4.00 |

Extra: después del caso 1, cambia cualquier campo: el 27.50 debe desaparecer.
