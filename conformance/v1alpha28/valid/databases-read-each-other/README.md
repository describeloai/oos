# v1alpha28 / valid / databases-read-each-other

**Regla:** [`01-la-visibilidad` 2](../../../../spec/v1alpha28/01-la-visibilidad.md#2) · **Nivel:** L0 · **Espera:** `accept`

---

Tres bases de un mismo árbol v1alpha28 se leen por nombre sin un `exports`: una standard lee una vista de la foránea y una `Table` de la fuente, y otra standard lee la primera.
