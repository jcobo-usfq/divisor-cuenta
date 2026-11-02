# Research: Divisor de cuenta

Decisiones técnicas tomadas en la Fase 0 del plan. Ninguna quedó como NEEDS CLARIFICATION.

## R1. Números: `double` con tolerancia, no centavos enteros

- **Decision**: el domain trabaja con `double`. Las estrategias de redondeo aplican una
  tolerancia pequeña para que el ruido de punto flotante (por ejemplo
  `27.500000000000004`) no cambie el resultado.
- **Rationale**: los casos de prueba de la spec usan `double` (incluido `double.nan` para
  "abc"), así que el domain debe aceptar `double`. Con los límites de la spec (monto hasta
  1 000 000 000, propina hasta 100 %), el monto por persona tiene como máximo 12 cifras
  enteras + 2 decimales, dentro de las ~15 cifras exactas de un `double`.
- **Alternatives considered**: centavos como `int` (más exacto, pero obliga a convertir
  en la frontera y no encaja con los casos de prueba en `double`); paquete `decimal`
  (prohibido: sin paquetes externos).

## R2. Fórmula del cálculo

- **Decision**: `porPersona = monto × (100 + propina) / (100 × personas)`.
- **Rationale**: es la misma fórmula de la spec (FR-002) reordenada para multiplicar antes
  de dividir; con montos y propinas enteras el resultado es exacto (100 × 110 / 400 =
  27.5 sin ruido).
- **Alternatives considered**: `monto × (1 + propina / 100) / personas` (introduce el
  error de representar 1.1 en binario).

## R3. Redondeo exacto = centavo más cercano

- **Decision**: `RedondeoExacto` multiplica por 100, suma una tolerancia de `1e-6`,
  redondea al entero y divide entre 100.
- **Rationale**: los casos de prueba comparan con `closeTo(esperado, 0.001)`; 10/3 =
  3.3333 no está a 0.001 de 3.33, así que el redondeo al centavo tiene que ocurrir en el
  domain, no solo al formatear. La tolerancia evita que 1.005 (guardado como
  1.00499999...) baje a 1.00.
- **Alternatives considered**: no redondear y dejarlo al formateador (falla el caso 5 de
  la tabla de pruebas y mezcla formatear con calcular).

## R4. Redondeo hacia arriba con tolerancia relativa

- **Decision**: `RedondeoHaciaArriba` calcula `(valor - tolerancia).ceilToDouble()`, con
  `tolerancia = max(1e-9, |valor| × 1e-12)`.
- **Rationale**: un valor que ya es entero salvo ruido (30.000000000000004) no debe subir
  a 31 (spec, US3 escenario 2). Una fracción real, aunque sea de un centavo (12.0033), sí
  debe subir, para que el grupo cubra la cuenta.
- **Alternatives considered**: redondear a centavos y luego al techo (12.0033 → 12.00 →
  12, y el grupo queda corto).

## R5. Dónde se convierte el texto a número

- **Decision**: `DivisorController` convierte el texto de los campos a número (coma →
  punto; monto vacío o no numérico → `double.nan`; propina vacía → 0; personas vacías →
  0). `ValidarEntrada` decide si esos números son válidos y devuelve el mensaje.
- **Rationale**: la forma del texto (coma, punto, campo vacío) es un detalle de la
  pantalla; la regla de qué es un monto válido es del negocio. Así los mensajes de error
  viven en un solo lugar (`ValidarEntrada`) y el domain se prueba con números, como piden
  los casos de prueba.
- **Alternatives considered**: `ValidarEntrada` recibe `String` (los casos de prueba usan
  `double`, habría que convertir `double.nan` a texto en las pruebas).

## R6. Resultado de la validación

- **Decision**: `ValidarEntrada.validar(...)` devuelve `String?`: `null` si todo es
  válido, o el mensaje de error exacto si no.
- **Rationale**: es lo más simple de explicar y de probar ("devuelve exactamente ese
  mensaje"). El controlador solo calcula cuando recibe `null`.
- **Alternatives considered**: una clase sellada `EntradaValida | EntradaInvalida`
  (más segura en tipos, pero agrega un tipo que el plan no pide).

## R7. Estado de la pantalla con `setState`

- **Decision**: `DivisorController` es una clase de Dart sin Flutter que guarda el modo
  elegido, el texto del resultado y el mensaje de error. `PantallaDivisor` (un
  `StatefulWidget`) llama a sus métodos dentro de `setState`.
- **Rationale**: lo pide el plan (setState, una sola pantalla) y deja el controlador
  probable sin widgets.
- **Alternatives considered**: `ChangeNotifier`, Provider o BLoC (innecesarios para una
  pantalla; Provider es un paquete externo).

## R8. Modos de redondeo como mapa inyectado (OCP)

- **Decision**: `main.dart` crea un `Map<String, EstrategiaRedondeo>` con los nombres
  visibles ("Exacto", "Hacia arriba") y se lo pasa al controlador. La pantalla dibuja un
  botón por cada entrada; la primera es la inicial.
- **Rationale**: agregar "al múltiplo de 5" es crear `RedondeoMultiploCinco` en `data/`
  y añadir una línea al mapa: no se edita ninguna clase existente.
- **Alternatives considered**: un `enum` de modos con un `switch` (cada modo nuevo obliga
  a editar el enum y el switch: viola OCP).

## R9. Campo de personas solo con dígitos

- **Decision**: el campo de personas usa `FilteringTextInputFormatter.digitsOnly` y un
  máximo de 6 caracteres.
- **Rationale**: elimina de raíz los casos "2.5", "dos" y "-3", y evita desbordar `int`.
  Vacío o 0 siguen mostrando "Debe haber al menos una persona".
- **Alternatives considered**: aceptar cualquier texto y validar (más mensajes de error
  que la spec no pide).

## R10. Regla de la materia comprobable

- **Decision**: activar la regla `public_member_api_docs` en `analysis_options.yaml`.
- **Rationale**: convierte "toda función documentada" en algo que `flutter analyze`
  verifica solo.
