# Parte 5 — Code smells en `lib/` (lista de la IA, sin cambiar código)

| # | Archivo y línea | Code smell | Por qué molesta |
|---|---|---|---|
| 1 | `lib/domain/calcular_division.dart:24` | **Número mágico** (`100` dos veces) | `monto * (100 + propina) / (100 * personas)`: el `100` es "el 100 % de la cuenta", pero no tiene nombre. Quien lee tiene que adivinar qué significa cada `100`. |
| 2 | `lib/domain/validar_entrada.dart:20` | **Conocimiento duplicado** | El mensaje `'La propina no puede superar el 100%'` repite a mano el valor de `propinaMaxima`. Si el tope cambia a 50, el mensaje queda mintiendo. |
| 3 | `lib/data/redondeo_exacto.dart:20` | **Número mágico** (`* 100` y `/ 100`) | El `100` aquí son "centavos por unidad", otra idea distinta al `100` del porcentaje, pero se escribe igual. |
| 4 | `lib/data/redondeo_hacia_arriba.dart:22` | **Número mágico** (`1e-9`, `1e-12`) | Las tolerancias no tienen nombre; en `RedondeoExacto` la tolerancia sí es una constante con nombre (`_tolerancia`). |
| 5 | `lib/presentation/divisor_controller.dart:76-105` | **Método que hace varias cosas** | `calcular` lee el texto, convierte a número, valida, arma la `Cuenta`, calcula y formatea. Funciona, pero hay que leerlo entero para cambiar una sola parte. |
| 6 | `lib/presentation/divisor_controller.dart:81` | **Valor centinela** (`double.nan`) | Se usa `double.nan` para decir "el usuario no escribió un número". Es una convención escondida: quien no la conoce no entiende por qué el monto vale NaN. |
| 7 | `lib/presentation/pantalla_divisor.dart:71-111` | **Código duplicado** | Los campos de monto y propina son casi el mismo `TextField` copiado; solo cambian la `key` y el texto de la etiqueta. |
| 8 | `lib/presentation/pantalla_divisor.dart:54-164` | **Función larga** | `build` tiene más de 100 líneas: campos, selector, botón, resultado y error en un solo método. |

**Elegido:** #1, el número mágico `100` en `calcular_division.dart`. Es el más claro de
explicar y el cambio es pequeño y no cambia el comportamiento.

Descartado: #6 (`double.nan`) — la IA lo marca, pero está documentado en el propio
método y en `ValidarEntrada`, así que no me convence que sea un problema real hoy.
