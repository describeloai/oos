# valid / decimal-with-precision-and-scale

**Regla:** [`02-entity.md` §3.2](../../../spec/v1alpha1/02-entity.md) · **Nivel:** L0

---

`Decimal<38, 9>` es un `NUMERIC` de BigQuery; `Decimal<10, 2>` un `numeric(10,2)` de
PostgreSQL; `Decimal<1, 0>` y `Decimal<38, 38>` son los bordes del rango. Van entrecomillados
porque en estilo flow la coma partiría el tipo (la trampa de §3.2).
