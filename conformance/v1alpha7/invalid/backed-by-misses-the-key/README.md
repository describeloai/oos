# v1alpha7 / invalid / backed-by-misses-the-key

**Regla:** [`01-view.md` §4](../../../../spec/v1alpha7/01-view.md#4) · **Código:** `OOS2011` · **Nivel:** L0

---

`Employee.primaryKey = [id]`, y `empleados` expone `employeeId`. La misma regla del binding —el
mapeo cubre lo que necesita columna— dicha de la vista, con el mismo código: sin clave no hay
resolución de instancia, ni índice, ni recurso en una política.

La solución no es mapear en la entidad: es poner una vista encima que renombre, o llamar a la
propiedad como al campo. El renombre es de la vista (`00-scope` §4).
