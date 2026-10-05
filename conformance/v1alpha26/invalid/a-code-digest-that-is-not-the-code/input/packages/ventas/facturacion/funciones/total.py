from datetime import date
from decimal import Decimal

from ore import function


@function
def total(desde: date) -> Decimal:
    return Decimal("1")
