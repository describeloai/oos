# v1alpha8 / invalid / a-group-key-the-lower-view-does-not-expose

**Regla:** [`02-view.md` §4](../../../../spec/v1alpha8/02-view.md#4) · **Código:** `OOS2018` · **Nivel:** L0

---

`por_ciudad` agrupa por `ciudad`, y `empleados` no la expone. Una clave de grupo es un nombre
como cualquier otro de la vista, y se resuelve donde se resuelven los demás: contra lo que la de
abajo expone. Sobre una tabla ya era así —`a-view-that-groups` agrupa por una columna real—;
esto fija la mitad vista→vista.
