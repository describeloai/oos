# v1alpha8 / valid / an-aggregate-over-a-view

**Regla:** [`02-view.md` §5.8](../../../../spec/v1alpha8/02-view.md#58--la-agrupación--oos2032-y-oos2033) · **Nivel:** L0

---

`por_pais` agrupa **sobre una vista**, no sobre una tabla: cuenta y toma el mayor
`employeeId` de `empleados` por `pais`, y `pais` es un campo de `empleados`, no una columna
de `employees`.

Es el gemelo de `a-view-that-groups` un piso más arriba, y existe porque se midió que faltaba:
la implementación de referencia aceptaba agrupar sobre una tabla y rechazaba agrupar sobre
una vista con un `OOS2018` que nombraba un campo **vacío** —*«lee ``, que `empleados` no
expone»*—. Nueve casos agrupaban sobre tabla y ninguno sobre vista, así que nada lo veía.

Lo que este caso afirma:

- el argumento de un agregado —`employeeId`— se resuelve contra **lo que la vista de abajo
  expone**, igual que un campo (`§4`);
- la clave de `groupBy` —`pais`— también;
- y el plan baja el agregado hasta la columna física de la que sale ese campo.
