# v1alpha14 / valid / a-k-threshold-on-an-aggregate

**Regla:** [`01-la-vista-es-sql` 6](../../../../spec/v1alpha14/01-la-vista-es-sql.md#6) · **Nivel:** L0 · **Espera:** `accept`

---

Un HAVING sobre un agregado admite rangos, como desde v1alpha8: `count(*) >= 8` es un umbral de k-anonimidad, no un canal lateral.
