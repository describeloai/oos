# invalid / decimal-precision-over-38

**Regla:** [`02-entity.md` §3.2](../../../spec/v1alpha1/02-entity.md) · **Código:** `OOS3002` · **Nivel:** L0

---

`Decimal<40, 2>`. 38 es el techo de Iceberg y de Parquet (`decimal128`). Un origen mas ancho viaja como `String` con su cita.

Es `OOS3002` y no `OOS3001`: el tipo existe, lo que falla son sus parámetros. El esquema
JSON reconoce la forma `Decimal<…>` sin mirar los números precisamente para que el código
diga la causa correcta.
