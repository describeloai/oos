# v1alpha8 / invalid / witness-field-not-a-column

**Regla:** [`01-table.md` §6](../../../../spec/v1alpha8/01-table.md#6) · **Código:** `OOS2018` · **Nivel:** L0

---

`changes.witness: field` dice que una columna de la propia tabla ordena el avance. `updated_at`
no esta en `columns`, asi que **no hay quien la lea**, y el refresco incremental no tendria por
donde empezar.

Es el gemelo de `witness-field-not-exposed` de v1alpha7, con el sujeto corregido: alli se pedia
que el testigo estuviera en `fields` de una vista; aqui, que sea una columna del objeto. El
testigo es del objeto, no de quien lo consulta — y ese traslado es media version.
