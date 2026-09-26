# diff / narrow-decimal-scale

**Regla:** [`91-versioning.md` §5.1](../../../spec/v1alpha1/91-versioning.md) y [`02-entity.md` §3.4](../../../spec/v1alpha1/02-entity.md) · **Eje:** `CONSUMER`

---

`Decimal<12, 4>` pasa a `Decimal<12, 2>`. Dos decimales menos: `0.0050` ya no se puede escribir. La copia redondearia en silencio.
