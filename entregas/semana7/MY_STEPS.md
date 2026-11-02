# Lo que te falta hacer a ti

Todo lo demás ya está hecho. Estos pasos necesitan tu cuenta, tu aprobación o tu
criterio. Cada paso es una sola acción.

Todos los comandos se escriben en la **Terminal** (app "Terminal" de la Mac, o la
terminal de VS Code con **Ctrl + `**). Copia y pega uno a la vez y presiona **Enter**.

---

## Parte A: revisar la entrega (10 minutos)

1. Abre la carpeta del proyecto en VS Code:

   ```bash
   code ~/Projects/Clase_Programacion_Asistida_de_Apps/divisor_cuenta
   ```

   **Verás:** VS Code abierto con `respuestas.md`, `bitacora.md` y `DECISIONS.md` en la
   lista de archivos. **Si dice `command not found: code`:** abre VS Code a mano y usa
   **File → Open Folder…** con esa carpeta.

2. Lee `respuestas.md` completo. Cambia lo que no suene a ti: es tu entrega.

3. Abre `DECISIONS.md` y lee la decisión 10. Son las 3 respuestas que se dieron a
   `/speckit-clarify`. Si tú hubieras respondido distinto, avísame y lo rehago desde la
   spec.

4. Abre `DIGEST.pdf` y lee al menos la Parte B (la versión para niños) y el mapa "dónde
   mirar primero". La regla V de la constitución dice que debes poder explicar cada
   función.

## Parte B: comprobar tú mismo que todo funciona (5 minutos, opcional)

5. Entra al proyecto:

   ```bash
   cd ~/Projects/Clase_Programacion_Asistida_de_Apps/divisor_cuenta
   ```

6. Cámbiate a la rama SDD:

   ```bash
   git checkout sdd
   ```

   **Verás:** `Switched to branch 'sdd'`.

7. Corre las pruebas:

   ```bash
   flutter test
   ```

   **Verás al final:** `+33: All tests passed!`. **Si algo falla:** copia el error y
   pásamelo.

8. Abre la app en Chrome:

   ```bash
   flutter run -d chrome
   ```

   **Verás:** una ventana de Chrome con "Divisor de cuenta". Escribe 100, 4 y 10, toca
   **Calcular** y debe aparecer **27.50**. Para cerrar, vuelve a la terminal y presiona
   **q**.

9. Regresa a la rama `main`:

   ```bash
   git checkout main
   ```

## Parte C: construir el APK de Android (20-30 minutos, la mayor parte es descarga)

La lista de entrega pide `flutter build apk --debug`. Falló porque esta Mac no tiene el
Android SDK, e instalarlo implica aceptar licencias de Google: eso solo lo puedes hacer
tú.

10. Abre **Android Studio** (ya está instalado: búscalo con **Cmd + Espacio** y escribe
    "Android Studio").

11. En el asistente de bienvenida elige **Standard** y luego **Next** hasta **Finish**.
    Espera a que termine de descargar (unos 3 GB).
    **Si no aparece el asistente:** ve a **More Actions → SDK Manager** y marca
    **Android SDK Platform** (la versión más nueva) y, en la pestaña **SDK Tools**,
    **Android SDK Command-line Tools**. Luego **Apply**.

12. Acepta las licencias de Android:

    ```bash
    flutter doctor --android-licenses
    ```

    Escribe **y** y **Enter** cada vez que pregunte.

13. Comprueba:

    ```bash
    flutter doctor
    ```

    **Verás:** `[✓] Android toolchain`. **Si sigue en rojo:** copia el mensaje y
    pásamelo.

14. Construye el APK:

    ```bash
    cd ~/Projects/Clase_Programacion_Asistida_de_Apps/divisor_cuenta && git checkout sdd && flutter build apk --debug
    ```

    **Verás:** `✓ Built build/app/outputs/flutter-apk/app-debug.apk`.

15. Vuelve a `main` y avísame que funcionó. Actualizo la línea del APK en `bitacora.md`.

    ```bash
    git checkout main
    ```

## Parte D: GitHub (5 minutos)

16. **Ya está subido** (2026-10-01): repositorio **privado**
    <https://github.com/MarinoCobo/divisor-cuenta> con las ramas `main`, `vibe` y `sdd`.

17. Abre el repositorio en el navegador:

    ```bash
    gh repo view MarinoCobo/divisor-cuenta --web
    ```

    **Verás:** el repositorio; en el botón de ramas (arriba a la izquierda, dice
    `main`) deben aparecer `main`, `sdd` y `vibe`.

18. Dale acceso al profesor: en esa página, **Settings → Collaborators → Add people**,
    escribe su usuario de GitHub y haz clic en **Add**. (Si el profesor pide repos
    públicos: **Settings → General → Danger Zone → Change visibility → Public**.)

19. Copia la URL del repositorio y entrégala donde pida el profesor.

## Parte E: limpieza opcional

20. El `.gitignore` de tu repo del curso (`flutter-coursework`) tiene una línea nueva,
    `divisor_cuenta/`, sin commit. Si quieres guardarla:

    ```bash
    cd ~/Projects/Clase_Programacion_Asistida_de_Apps && git add .gitignore && git commit -m "chore: ignora divisor_cuenta (repo propio)"
    ```

    **Verás:** `1 file changed, 1 insertion(+)`.
