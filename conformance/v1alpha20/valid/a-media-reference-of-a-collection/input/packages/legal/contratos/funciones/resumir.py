from dataclasses import dataclass
from datetime import time
from decimal import Decimal
from typing import Annotated

from ore import function
from ore.tipos import DateTimeTz, Media, Money, Precision, Quantity


@function
def resumir(contrato: Media["legal.archivo.contratos"]) -> str:
    """El resumen de un contrato."""
    return contrato.path
