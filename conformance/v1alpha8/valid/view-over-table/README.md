# v1alpha8 / valid / view-over-table

**Regla:** [`02-view.md` §4](../../../../spec/v1alpha8/02-view.md#4) · **Nivel:** L0

---

`empleados` sale de `erp.employees` y renombra tres de sus columnas. `national_id` no lleva ya
`physicalType`: lo dice la columna de la tabla, que es de quien es.

Lo que este caso afirma no es que compile —eso ya lo hacia en v1alpha7— sino **contra que**
compila. Cada valor de `fields` y la clave de `where` estan en `columns`, y por primera vez eso
se puede verificar. La vista adelgazada no declara `capabilities` ni `version` porque no son
suyos.
