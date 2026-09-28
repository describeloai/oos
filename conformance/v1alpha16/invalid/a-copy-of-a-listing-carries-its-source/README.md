# v1alpha16 / invalid / a-copy-of-a-listing-carries-its-source

**Regla:** [`01-object-table.md` §2](../../../../spec/v1alpha16/01-object-table.md#2) · **Código:** `OOS4002` · **Nivel:** L0

---

Un `ObjectTable` no lleva `labels` porque su clasificación es la de su `datasource`, y la hereda
quien lo lee: la vista `inventario` no escribe ninguna etiqueta y su copia lleva `high` por su
raíz, que es el listado. Lo encontró E3 en ORE: la raíz de un linaje solo miraba el `datasource`
de una `Table`, y el listado se leía sin clasificación.
