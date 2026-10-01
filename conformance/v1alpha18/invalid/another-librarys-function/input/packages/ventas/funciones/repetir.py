from ore import function
from otra.biblioteca import function  # noqa: F811 · tapa al de ore


@function
def repetir(texto: str) -> str:
    return texto
