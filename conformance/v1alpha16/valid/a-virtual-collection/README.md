# v1alpha16 / valid / a-virtual-collection

**Regla:** [`02-media-collection.md` §3](../../../../spec/v1alpha16/02-media-collection.md#3) · **Espera:** `accept` · **Nivel:** L0

---

La misma colección con `virtual: true` y sin `ConduitPolicy`. No copia bytes, así que no
instancia `materialization.payload`; lo que sirve lo decide la comprobación al servir. Sigue
siendo una colección: fija en cada transacción qué ítems tenía.
