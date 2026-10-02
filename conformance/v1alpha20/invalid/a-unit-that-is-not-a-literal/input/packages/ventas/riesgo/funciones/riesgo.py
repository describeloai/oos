from dataclasses import dataclass
from datetime import time
from decimal import Decimal
from typing import Annotated

from ore import function
from ore.tipos import DateTimeTz, Media, Money, Precision, Quantity


MONEDA = "EUR"


@function
def riesgo(importe: Money[MONEDA, 2]) -> str:
    return str(importe)
