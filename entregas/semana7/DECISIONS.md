# Decisiones

Cada decisión que tomó el agente donde la guía o el pedido no eran explícitos, con la
razón en una línea. Revísalas; cualquiera se puede cambiar.

## Proceso

1. **Proyecto en `~/Projects/Clase_Programacion_Asistida_de_Apps/divisor_cuenta`.** Es la carpeta donde están las demás prácticas del curso.
2. **Caso C de Git: repo propio + `divisor_cuenta/` en el `.gitignore` de arriba.** Es lo que recomienda la guía; el cambio del `.gitignore` de `flutter-coursework` quedó **sin commit** para que decidas tú.
3. **La rama `vibe` la hizo otra instancia del agente (mismo modelo), con tu aprobación.** El agente principal ya había leído la guía completa; usarlo habría contaminado el experimento.
4. **Al prompt de `vibe` solo se le agregó la ruta del proyecto.** Equivale a "abrir el agente en esta carpeta"; no da información sobre la app.
5. **Las correcciones de `vibe` se basaron solo en "La app" del enunciado ("Nada más").** Mencionar los 6 escenarios habría sido darle la spec por la puerta de atrás.
6. **La primera respuesta de `vibe` se guardó en un commit (`01340e6`).** Es la evidencia de lo que el agente agregó sin que nadie lo pidiera.
7. **`vibe` corrió en un `git worktree` aparte, en paralelo.** Así las dos ramas no se pisaban en la misma carpeta.
8. **`specify init . --integration claude --script sh`, sin menú interactivo.** La terminal del agente no puede usar flechas; elegir `claude` en el parámetro es lo mismo que elegirlo en el menú.
9. **Los skills `/speckit-*` se ejecutaron siguiendo su `SKILL.md` paso a paso.** La sesión se abrió fuera de `divisor_cuenta`, así que no estaban cargados como comandos; el contenido que siguió el agente es el mismo.
10. **Clarify: se aceptó la opción recomendada en las 3 preguntas.** Tu misión decía tomar el valor más sensato y anotarlo; las preguntas y respuestas están en `spec.md` y en `respuestas.md` (pregunta 4).
11. **Iteraciones: en `sdd` solo se cuentan correcciones; los 11 pasos del flujo van aparte.** Los pasos de Spec Kit son el método, no correcciones; la bitácora da los dos números.

## Producto (rama `sdd`)

12. **"Exacto" = centavo más cercano, mitad hacia arriba.** Con 10/3 = 3.333 la prueba exige 3.33 con tolerancia 0.001, así que hay que redondear en el domain.
13. **Monto > 0 y ≤ 1 000 000 000; propina de 0 a 100; personas solo dígitos (hasta 6).** Con esos topes los centavos siempre caben en la precisión de un `double`, y una propina mayor que la cuenta es casi seguro un error de tipeo.
14. **Coma o punto como separador decimal.** En Ecuador se usan los dos.
15. **El resultado se borra al editar cualquier campo o el modo.** Evita mostrar un resultado que no corresponde a lo que está escrito (respuesta de clarify).
16. **Sin símbolo de moneda.** La spec solo pedía "dos decimales" y la prueba busca el texto exacto `27.50`.

## Técnica (rama `sdd`)

17. **`double` con tolerancia, no centavos enteros.** Los casos de prueba de la guía usan `double` (incluido `double.nan` para "abc").
18. **`ValidarEntrada.validar(...)` devuelve `String?` (null = válido).** Es lo más fácil de explicar y de probar contra "devuelve exactamente ese mensaje".
19. **El texto se convierte a número en `DivisorController`, no en el domain.** La coma o el campo vacío son detalles de la pantalla; las reglas y los mensajes quedan todos en `ValidarEntrada`.
20. **Modos de redondeo como un mapa que arma `main.dart`.** Agregar un modo es una clase nueva más su import y su entrada en el mapa; ninguna otra clase cambia (OCP). Comprobado en una copia aparte: 34/34 pruebas.
21. **Se quitó `cupertino_icons` del `pubspec.yaml`.** No se usaba y `CLAUDE.md` dice "sin paquetes externos".
22. **Regla `public_member_api_docs` activada.** Hace que `flutter analyze` compruebe la regla de la materia (todo documentado).
23. **`test/widget_test.dart` de la plantilla se borró en la Fase 1.** `/speckit-analyze` vio que rompía `flutter analyze` apenas cambiara `main.dart` (hallazgo D1).
24. **Las estrategias no declaran constructor propio.** Así `grep "RedondeoExacto()"` solo encuentra `main.dart` (tarea T028 de converge).
25. **Pruebas de casos borde en `test/casos_borde_test.dart` y `test/pantalla_borde_test.dart`.** Los tres archivos que pide la guía quedaron exactamente como se pidieron.
26. **`test/casos_de_prueba.dart` es copia literal de la guía (9.1), sin formatear.** Es el archivo que el estudiante escribe "a mano".
27. **El formulario se alinea arriba en vez de centrarse.** Centrado verticalmente quedaba a media pantalla y saltaba al aparecer el resultado.

## Verificación y entrega

28. **La prueba "de verdad" se hizo en Chrome sin interfaz, controlado por un script de Dart.** La extensión de Chrome no respondió (dos intentos); Dart y Chrome ya estaban instalados, así que no hubo que instalar nada.
29. **No se construyó el APK.** Esta Mac no tiene Android SDK; instalarlo implica aceptar licencias de Google, y eso te toca a ti. Se construyó la app de macOS como prueba de que compila.
30. **Los documentos (respuestas, bitácora, este archivo, `MY_STEPS.md`, `DIGEST.pdf`) van en `main`.** La guía pide `respuestas.md` en `main`; el código queda en `vibe` y `sdd`.
31. **Nada se subió a GitHub.** Requiere tu aprobación.
32. **Todo en español.** Es material del curso.
