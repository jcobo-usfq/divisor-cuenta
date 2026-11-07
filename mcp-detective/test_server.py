"""Pruebas de la lógica del servidor MCP Detective."""

import pytest

import server


@pytest.fixture(autouse=True)
def alertas_vacias():
    """Cada prueba empieza sin alertas, para no depender del orden."""
    server.ALERTAS.clear()
    yield
    server.ALERTAS.clear()


def test_listar_casos_devuelve_los_tres_casos_con_sus_cantidades():
    casos = server.listar_casos()

    assert [caso["caso_id"] for caso in casos] == ["INC-001", "INC-002", "INC-003"]
    assert {caso["caso_id"]: caso["cantidad_eventos"] for caso in casos} == {
        "INC-001": 2,
        "INC-002": 6,
        "INC-003": 5,
    }


def test_consultar_eventos_de_inc_002_devuelve_seis_fallos_de_admin():
    eventos = server.obtener_eventos("INC-002")

    assert len(eventos) == 6
    assert all(e["evento"] == "LOGIN_FAILED" and e["usuario"] == "admin" for e in eventos)


def test_consultar_caso_inexistente_lanza_error_explicito():
    with pytest.raises(ValueError, match="INC-999"):
        server.obtener_eventos("INC-999")


def test_registrar_alerta_valida_la_guarda_en_memoria():
    alerta = server.guardar_alerta("INC-003", "alto", "Cuatro fallos y un acceso exitoso desde la misma IP")

    assert alerta == {
        "caso_id": "INC-003",
        "nivel": "alto",
        "motivo": "Cuatro fallos y un acceso exitoso desde la misma IP",
        "estado": "registrada",
    }
    assert "INC-003" in server.ALERTAS


def test_segunda_alerta_del_mismo_caso_se_rechaza_como_duplicada():
    server.guardar_alerta("INC-003", "alto", "Primer registro")

    with pytest.raises(ValueError, match="duplicada"):
        server.guardar_alerta("INC-003", "medio", "Segundo registro")
    assert server.ALERTAS["INC-003"]["motivo"] == "Primer registro"


def test_nivel_invalido_se_rechaza():
    with pytest.raises(ValueError, match="bajo, medio o alto"):
        server.guardar_alerta("INC-002", "critico", "Intentos repetidos")
    assert server.ALERTAS == {}


def test_motivo_en_blanco_se_rechaza():
    with pytest.raises(ValueError, match="motivo"):
        server.guardar_alerta("INC-002", "medio", "   ")
    assert server.ALERTAS == {}


def test_alerta_para_caso_inexistente_se_rechaza():
    with pytest.raises(ValueError, match="no existe"):
        server.guardar_alerta("INC-999", "bajo", "Prueba")
    assert server.ALERTAS == {}
