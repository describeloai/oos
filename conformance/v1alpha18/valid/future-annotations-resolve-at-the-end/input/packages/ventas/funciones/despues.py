from __future__ import annotations

from dataclasses import dataclass

from ore import function


@function(timeout="30s")
def adelantada(minimo: int = 0) -> Despues:
    """

       La docstring empieza tarde.
    """
    return Despues(minimo)


@dataclass
class Despues:
    valor: int | None
