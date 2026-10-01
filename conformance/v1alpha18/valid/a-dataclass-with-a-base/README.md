# v1alpha18 / valid / a-dataclass-with-a-base

**Regla:** [`01-la-funcion-de-codigo.md` §4.5](../../../../spec/v1alpha18/01-la-funcion-de-codigo.md#4.5) · **Nivel:** L0

---

`Resultado` hereda `id` de `Base`. `UNIDAD` (`ClassVar`), `semilla` (`InitVar`) y `_` (`KW_ONLY`) no son campos. `notas` tiene `default_factory` y es opcional; `puntos = field(metadata=…)` no tiene valor por defecto y es obligatorio. La vuelta se anota entre comillas porque `Resultado` se define más abajo, y `Decimal` solo se importa bajo `TYPE_CHECKING`: entre comillas se resuelve al final del módulo.
