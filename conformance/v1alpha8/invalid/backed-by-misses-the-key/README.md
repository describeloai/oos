# v1alpha8 / invalid / backed-by-misses-the-key

**Regla:** [`02-view.md` §4](../../../../spec/v1alpha8/02-view.md#4) · **Código:** `OOS2011` · **Nivel:** L0

---

`Employee.primaryKey` es `[id]` y `empleados` expone `employeeId`, `nationalId` y
`pais`. Lo que la vista no da, la entidad no lo tiene.

Sin la clave no hay resolución de instancia, ni índice de topología, ni recurso identificable en
una política. El código es el del binding —`OOS2011`— porque es el mismo defecto: **el mapeo no
cubre lo que necesita columna**, dicho de la vista.
