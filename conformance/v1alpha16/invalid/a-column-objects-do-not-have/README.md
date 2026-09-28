# v1alpha16 / invalid / a-column-objects-do-not-have

**Regla:** [`01-object-table.md` §7](../../../../spec/v1alpha16/01-object-table.md#7) · **Código:** `OOS2018` · **Nivel:** L0

---

Las columnas de un `ObjectTable` no se declaran porque son éstas: `key`, `size`, `contentType`,
`checksum`, `modified`, `version` y las particiones. `owner` no es ninguna.
