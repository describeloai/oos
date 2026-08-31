# valid / relation-against-an-alternate-key

**Regla:** [`02-entity.md` §6](../../../spec/v1alpha1/02-entity.md) · **Nivel:** L0

---

`Cliente` tiene identidad subrogada `[id]` y una clave natural `[nif]`. `Factura` enlaza por
el NIF, que es como enlaza cualquier ERP.

**SQL no obliga a referenciar la clave primaria.** Una foránea puede apuntar a cualquier
restricción `UNIQUE`, y `REFERENCES clientes (nif)` lo acepta PostgreSQL sin protestar. Se
comprobó ejecutándolo, después de haber escrito en una decisión que este caso era raro — no
lo es.

Sin `toKey`, esta relación no era *inexpresable*: era **expresable y silenciosamente
falsa**. `via: [nifCliente]` se emparejaba contra `[id]`, y con `id` y `nif` ambos de tipo
`String` la aridad y los tipos habrían casado. `discover` la habría emitido en verde.

Aquí es donde R2RML acertaba al nombrar los dos lados. Este campo es el precio de haberlo
ahorrado en el caso normal, y solo se paga cuando hace falta.
