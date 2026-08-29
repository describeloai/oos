# invalid / unknown-type

**Regla:** [`02-entity.md` §3](../../../spec/v1alpha1/02-entity.md) · **Código:** `OOS3001` · **Nivel:** L0

---

`Blob` no está en el conjunto. Los escalares son `String`, `Integer`, `Decimal`, `Float`,
`Boolean`, `Date`, `Time`, `DateTime`, `DateTimeTz` y `Opaque`.

El conjunto es cerrado y alineado con el enum de Apache Ossie **aunque no lo perfilemos**:
así la emisión es un mapeo sin renombrados. Y tiene salida prevista — **`Opaque`** — para
lo que OOS no modela: un blob binario existe en la fuente, se puede etiquetar y gobernar, y
no hace falta que el sistema de tipos sepa qué hay dentro.
