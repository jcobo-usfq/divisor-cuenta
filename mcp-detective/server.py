"""Servidor MCP Detective: consulta casos del sistema ficticio Centinela y registra alertas.

Las funciones de lógica (sin decorador) recuperan o registran datos y validan entradas;
lanzan ValueError cuando algo no cumple el contrato. Las tools MCP solo las llaman.
"""

import json
from pathlib import Path

from mcp.server import MCPServer
from mcp.server.mcpserver.exceptions import ToolError
from mcp.types import ToolAnnotations

RUTA_CASOS = Path(__file__).resolve().parent / "casos.json"
NIVELES_VALIDOS = ("bajo", "medio", "alto")

with RUTA_CASOS.open(encoding="utf-8") as archivo:
    CASOS: dict[str, dict] = json.load(archivo)

# Almacenamiento solo en memoria: se pierde al reiniciar el proceso del servidor.
ALERTAS: dict[str, dict] = {}


# --- Lógica (se prueba con pytest) ---------------------------------------------


def validar_caso(caso_id: str) -> None:
    """Lanza ValueError si caso_id no es texto o no existe en casos.json."""
    if not isinstance(caso_id, str):
        raise ValueError("caso_id debe ser texto, por ejemplo 'INC-001'.")
    if caso_id not in CASOS:
        disponibles = ", ".join(CASOS)
        raise ValueError(f"El caso '{caso_id}' no existe. Casos disponibles: {disponibles}.")


def obtener_casos() -> list[dict]:
    """Devuelve id, sistema y cantidad de eventos de cada caso, sin conclusiones."""
    return [
        {"caso_id": caso_id, "sistema": caso["sistema"], "cantidad_eventos": len(caso["eventos"])}
        for caso_id, caso in CASOS.items()
    ]


def obtener_eventos(caso_id: str) -> list[dict]:
    """Devuelve una copia de los eventos exactos del caso; ValueError si no existe."""
    validar_caso(caso_id)
    return [dict(evento) for evento in CASOS[caso_id]["eventos"]]


def guardar_alerta(caso_id: str, nivel: str, motivo: str) -> dict:
    """Guarda una alerta en memoria si cumple el contrato; si no, lanza ValueError."""
    validar_caso(caso_id)
    if nivel not in NIVELES_VALIDOS:
        raise ValueError(f"Nivel inválido '{nivel}'. Solo se acepta: bajo, medio o alto.")
    if not isinstance(motivo, str) or not motivo.strip():
        raise ValueError("El motivo no puede estar vacío ni tener solo espacios.")
    if caso_id in ALERTAS:
        raise ValueError(
            f"Alerta duplicada: el caso '{caso_id}' ya tiene una alerta registrada "
            f"(nivel {ALERTAS[caso_id]['nivel']}). Solo se permite una por caso."
        )

    alerta = {"caso_id": caso_id, "nivel": nivel, "motivo": motivo.strip(), "estado": "registrada"}
    ALERTAS[caso_id] = alerta
    return dict(alerta)


# --- Tools MCP -----------------------------------------------------------------

mcp = MCPServer("MCP Detective")

# El SDK v2 oculta al cliente el texto de un ValueError (lo trata como fallo interno);
# solo el texto de ToolError llega al agente. Por eso cada tool traduce el error.


@mcp.tool(annotations=ToolAnnotations(read_only_hint=True))
def listar_casos() -> list[dict]:
    """Lista los casos disponibles para investigar.

    Solo lectura. Devuelve, por cada caso, su identificador (caso_id), el sistema
    afectado y la cantidad de eventos registrados. No incluye conclusiones.
    """
    return obtener_casos()


@mcp.tool(annotations=ToolAnnotations(read_only_hint=True))
def consultar_eventos(caso_id: str) -> list[dict]:
    """Devuelve los eventos exactos (hora, usuario, ip, evento) de un caso.

    Solo lectura. Si el caso no existe, falla con un error explícito en lugar de
    devolver una lista vacía.
    """
    try:
        return obtener_eventos(caso_id)
    except ValueError as error:
        raise ToolError(str(error)) from error


@mcp.tool(annotations=ToolAnnotations(read_only_hint=False, destructive_hint=False, idempotent_hint=False))
def registrar_alerta(caso_id: str, nivel: str, motivo: str) -> dict:
    """Registra una alerta en memoria para un caso. Es una acción: modifica el estado.

    Requisitos: el caso debe existir, el nivel debe ser exactamente 'bajo', 'medio' o
    'alto' y el motivo debe tener al menos un carácter que no sea espacio. Solo se
    permite una alerta por caso; un duplicado se rechaza. Las alertas se pierden al
    reiniciar el servidor.
    """
    try:
        return guardar_alerta(caso_id, nivel, motivo)
    except ValueError as error:
        raise ToolError(str(error)) from error


if __name__ == "__main__":
    mcp.run(transport="stdio")
