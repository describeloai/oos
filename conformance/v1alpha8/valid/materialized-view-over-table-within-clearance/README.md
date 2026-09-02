# v1alpha8 / valid / materialized-view-over-table-within-clearance

**Regla:** [`02-view.md` §6](../../../../spec/v1alpha8/02-view.md#6) · **Nivel:** L0

---

El gemelo positivo de `invalid/materialized-view-leaks-entity-label`, con la
autorización puesta, y con una tabla debajo.

Compila **por la razón correcta**: no porque la etiqueta no llegara, sino porque llegó y cabe.
`dni` es `high` porque lo dijo `Employee`, dos eslabones más arriba; `empleados` no lleva
significado y `erp.employees` tampoco; y aun así la copia sabe lo que lleva.
