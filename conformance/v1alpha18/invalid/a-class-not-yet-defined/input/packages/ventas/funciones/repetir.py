from dataclasses import dataclass

from ore import function


@function
def repetir(texto: str) -> Nivel:
    return Nivel(texto)


@dataclass
class Nivel:
    nivel: str
