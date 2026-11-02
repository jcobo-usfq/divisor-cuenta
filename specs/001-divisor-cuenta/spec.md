# Feature Specification: Divisor de cuenta

**Feature Branch**: `sdd` (directorio de la spec: `specs/001-divisor-cuenta`)

**Created**: 2026-10-01

**Status**: Draft

**Input**: User description: "Una app de una sola pantalla para dividir la cuenta de un
restaurante entre varias personas. El usuario ingresa el monto total, el número de personas
y el porcentaje de propina, y al tocar "Calcular" ve cuánto paga cada persona con dos
decimales. Hay dos modos de redondeo que el usuario elige: exacto, o hacia arriba al entero
más cercano. La app funciona sin conexión: no hay red ni base de datos. Escenarios de
aceptación: 1. 100.00, 4 personas, 10% de propina, modo exacto -> 27.50 por persona;
2. 90.00, 3 personas, 0% de propina, modo exacto -> 30.00 por persona; 3. 50.00 y 0
personas -> mensaje "Debe haber al menos una persona", y NO se muestra resultado; 4. el
monto dice "abc" -> mensaje "Monto inválido"; 5. 10.00, 3 personas, 0%, modo exacto ->
3.33 por persona; 6. 10.00, 3 personas, 0%, modo hacia arriba -> 4.00 por persona"

## Clarifications

### Session 2026-10-01

- Q: En modo exacto, 10.00 entre 3 da 3.33 por persona y la suma (9.99) no llega al total;
  ¿la app debe hacer algo con ese centavo de diferencia? → A: No. Solo se muestra el
  monto por persona redondeado; la diferencia de centavos se ignora (opción A,
  recomendada).
- Q: ¿Un monto total de 0.00 es una entrada válida? → A: No. Un monto igual a 0 muestra
  "Monto inválido" (opción A, recomendada).
- Q: Si el usuario cambia un campo o el modo después de calcular, ¿qué pasa con el
  resultado que ya está en pantalla? → A: Se borra en cuanto cambia cualquier entrada, y
  vuelve a aparecer solo al tocar "Calcular" (opción B, recomendada).

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Calcular cuánto paga cada persona (Priority: P1)

Al terminar de comer, una persona del grupo abre la app, escribe el monto total de la
cuenta, el número de personas y el porcentaje de propina, toca "Calcular" y ve cuánto
debe pagar cada persona, con dos decimales.

**Why this priority**: es la razón de ser de la app. Sin esto no hay producto.

**Independent Test**: se prueba ingresando monto, personas y propina con el modo exacto y
comprobando que el monto por persona mostrado coincide con el esperado.

**Acceptance Scenarios**:

1. **Given** monto 100.00, 4 personas, 10% de propina y modo exacto, **When** el usuario
   toca "Calcular", **Then** ve 27.50 por persona.
2. **Given** monto 90.00, 3 personas, 0% de propina y modo exacto, **When** el usuario toca
   "Calcular", **Then** ve 30.00 por persona.
3. **Given** monto 10.00, 3 personas, 0% de propina y modo exacto, **When** el usuario toca
   "Calcular", **Then** ve 3.33 por persona (escenario 5 de la descripción).

---

### User Story 2 - Recibir un aviso claro cuando la entrada es inválida (Priority: P2)

Si el usuario escribe algo que no permite calcular (cero personas, un monto que no es un
número), la app le dice qué está mal y no muestra ningún resultado.

**Why this priority**: un resultado incorrecto mostrado con seguridad es peor que no
mostrar nada; el aviso evita que el grupo pague mal.

**Independent Test**: se prueba ingresando entradas inválidas y comprobando el mensaje
exacto y la ausencia de resultado.

**Acceptance Scenarios**:

1. **Given** monto 50.00 y 0 personas, **When** el usuario toca "Calcular", **Then** ve el
   mensaje "Debe haber al menos una persona" y NO se muestra ningún resultado (escenario 3).
2. **Given** el monto dice "abc", **When** el usuario toca "Calcular", **Then** ve el mensaje
   "Monto inválido" y NO se muestra ningún resultado (escenario 4).

---

### User Story 3 - Elegir redondear hacia arriba (Priority: P3)

Para no lidiar con centavos, el usuario puede elegir que el monto por persona se redondee
hacia arriba al entero más cercano, en lugar del modo exacto.

**Why this priority**: es una comodidad sobre el cálculo básico; la app ya es útil sin
ella.

**Independent Test**: se prueba con el mismo caso en los dos modos y comprobando que solo
cambia el redondeo.

**Acceptance Scenarios**:

