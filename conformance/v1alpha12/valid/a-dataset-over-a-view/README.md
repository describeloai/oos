# v1alpha12 / valid / a-dataset-over-a-view

**Regla:** [`01-dataset.md` 3.1](../../../../spec/v1alpha12/01-dataset.md#3.1) · **Nivel:** L0

---

`hr.iberia` es la pregunta; `hr.iberia_copia` es sus filas guardadas, con `from: { view }` y sin plan propio (expone lo que la vista expone, con sus nombres). Es la migración directa de una `View` con `materialized` y plan: la clave se va, la vista queda como pregunta, y lo que se tiene gana documento. El plan que instancia el conducto es el de la vista, bajado por `from`.
