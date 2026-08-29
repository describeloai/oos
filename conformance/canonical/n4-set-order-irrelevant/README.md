# canonical / n4-set-order-irrelevant

**Regla:** [`90-canonical-form.md` §N4](../../../spec/v1alpha1/90-canonical-form.md) · **Afirmación:** convergen

---

`predicatePushdown` es un **conjunto**: que un origen admita `eq`, `in` y `range` no dice
nada sobre el orden en que se escribieron.

La forma canónica los ordena ascendentemente, así que las dos variantes colapsan.

Sin esto, dos personas declarando exactamente las mismas capacidades producirían digests
distintos, y **el diff semántico se llenaría de ruido** — cambios que no cambian nada. Es
justo el ruido que hace inservibles a los diffs de configuración en la mayoría de sistemas.

Su par es [`n4-sequence-order-semantic`](../n4-sequence-order-semantic/), donde ocurre lo
contrario y **debe** ocurrir.