1. **Given** monto 10.00, 3 personas, 0% de propina y modo hacia arriba, **When** el usuario
   toca "Calcular", **Then** ve 4.00 por persona (escenario 6).
2. **Given** monto 90.00, 3 personas, 0% de propina y modo hacia arriba, **When** el usuario
   toca "Calcular", **Then** ve 30.00 por persona (un valor que ya es entero no sube).

---

### Edge Cases

- Monto vacío, no numérico, negativo, cero, mayor a 1 000 000 000 o con más de un
  separador decimal: se muestra "Monto inválido".
- Número de personas vacío o cero: se muestra "Debe haber al menos una persona".
- El campo de personas solo admite dígitos (hasta 6), así que no se pueden escribir
  valores negativos, decimales ni letras.
- Propina vacía: se interpreta como 0%.
- Propina negativa, mayor a 100 % o no numérica: se muestra "Propina inválida".
- Varias entradas inválidas a la vez: se muestra un solo mensaje, en este orden de
  prioridad: monto, personas, propina.
- El monto máximo (1 000 000 000) con 100 % de propina y 1 persona, o 999 999 personas:
  el cálculo sigue siendo correcto con dos decimales.
- Un valor por persona que ya es entero (30.00) no sube a 31.00 en modo hacia arriba.
- Ruido de punto flotante (por ejemplo 27.500000000000004) no cambia el resultado
  mostrado.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: La app MUST tener una sola pantalla con tres campos (monto total, número de
  personas, porcentaje de propina), un selector de modo de redondeo y un botón "Calcular".
- **FR-002**: Al tocar "Calcular" con entradas válidas, la app MUST mostrar el monto por
  persona = (monto × (1 + propina / 100)) / personas, redondeado según el modo elegido.
- **FR-003**: El resultado MUST mostrarse siempre con exactamente dos decimales.
- **FR-004**: El modo "exacto" MUST redondear el monto por persona al centavo más cercano
  (mitad hacia arriba).
- **FR-005**: El modo "hacia arriba" MUST redondear el monto por persona al entero
  inmediatamente superior, salvo que ya sea entero.
- **FR-006**: El usuario MUST poder elegir el modo de redondeo; el modo inicial es
  "exacto".
- **FR-007**: Con entradas inválidas, la app MUST mostrar un único mensaje de error (ver
  Edge Cases) y MUST NOT mostrar ningún resultado, ni siquiera el de un cálculo anterior.
- **FR-008**: Los mensajes "Debe haber al menos una persona" y "Monto inválido" MUST
  mostrarse con ese texto exacto.
- **FR-009**: La app MUST funcionar sin conexión: no usa red ni guarda datos.
- **FR-010**: La app MUST aceptar tanto el punto como la coma como separador decimal en el
  monto y en la propina.
- **FR-011**: Si el usuario cambia el monto, las personas, la propina o el modo después de
  calcular, el resultado visible MUST borrarse hasta el próximo toque de "Calcular".
- **FR-012**: El monto total MUST ser mayor que 0; un monto igual a 0 es inválido.
- **FR-013**: La app MUST mostrar solo el monto por persona; NO reparte ni muestra la
  diferencia de centavos entre la suma de las partes y el total.

### Key Entities *(include if feature involves data)*

- **Cuenta**: lo que el usuario ingresó y ya fue validado: monto total, número de
  personas y porcentaje de propina.
- **Resultado**: el monto que paga cada persona, ya redondeado según el modo.
- **Modo de redondeo**: la regla que convierte el monto por persona sin redondear en el
  monto a pagar (exacto o hacia arriba).

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Los 6 escenarios de aceptación de la descripción producen exactamente el
  resultado o el mensaje esperado (6 de 6).
- **SC-002**: Un usuario que abre la app por primera vez obtiene el monto por persona en
  menos de 30 segundos.
- **SC-003**: El resultado aparece en menos de 1 segundo después de tocar "Calcular".
- **SC-004**: La app funciona igual con el teléfono en modo avión (100 % de las funciones
  disponibles sin conexión).

## Assumptions

- La propina se calcula sobre el monto total ingresado (no hay impuestos aparte).
- La moneda es una sola y no se muestra símbolo; el resultado es un número con dos
  decimales.
- El resultado se calcula solo al tocar "Calcular", no mientras el usuario escribe.
- No hay historial, ni cuentas de usuario, ni división desigual entre personas: fuera
  del alcance de este MVP.
- Los límites (monto hasta 1 000 000 000, propina hasta 100 %, personas hasta 999 999)
  existen para garantizar que los centavos se calculen sin errores de precisión; una
  propina mayor que la cuenta se considera un error de tipeo.
