# v1alpha7 / valid / view-over-view

**Regla:** [`01-view.md` §5](../../../../spec/v1alpha7/01-view.md#5) · **Nivel:** L0

---

`iberia` sale de `empleados`: renombra `employeeId → id` y `nationalId → dni`, y recorta por `pais`,
que es un campo de `empleados` y no una columna. La entidad se respalda en `iberia` y su clave es `id`.

Es la cadena de §5 con dos eslabones. La raíz es `erp` / `public.employees`, y `id` llega allí como
`employee_id` — compuesto, sin que ningún documento lo escriba.
