# diff / widen-decimal

**Regla:** [`91-versioning.md` §5.1](../../../spec/v1alpha1/91-versioning.md) y [`02-entity.md` §3.4](../../../spec/v1alpha1/02-entity.md) · **Eje:** `CONSUMER`

---

`Decimal<10, 2>` pasa a `Decimal<12, 2>`. Dos cifras enteras mas y la misma escala: todo valor de antes cabe. Es un ensanche (02-entity 3.4), no OOS5010.
