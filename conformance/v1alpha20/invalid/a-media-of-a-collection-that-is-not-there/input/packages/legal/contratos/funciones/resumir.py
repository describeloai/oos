from dataclasses import dataclass
from datetime import time
from decimal import Decimal
from typing import Annotated

from ore import function
from ore.tipos import DateTimeTz, Media, Money, Precision, Quantity


@function
def resumir(factura: Media["legal.archivo.facturas"]) -> str:
    """El resumen de una factura."""
    return factura.path
