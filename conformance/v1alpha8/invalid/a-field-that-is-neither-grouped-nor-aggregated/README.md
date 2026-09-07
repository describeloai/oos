# v1alpha8 / invalid / a-field-that-is-neither-grouped-nor-aggregated

**Regla:** [`02-view.md` §5.8](../../../../spec/v1alpha8/02-view.md) · **Codigo:** `OOS2032` ·
**Nivel:** L0

---

La vista agrupa por `country` y proyecta ademas `national_id`, que no agrupa ni agrega. En un
grupo hay tantos DNI como empleados de ese pais: la vista pide **uno**, y no hay ninguno que sea
el correcto.

Es la regla de SQL y por su misma razon. El remedio es una eleccion de quien escribe la vista
—entra en `groupBy`, o sale agregado— y por eso el diagnostico enseña las dos.
