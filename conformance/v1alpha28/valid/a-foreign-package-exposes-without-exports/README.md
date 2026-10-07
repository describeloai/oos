# v1alpha28 / valid / a-foreign-package-exposes-without-exports

**Regla:** [`01-la-visibilidad` 3](../../../../spec/v1alpha28/01-la-visibilidad.md#3) · **Nivel:** L0 · **Espera:** `accept`

---

En un árbol v1alpha28, una base foránea expone el schema `ventas` de `erp` entero aunque el paquete de la fuente no exporte nada: lo que expone lo dice su `include`, y quién lo lee, el acceso.
