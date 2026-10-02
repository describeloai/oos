from dataclasses import dataclass
from datetime import time
from decimal import Decimal
from typing import Annotated

from ore import function
from ore.tipos import DateTimeTz, Media, Money, Precision, Quantity


@dataclass
class Linea:
    producto: str
    precio: Money["EUR", 2]
    notas: str | None = None


@dataclass
class Pedido:
    id: int
    lineas: list[Linea]
    entrega: time


@function
def riesgo(pedido: Pedido, corte: DateTimeTz, firma: bytes, tasa: Annotated[Decimal, Precision(5, 4)],
           peso: Quantity["kg", 3] = Decimal("0")) -> list[Linea]:
    """Las líneas de un pedido que pesan."""
    return pedido.lineas
