# v1alpha18 / valid / a-python-function-over-a-view

**Regla:** [`01-la-funcion-de-codigo.md` §4.3](../../../../spec/v1alpha18/01-la-funcion-de-codigo.md#4.3) · **Nivel:** L0

---

`riesgo` trabaja una fila de `ventas.clientes` (el primer parámetro, sin anotar: es la fila) y puede leer `ventas.pedidos`. `umbral: Decimal` es obligatorio; `moneda: str = "EUR"`, opcional. Devuelve un `@dataclass` del mismo fichero, y su campo es `output`. El documento es exactamente el que el código da.
