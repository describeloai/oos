# diff / remove-property-without-moved

**Regla:** [`91-versioning.md` §5.1](../../../spec/v1alpha1/91-versioning.md) · **Eje:** `CONSUMER` · **Código:** `OOS5001`

---

`nickname` desaparece de una entidad `STABLE` sin dejar rastro.

El contraste está en [`rename-with-moved`](../rename-with-moved/): la **misma** eliminación,
acompañada de `moved`, es compatible. La diferencia no es cuánto cambia el modelo — es si
el consumidor tiene un camino para seguirlo.
