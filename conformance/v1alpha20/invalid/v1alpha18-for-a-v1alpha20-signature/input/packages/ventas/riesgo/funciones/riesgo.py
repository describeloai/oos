from dataclasses import dataclass
from datetime import time
from decimal import Decimal
from typing import Annotated

from ore import function
from ore.tipos import DateTimeTz, Media, Money, Precision, Quantity


@function
def riesgo(importe: Money["EUR", 2]) -> str:
    """El riesgo de un importe."""
    return str(importe)
