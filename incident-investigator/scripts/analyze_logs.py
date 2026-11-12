#!/usr/bin/env python3
"""Aplica las reglas R1-R4 de references/detection-rules.md a un CSV de logs.

Uso: python3 analyze_logs.py archivo.csv

Solo lectura, sin red y solo con la biblioteca estándar. Imprime Markdown con los
números de fila del archivo original (encabezado = fila 1) y con los secretos
reemplazados por [REDACTED]. Es un apoyo reproducible: las alertas se verifican
después contra las filas del CSV.
"""

import csv
import re
import sys
from collections import defaultdict
from datetime import datetime, timedelta

COLUMNAS = ["timestamp", "ip", "user", "event", "result", "detail"]
VENTANA = timedelta(minutes=5)
UMBRAL_FUERZA_BRUTA = 6
UMBRAL_SPRAYING = 5
SECRETO = re.compile(r"(token|password|secret|apikey)=[^\s&;,]*", re.IGNORECASE)


def ocultar(texto):
    return SECRETO.sub(lambda m: m.group(1) + "=[REDACTED]", texto)


def leer(ruta):
    with open(ruta, newline="", encoding="utf-8") as f:
        lector = csv.DictReader(f)
        faltan = [c for c in COLUMNAS if c not in (lector.fieldnames or [])]
        if faltan:
            sys.exit(f"Faltan columnas: {', '.join(faltan)}")
        filas, problemas = [], []
        for n, fila in enumerate(lector, start=2):
            try:
                ts = datetime.fromisoformat(fila["timestamp"].strip())
            except ValueError:
                problemas.append(n)
                continue
            filas.append({**fila, "fila": n, "ts": ts})
    filas.sort(key=lambda r: (r["ts"], r["fila"]))
    return filas, problemas


def episodios(eventos, cumple):
    """Une en episodios las ventanas de <= 5 min (extremos incluidos) que cumplen."""
    intervalos = []
    j = 0
    for i in range(len(eventos)):
        j = max(j, i)
        while j + 1 < len(eventos) and eventos[j + 1]["ts"] - eventos[i]["ts"] <= VENTANA:
            j += 1
        if cumple(eventos[i : j + 1]):
            if intervalos and i <= intervalos[-1][1]:
                intervalos[-1][1] = j
            else:
                intervalos.append([i, j])
    return [eventos[a : b + 1] for a, b in intervalos]


def es(r, evento, resultado):
    return r["event"] == evento and r["result"] == resultado


def filas_txt(rs):
    return ", ".join(str(n) for n in sorted(r["fila"] for r in rs))


def rango(rs):
    return f"{rs[0]['timestamp']} – {rs[-1]['timestamp']}"


