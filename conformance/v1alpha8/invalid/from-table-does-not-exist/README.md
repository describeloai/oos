# v1alpha8 / invalid / from-table-does-not-exist

**Regla:** [`02-view.md` §4](../../../../spec/v1alpha8/02-view.md#4) · **Código:** `OOS2018` · **Nivel:** L0

---

`from.table` **DEBE** resolver, igual que `from.view` y que `backedBy`. Aqui dice
`erp.employes`, y la tabla es `erp.employees`.

Es el mismo codigo que `from-view-does-not-exist` de v1alpha7 porque es el mismo defecto: una
cadena que no llega al suelo no tiene raiz, y sin raiz no hay de donde heredar etiquetas ni de
donde leer.
