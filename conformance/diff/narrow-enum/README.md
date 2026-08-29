# diff / narrow-enum

**Regla:** [`91-versioning.md` §5.1](../../../spec/v1alpha1/91-versioning.md) · **Eje:** `CONSUMER` · **Código:** `OOS5002`

---

`IC3` desaparece del enum. Un consumidor que ramificaba sobre él tiene ahora una rama
muerta — o peor, un `else` que lo absorbe en silencio.

Es la razón por la que `enum` se declara como **secuencia** y no como conjunto en la forma
canónica: retirar un valor y reordenarlos son cambios observables, y un conjunto ordenado
automáticamente los habría hecho indistinguibles.
