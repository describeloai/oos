# v1alpha8 / invalid / an-aggregate-over-a-field-the-lower-view-does-not-expose

**Regla:** [`02-view.md` §4](../../../../spec/v1alpha8/02-view.md#4) · **Código:** `OOS2018` · **Nivel:** L0

---

`por_pais` suma `salario`, y `empleados` expone `employeeId`, `nationalId` y `pais`. Lo que la
de abajo no expone **no existe** para la de arriba — también cuando lo que lo nombra es un
agregado y no un campo.

Es `field-the-lower-view-does-not-expose` con el sujeto cambiado, y el diagnóstico tiene que
decir **qué** agrega: el defecto que motivó el caso era un `OOS2018` con el nombre vacío.
