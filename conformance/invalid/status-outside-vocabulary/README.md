# invalid / status-outside-vocabulary

**Regla:** [`01-package.md` §2.3](../../../spec/v1alpha1/01-package.md) · **Código:** `OOS2008` · **Nivel:** L0

---

El caso usa `stable` a propósito, y no un valor absurdo: **`STABLE` sí existe** — en el
retículo `oos.maturity`, que es otra cosa.

`status` adopta el vocabulario de ODCS verbatim (`proposed`, `draft`, `active`,
`deprecated`, `retired`) para que la emisión no pierda nada, y el nivel de madurez se
**deriva** de él. Confundir los dos vocabularios es el error que un usuario cometerá de
verdad, así que es el que conviene probar.
