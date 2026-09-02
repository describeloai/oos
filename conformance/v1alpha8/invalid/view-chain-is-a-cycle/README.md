# v1alpha8 / invalid / view-chain-is-a-cycle

**Regla:** [`02-view.md` §4](../../../../spec/v1alpha8/02-view.md#4) · **Código:** `OOS2019` · **Nivel:** L0

---

`a` sale de `b` y `b` sale de `a`. Ninguna de las dos se define, porque una vista
se define **por lo que tiene debajo** y aquí debajo no hay suelo.

Que exista una tabla en el paquete no salva nada, y por eso está: el ciclo no es un problema de
que falte un objeto físico — es que la cadena no llega a él.
