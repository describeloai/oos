import datetime as dt
import typing
from typing import Annotated, Union

import ore as o
from ore import function as fn


@o.function
def por_modulo(dia: dt.date, n: typing.Optional[int] = None) -> str:
    return str(dia)


@fn
def por_alias(x: Union[int, None], nombre: Annotated[str, "el nombre"]) -> typing.List[float]:
    """Lo que se pida, por alias."""
    return []
