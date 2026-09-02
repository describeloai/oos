# v1alpha8 / invalid / from-view-does-not-exist

**Regla:** [`02-view.md` §4](../../../../spec/v1alpha8/02-view.md#4) · **Código:** `OOS2018` · **Nivel:** L0

---

`iberia` sale de `empleados`, y no hay ninguna `empleados`.

El mismo código que `from-table-does-not-exist` y por el mismo motivo: una cadena que no llega al
suelo no tiene raíz, y sin raíz no hay de dónde heredar etiquetas ni de dónde leer. Que las dos
formas de `from` fallen igual es lo que hace que `from` sea **una** decisión con dos escrituras y
no dos campos distintos.
