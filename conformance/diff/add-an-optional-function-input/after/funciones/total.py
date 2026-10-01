from datetime import date
from decimal import Decimal

from ore import function


@function(reads=["ventas.pedidos"])
def total(desde: date, moneda: str = "EUR") -> Decimal:
    return Decimal("0")
