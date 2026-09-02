# v1alpha8 / invalid / entity-inherits-through-the-chain

**Regla:** [`02-view.md` §3](../../../../spec/v1alpha8/02-view.md#3) · **Código:** `OOS4002` · **Nivel:** L0

---

**La herencia atraviesa la cadena, y ahora atraviesa también la tabla.**

Nadie escribe una etiqueta en `iberia`. La lleva el **datasource** de la tabla que está dos
eslabones más abajo, y llega arriba porque de ahí salen los bytes — la ubicación física es un
hecho del mundo, y se computa (P2).

Que el puntero viva ahora en un documento aparte añade un eslabón al camino y **no cambia la
regla**: la raíz de la cadena sigue teniendo un `datasource`, y sigue etiquetando todo lo que
sale de él.
