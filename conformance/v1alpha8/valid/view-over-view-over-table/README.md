# v1alpha8 / valid / view-over-view-over-table

**Regla:** [`02-view.md` §3](../../../../spec/v1alpha8/02-view.md#3) · **Nivel:** L0

---

El gemelo de `v1alpha7/valid/view-over-view`, y su valor está en que **no cambia
nada**: `iberia` renombra campos de `empleados`, recorta por `pais` —que es un campo y no una
columna— y la raíz sigue siendo `erp` / `public.employees`.

Lo único que sí cambia es que ahora es **comprobable hasta el suelo**: `employeeId: employee_id`
se verifica contra `columns`, y en v1alpha7 no había contra qué.
