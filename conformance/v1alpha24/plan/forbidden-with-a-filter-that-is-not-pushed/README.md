# v1alpha24 / plan / forbidden-with-a-filter-that-is-not-pushed

**Regla:** [`01-leer-el-origen` 4](../../../../spec/v1alpha24/01-leer-el-origen.md#4) · **Nivel:** L0 · **Espera:** `OOS2044`

---

`fullScan: forbidden`: el `LIKE` no está en `predicatePushdown`, lo evalúa el motor y no protege al origen, que devolvería todo.
