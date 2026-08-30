# v1alpha5 / diff / raising-a-label-removes-a-served-field

**Regla:** [`01-emision-graphql.md` §6.4](../../../../spec/v1alpha5/01-emision-graphql.md#64--peldaño-4--es-versionable) · **Nivel:** L0

---

`email` pasa de `low` a `high`. El techo de `contextSurface` es `medium`, así que **el campo
desaparece del SDL**.

Es el **peldaño 4**, y lo que certifica es una ausencia: **no hace falta un código nuevo**.
`OOS5009` —*elevar la etiqueta de una propiedad*— ya existía, ya estaba en el eje `CONSUMER`, y
describe exactamente lo que pasó.

## Por qué eso es la afirmación, y no un detalle

Si emitir a GraphQL hubiera necesitado su propia familia de códigos, querría decir que la
emisión **introdujo un eje de cambio que el artefacto no tenía** — y eso sería un defecto del
mapeo. Que reutilice el registro entero es la prueba de que el SDL es una **proyección** del
bundle y no una superficie con vida propia.

Y trae de regalo lo que un registro comercial de esquemas cobra aparte: los *schema checks* no
son un servicio, **son `ore diff`**.

## El hermano gemelo que NO está clasificado

Hay un segundo camino para sacar `email` del contrato, y produce **el mismo síntoma**:

```
elevar la etiqueta:    low → high,  techo medium     →  OOS5009 · CONSUMER · rompedor
endurecer el techo:    medium → low, etiqueta low    →  «compatible»
```

El segundo está en [`91-versioning` §5.4](../../../../spec/v1alpha1/91-versioning.md) en la
lista de cambios **compatibles**, literalmente como *«endurecer un conducto»*. Y lo era: hasta
esta versión, endurecer un conducto solo restringía materialización, exportación y log —
operaciones internas, sin consumidor al otro lado.

> **`contextSurface` era el único conducto sin consumidor, y la tabla de compatibilidad se
> escribió cuando eso era cierto.**

Por el criterio del propio registro —*un código por síntoma, no por causa*— los dos cambios
deberían compartir veredicto: **una propiedad deja de ser legible por el conducto.** Elevar la
etiqueta y bajar el techo son dos causas de un solo síntoma.

**No es un código que falte: es una fila mal clasificada**, y arreglarla es de v1alpha1.
Anotado en [`00-scope` §8](../../../../spec/v1alpha5/00-scope.md).
