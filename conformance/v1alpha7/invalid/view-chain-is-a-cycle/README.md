# v1alpha7 / invalid / view-chain-is-a-cycle

**Regla:** [`01-view.md` §4](../../../../spec/v1alpha7/01-view.md#4) · **Código:** `OOS2019` · **Nivel:** L0

---

`a` sale de `b` y `b` sale de `a`. Las dos resuelven —por eso no es `OOS2018`— y ninguna llega a una
fuente: la cadena da la vuelta. Una vista se define por lo que tiene debajo, y una que se tiene a sí
misma debajo no se define. El mensaje enseña la cadena entera, porque el defecto no está en un
documento sino entre dos.
