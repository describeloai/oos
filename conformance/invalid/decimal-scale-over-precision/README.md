# invalid / decimal-scale-over-precision

**Regla:** [`02-entity.md` §3.2](../../../spec/v1alpha1/02-entity.md) · **Código:** `OOS3002` · **Nivel:** L0

---

`Decimal<2, 4>`. Cuatro decimales en dos cifras no existen: la escala no puede pasar de la precision.

Es `OOS3002` y no `OOS3001`: el tipo existe, lo que falla son sus parámetros. El esquema
JSON reconoce la forma `Decimal<…>` sin mirar los números precisamente para que el código
diga la causa correcta.
