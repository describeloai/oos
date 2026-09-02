# v1alpha8 / valid / virtual-over-materialized-over-stream

**Regla:** [`02-view.md` §3](../../../../spec/v1alpha8/02-view.md#3) · **Nivel:** L0

---

**La distincion que `OOS2020` mide.** La *raiz* de `iberia` es `bus.orders`, que no se deja leer.
Su *raiz de lectura* es `pedidos`, que es la copia, y una copia se lee.

Por eso `iberia` puede ser virtual sin mentir: hay un sitio donde preguntar, y esta un eslabon
mas abajo. Si la regla mirara la raiz en vez de la raiz de lectura, este caso fallaria — y seria
un falso positivo que obligaria a materializar dos veces lo mismo.
