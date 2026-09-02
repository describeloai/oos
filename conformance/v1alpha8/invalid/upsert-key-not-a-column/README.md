# v1alpha8 / invalid / upsert-key-not-a-column

**Regla:** [`01-table.md` §6](../../../../spec/v1alpha8/01-table.md#6) · **Código:** `OOS2018` · **Nivel:** L0

---

`changes.mode: upsert` exige `key`, y **el esquema ya lo exige**: una tabla `upsert` sin `key`
falla antes, con `OOS1004`. Lo que un esquema no puede hacer es mirar si ese nombre esta en
`columns`, y eso es lo que este caso mide.

Aqui la clave es `order_key`, y el tema declara `order_id`. Sin clave real, un *tombstone* no
dice que fila retira, y el mantenedor aplicaria un `-1` a nada.

> El plan de trabajo llamaba a este caso `upsert-without-key`. Se midio y se cambio: con el
> esquema exigiendo `key`, aquel nombre habria afirmado `OOS2018` sobre algo que falla antes con
> `OOS1004`, y la suite exige que no se falle antes con otro codigo.
