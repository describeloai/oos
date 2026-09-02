# v1alpha8 / invalid / table-datasource-undeclared

**Regla:** [`01-table.md` §6](../../../../spec/v1alpha8/01-table.md#6) · **Código:** `OOS2004` · **Nivel:** L0

---

El mismo codigo que `datasourceRef` y que `from.datasource`, y **se reutiliza en vez de
duplicarse** porque es el mismo defecto: se nombra una fuente que este repositorio no puede
alcanzar.

Que el sujeto haya cambiado tres veces —binding, vista, tabla— y el codigo sea el mismo es la
afirmacion de que la tabla no cambia la regla, cambia el sujeto.
