# Data Model: Divisor de cuenta

Todas las entidades son inmutables y viven en `lib/domain/` (Dart puro).

## Cuenta

Lo que el usuario ingresó, ya convertido a números.

| Campo | Tipo | Regla (la aplica `ValidarEntrada`) |
|---|---|---|
| `monto` | `double` | finito, > 0 y ≤ 1 000 000 000; si no: "Monto inválido" |
| `personas` | `int` | ≥ 1; si no: "Debe haber al menos una persona" |
| `propina` | `double` | porcentaje finito entre 0 y 100; si no: "Propina inválida" |

Orden de validación: monto → personas → propina. Se devuelve solo el primer error.

## Resultado

| Campo | Tipo | Significado |
|---|---|---|
| `montoPorPersona` | `double` | lo que paga cada persona, ya redondeado por la estrategia |

## EstrategiaRedondeo (interfaz)

Es el "modo de redondeo" de la spec: el usuario ve un modo ("Exacto", "Hacia arriba"),
el código lo implementa como una `EstrategiaRedondeo` (hallazgo F1 de `/speckit-analyze`).

| Método | Recibe | Devuelve |
|---|---|---|
| `redondear` | `double` monto por persona sin redondear (finito, ≥ 0) | `double` monto redondeado |

Implementaciones en `lib/data/`:

| Clase | Regla | Ejemplos |
|---|---|---|
| `RedondeoExacto` | al centavo más cercano, mitad hacia arriba | 3.3333 → 3.33; 27.5 → 27.50; 1.005 → 1.01 |
| `RedondeoHaciaArriba` | al entero superior, salvo que ya sea entero | 3.3333 → 4.00; 30.0 → 30.00 |

## Estado de la pantalla (en `DivisorController`)

```text
            cambia una entrada / modo
   ┌───────────────────────────────────────┐
   ↓                                       │
[VACÍO] ──Calcular (válido)──→ [CON RESULTADO]
   │  ↑                                    │
   │  └──── cambia una entrada / modo ─────┤
   │                                       │
   └──Calcular (inválido)──→ [CON ERROR] ←─┘ Calcular (inválido)
```

- `resultado` y `error` nunca tienen valor al mismo tiempo.
- `modoSeleccionado` empieza en el primer modo del mapa ("Exacto").
