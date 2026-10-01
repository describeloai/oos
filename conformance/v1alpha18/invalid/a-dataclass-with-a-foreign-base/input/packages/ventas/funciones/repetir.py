from dataclasses import dataclass

from ore import function


@dataclass
class Nivel(dict):
    nivel: str


@function
def repetir(texto: str) -> Nivel:
    return Nivel(texto)
