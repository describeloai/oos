# canonical / n2-defaults-materialized

**Regla:** [`90-canonical-form.md` §N2](../../../spec/v1alpha1/90-canonical-form.md) · **Afirmación:** convergen

---

Un manifiesto sin `workspace` y otro que escribe `members: [packages/*]`.

**La forma canónica no contiene valores implícitos.** Todo valor por defecto se escribe, y por
eso las dos variantes colapsan en los mismos bytes.

Este caso tenía **otro sujeto** —un binding sin `materialization` frente a uno con `mode: passthrough` explícito— y lo
perdió cuando `03-binding` §3.1 pasó de un enum de tres modos a dos ejes independientes: la
ausencia dejó de ser un valor por defecto y pasó a ser *la ausencia*. **Un vocabulario que no
crea la ambigüedad no necesita que N2 la repare**, y eso es mejor que repararla bien.

Y al mudarlo se vio que el sujeto nuevo **estaba roto**: el esquema declara
`"default": ["packages/*"]` desde v1alpha1 y nadie lo materializaba, así que estos dos
manifiestos producían **digests distintos**. Peor: `ore init` omite el campo a propósito
citando P2, de modo que todo repositorio recién creado caía de un lado del corte.

Es la cuarta vez que N2 se rompe por lo mismo — la regla estaba escrita y se aplicaba a un
solo campo de los que cubría.
