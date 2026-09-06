# v1alpha8 / diff / a-loosened-freshness-promises-less

**Regla:** [`91-versioning.md` §5.1](../../../../spec/v1alpha1/91-versioning.md#51--rompedor-en-consumer) ·
**Código:** `OOS5030` · **Nivel:** L0

---

`freshness: 15m` pasa a `24h`. Nadie recibe un error y todo el mundo recibe datos más viejos de lo
prometido.

## Por qué este rompe y los otros dos de este trío informan

Porque **la frescura se decide**. `ore discover` emite `reads` y `changes` desde el catálogo y **no
emite `freshness`** — *«son decisiones de operación con coste, y proponerlas sería exactamente
inventar»*. Las dos caras de la tabla son un hecho del origen; esto es una promesa, y aflojarla es
un acto de quien publica.

Por eso cae en `CONSUMER` —hay alguien al otro lado a quien se le prometió— y los otros dos en
`INDEX`, que informa sin bloquear.

## Lo que NO dice

Que poner una `freshness` donde no había sea un cambio. **No lo es**: una promesa nueva constriñe a
quien publica, no a quien lee. El código solo mira aflojar — o retirarla, que es la forma extrema.
