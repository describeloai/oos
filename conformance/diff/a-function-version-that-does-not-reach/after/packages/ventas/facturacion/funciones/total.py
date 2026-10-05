from datetime import date
from decimal import Decimal

from ore import function


@function
def total(desde: date, moneda: str) -> Decimal:
    return Decimal("0")
