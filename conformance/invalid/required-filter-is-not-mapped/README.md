# invalid / required-filter-is-not-mapped

**Regla:** [`05-ejecutor.md` §5.2](../../../spec/v1alpha1/05-ejecutor.md) · **Código:** `OOS2015` · **Nivel:** L0

---

`requiredFilters: [cuenta]` dice que el origen **no acepta una consulta sin ese filtro**. El
mapeo cubre `pk` y `sk`, y no `cuenta`.

Es un documento que **compila y no sirve para nada**: el motor no tiene con qué construir el
filtro, así que este binding no se puede consultar nunca. Con `fullScan: forbidden` no queda
ni la salida cara.

`capabilities` llevaba desde v1alpha1 sin que nada lo comprobara — estaba clasificado para la
forma canónica y nadie más lo miraba. Dejó de ser documentación en cuanto
[`05-ejecutor`](../../../spec/v1alpha1/05-ejecutor.md) §5 convirtió `fullScan` en una
autorización: **lo que el planificador se cree tiene que ser verdad.**
