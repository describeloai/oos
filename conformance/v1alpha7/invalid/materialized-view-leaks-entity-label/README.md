# v1alpha7 / invalid / materialized-view-leaks-entity-label

**Regla:** [`01-view.md` §5.2](../../../../spec/v1alpha7/01-view.md#52) · **Código:** `OOS4002` · **Nivel:** L0

---

**El caso que vale dinero.** `empleados` se copia a `lago`. `Employee` está respaldada por `iberia`,
que sale de `empleados`, y declara `dni: high`. `empleados` no lleva etiquetas —no puede, no lleva
significado— y aun así **no puede materializarse**: `dni` es `nationalId` allí, y `high` no cabe
en un conducto que admite `low`.

Sin esta regla se copiaría en claro un dato que la entidad clasificó, y compilaría. Es el *label
seal*: la clasificación de una copia se hereda por la cadena, no se recalcula sobre la tabla
copiada — donde la columna por la que alguien clasificó puede no estar.

El diagnóstico sale **en la vista de abajo**, que es la que se copia, y nombra el campo con el nombre
que tiene allí.
