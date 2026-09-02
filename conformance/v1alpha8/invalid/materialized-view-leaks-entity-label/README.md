# v1alpha8 / invalid / materialized-view-leaks-entity-label

**Regla:** [`02-view.md` §6](../../../../spec/v1alpha8/02-view.md#6) · **Código:** `OOS4002` · **Nivel:** L0

---

El gemelo v1alpha8 del caso de v1alpha7, **y su valor esta en que no cambia nada**.

`empleados` se copia a `lago`. `Employee` esta respaldada por `iberia`, que sale de `empleados`, y
declara `dni: high`. Ni `empleados` ni `erp.employees` llevan etiquetas —no pueden, no llevan
significado— y aun asi la copia no cabe: `dni` es `nationalId` alli, y `high` no cabe en un
conducto que admite `low`.

Que este caso siga fallando con el mismo codigo, por la misma razon, con una tabla debajo, es la
afirmacion de esta version: **la tabla movio el puntero de sitio, no la regla de flujo.**