def main(ruta):
    filas, problemas = leer(ruta)
    fallos = [r for r in filas if es(r, "login", "failed")]
    exitos = [r for r in filas if es(r, "login", "success")]
    alertas, descartado, limites = [], [], []

    # R1: fuerza bruta por (ip, user)
    por_par = defaultdict(list)
    for r in fallos:
        por_par[(r["ip"], r["user"])].append(r)
    en_r1 = set()
    for (ip, user), evs in sorted(por_par.items()):
        eps = episodios(evs, lambda w: len(w) >= UMBRAL_FUERZA_BRUTA)
        for ep in eps:
            en_r1.update(r["fila"] for r in ep)
            fin = ep[-1]["ts"]
            despues = [e for e in exitos if e["user"] == user and fin < e["ts"] <= fin + VENTANA]
            misma = [e for e in despues if e["ip"] == ip]
            otra = [e for e in despues if e["ip"] != ip]
            nota = f"{len(ep)} fallos"
            if misma:
                nota += f"; éxito posterior desde la misma IP: fila(s) {filas_txt(misma)}"
            if otra:
                nota += f"; éxito posterior desde otra IP (contexto): fila(s) {filas_txt(otra)}"
            sev = "alta" if misma else "media"
            alertas.append(("Fuerza bruta probable", sev, "R1", rango(ep), ip, user,
                            f"{filas_txt(ep)} ({nota})"))
        if not eps and len(evs) > 1:
            descartado.append(f"{len(evs)} `login/failed` de `{user}` desde {ip} "
                              f"(filas {filas_txt(evs)}): no hay {UMBRAL_FUERZA_BRUTA} "
                              "dentro de 5 min; no cumple R1.")

    # R2: password spraying por ip
    por_ip = defaultdict(list)
    for r in fallos:
        por_ip[r["ip"]].append(r)
    for ip, evs in sorted(por_ip.items()):
        for ep in episodios(evs, lambda w: len({r["user"] for r in w}) >= UMBRAL_SPRAYING):
            usuarios = sorted({r["user"] for r in ep})
            alertas.append(("Password spraying probable", "media", "R2", rango(ep), ip,
                            ", ".join(usuarios),
                            f"{filas_txt(ep)} ({len(usuarios)} usuarios distintos)"))

    # R3: token en detail
    for r in filas:
        if "token=" in r["detail"]:
            alertas.append(("Token potencialmente expuesto", "alta", "R3", r["timestamp"],
                            r["ip"], r["user"], f"{r['fila']} (`{ocultar(r['detail'])}`)"))

    # R4: cambio de rol exitoso no aprobado
    for r in filas:
        if es(r, "role_change", "success") and "approved=false" in r["detail"]:
            alertas.append(("Escalada no autorizada según el registro", "alta", "R4",
                            r["timestamp"], r["ip"], r["user"],
                            f"{r['fila']} (`{ocultar(r['detail'])}`)"))
        elif r["event"] == "role_change":
            descartado.append(f"Fila {r['fila']}: `role_change/{r['result']}` "
                              f"(`{ocultar(r['detail'])}`); no cumple R4.")

    # Falsos positivos y límites
    hc = [r for r in filas if r["event"] == "healthcheck"]
    if hc:
        descartado.append(f"{len(hc)} `healthcheck` (filas {filas_txt(hc)}): no son "
                          "`login/failed`; no cuentan para R1 ni R2.")
    variantes = [r for r in filas if r["event"].strip().lower() == "login"
                 and r["result"].strip().lower() == "failed" and not es(r, "login", "failed")]
    if variantes:
        limites.append(f"Variantes de `login/failed` que no coinciden exactamente "
                       f"(filas {filas_txt(variantes)}); no se contaron.")
    vistos = defaultdict(list)
    for r in filas:
        vistos[tuple(r[c] for c in COLUMNAS)].append(r)
    for grupo in vistos.values():
        if len(grupo) > 1:
            limites.append(f"Filas idénticas: {filas_txt(grupo)}. Se trataron como filas separadas; "
                           "el registro no permite saber si son duplicados.")
    if problemas:
        limites.append(f"Timestamps no interpretables en filas {', '.join(map(str, problemas))}; "
                       "se excluyeron.")

    print(f"Archivo: `{ruta}` · filas de datos analizadas: {len(filas)}"
          + (f" · rango: {filas[0]['timestamp']} – {filas[-1]['timestamp']}" if filas else ""))
    print()
    print("| alerta | severidad orientativa | regla | timestamp (inicio–fin) | ip | usuario "
          "| filas / evidencia |")
    print("|---|---|---|---|---|---|---|")
    for a in alertas:
        print("| " + " | ".join(a) + " |")
    if not alertas:
        print("| (ninguna) | | | | | | |")
    print("\n### Descartado (no es alerta)\n")
    for d in descartado or ["(nada)"]:
        print(f"- {d}")
    print("\n### Límites detectados por el script\n")
    for l in limites or ["(ninguno)"]:
        print(f"- {l}")


if __name__ == "__main__":
    if len(sys.argv) != 2:
        sys.exit(__doc__)
    main(sys.argv[1])
