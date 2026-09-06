# valid / a-copy-above-that-carries-nothing-classified

**Regla:** [`04-flow.md` §2](../../../spec/v1alpha1/04-flow.md) · **Debe:** aceptar · **Nivel:** L0

---

El mismo arbol, y `hr.copia` expone `employeeId` y `pais` — ninguna clasificada. Compila,
aunque cuelgue de la misma vista que el caso invalido y aunque la entidad tenga un campo
`high` que no viaja.

**Es el caso que impide que la correccion se pase de estricta.** Sin el, resolver la cadena
en las dos direcciones podria haberse escrito como *«toda copia de una cadena con una
entidad clasificada lleva su clasificacion»*, que es mas facil y es falso: el sello mira
**los campos que viajan**, no de donde cuelga la vista.
