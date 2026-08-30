# v1alpha4 / invalid / redeclares-the-inherited-type

**Regla:** [`01-significado.md` §4.2](../../../../spec/v1alpha4/01-significado.md#42) · **Codigo:** `OOS1004` · **Nivel:** L0

---

> Una propiedad **declara localmente o referencia un concepto, nunca las dos cosas.**

El borrador de v1alpha4 reservo `OOS9002` para esto. **No hace falta**, y el caso esta aqui
para dejar constancia de por que: la exclusion es expresable entera con un `oneOf`, luego su
incumplimiento ya tiene codigo — `OOS1004`, *el documento no valida contra su esquema*. Es
el mismo trato que §7 le daba una fila mas arriba a `confidence` sin `is`, y no verlo habria
sido inflar una familia por simetria con una tabla.

**El registro encoge en vez de crecer**, que es el resultado que P7 existe para producir.

Y notese que aqui el tipo declarado **coincide** con el del concepto. Falla igualmente, por
lo mismo que `OOS4008` falla cuando el valor es correcto: una copia que un humano puede
desincronizar acaba mintiendo, y el dia que el concepto cambie nadie mirara aqui.

`labels` **si** puede escribirse junto a `is` — para elevar, nunca para rebajar. Los dos
campos no son la misma clase de cosa: `type` es una igualdad y `labels` un orden.
