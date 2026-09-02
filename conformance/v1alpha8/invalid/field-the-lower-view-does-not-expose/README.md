# v1alpha8 / invalid / field-the-lower-view-does-not-expose

**Regla:** [`02-view.md` §4](../../../../spec/v1alpha8/02-view.md#4) · **Código:** `OOS2018` · **Nivel:** L0

---

`iberia` pide `salario`, y `empleados` expone `employeeId`, `nationalId` y `pais`.
Lo que la de abajo no expone **no existe** para la de arriba.

Es la mitad vista→vista de `OOS2018`, la que v1alpha7 ya comprobaba. Su gemela —la que llega
hasta la columna física— es `field-not-a-column`, y solo existe desde que hay tabla. Las dos
tienen que estar: una regla comprobada por un lado y creída por el otro es media regla.
