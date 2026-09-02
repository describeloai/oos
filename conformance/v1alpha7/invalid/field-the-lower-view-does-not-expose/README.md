# v1alpha7 / invalid / field-the-lower-view-does-not-expose

**Regla:** [`01-view.md` §4](../../../../spec/v1alpha7/01-view.md#4) · **Código:** `OOS2018` · **Nivel:** L0

---

`iberia` pide `baseSalary` a `empleados`, y `empleados` expone `employeeId`, `nationalId` y `pais`.
Lo que la de abajo no expone **no existe** para la de arriba — aunque la columna esté en la tabla.
Es la regla que hace que exponer sea una decisión: una vista de encima no puede alcanzar por detrás
lo que la de abajo decidió no dar.
