# v1alpha18 / valid / names-are-resolved-like-python

**Regla:** [`01-la-funcion-de-codigo.md` §4.1](../../../../spec/v1alpha18/01-la-funcion-de-codigo.md#4.1) · **Nivel:** L0

---

`@o.function` es `ore.function` porque `import ore as o`; `@fn`, porque `from ore import function as fn`. `dt.date` es una fecha porque `import datetime as dt`; `typing.Optional[int]`, `Union[int, None]` y `Annotated[str, …]` se traducen como §4.6 dice. El documento es el que se deriva.
