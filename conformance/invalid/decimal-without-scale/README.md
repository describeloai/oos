# invalid / decimal-without-scale

**Regla:** [`02-entity.md` §3.2](../../../spec/v1alpha1/02-entity.md) · **Código:** `OOS3002` · **Nivel:** L0

---

`Decimal<10>`. Sin la escala no se sabe cuantas de las diez cifras van detras de la coma. Es la mitad del error, como `Money<EUR>`.

Es `OOS3002` y no `OOS3001`: el tipo existe, lo que falla son sus parámetros. El esquema
JSON reconoce la forma `Decimal<…>` sin mirar los números precisamente para que el código
diga la causa correcta.
