from dataclasses import dataclass
from datetime import time
from decimal import Decimal
from typing import Annotated

from ore import function
from ore.tipos import DateTimeTz, Media, Money, Precision, Quantity


@dataclass
class Nodo:
    valor: int
    hijos: list["Nodo"]


@function
def riesgo(arbol: Nodo) -> int:
    return arbol.valor
