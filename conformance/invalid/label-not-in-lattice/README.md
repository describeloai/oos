# invalid / label-not-in-lattice

**Regla:** [`04-flow.md` §3](../../../spec/v1alpha1/04-flow.md) · **Código:** `OOS4003` · **Nivel:** L0

---

`gdpr.sensitivity` declara `[none, low, medium, high, critical]`. La propiedad usa
`extreme`.

Este caso existe sobre todo para fijar **la frontera entre el esquema y el compilador**.
`entity.schema.json` valida que la clave es un nombre cualificado y el valor un
identificador — y ahí se acaba lo que puede saber. Que ese nivel exista en ese retículo es
una relación **entre documentos**, y ningún JSON Schema la alcanza.

Es el mismo motivo por el que la suite no es opcional: sin ella, "conforme" significaría
solo "valida contra el esquema", que es la mitad más fácil.
