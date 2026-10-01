from dataclasses import KW_ONLY, InitVar, dataclass, field
from typing import TYPE_CHECKING, ClassVar

from ore import function

if TYPE_CHECKING:
    from decimal import Decimal


@function
def resultado(importe: "Decimal") -> "Resultado":
    return Resultado("x", importe, puntos=1)


@dataclass
class Base:
    id: str


@dataclass(frozen=True)
class Resultado(Base):
    total: "Decimal"
    UNIDAD: ClassVar[str] = "EUR"
    semilla: InitVar[int] = 0
    _: KW_ONLY
    notas: list[str] = field(default_factory=list)
    puntos: int = field(metadata={"x": 1})
    peso: float = field(default=1.0)
