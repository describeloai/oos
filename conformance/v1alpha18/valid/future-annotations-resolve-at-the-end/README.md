# v1alpha18 / valid / future-annotations-resolve-at-the-end

**Regla:** [`01-la-funcion-de-codigo.md` §4.6](../../../../spec/v1alpha18/01-la-funcion-de-codigo.md#4.6) · **Nivel:** L0

---

`from __future__ import annotations` deja todas las anotaciones para el final del módulo: `-> Despues` nombra la `@dataclass` de abajo. La docstring empieza tarde, y su primera línea no vacía es `description`.
