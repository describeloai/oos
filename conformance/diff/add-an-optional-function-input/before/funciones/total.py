from datetime import date
from decimal import Decimal

from ore import function


@function(reads=["ventas.pedidos"])
def total(desde: date) -> Decimal:
    return Decimal("0")
