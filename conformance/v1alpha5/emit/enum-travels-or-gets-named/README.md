# v1alpha5 / emit / enum-travels-or-gets-named

**Regla:** [`01-emision-graphql.md` §2.10](../../../../spec/v1alpha5/01-emision-graphql.md#210--enumeraciones--y-que-pasa-cuando-el-valor-no-es-un-identificador) · **Nivel:** L0

---

`00-scope` §5 daba el mapeo por medido —`enum` → `enum` ✓— y le faltaba la mitad que decide:
**no todo `enum` de OOS puede ser un `enum` de GraphQL.** Un valor de enumeración de GraphQL
es un identificador; `EUR` cabe y `es-ES` no. Y no es un caso rebuscado: así se escribe una
lengua en todas partes.

## Las dos salidas, y la que se comparte

| propiedad | de dónde sale el conjunto | sale |
|---|---|---|
| `Order.currency` · `Refund.currency` | `is: iso.currencyCode` | **un solo** `enum Iso_currencyCode` |
| `Order.locale` | `is: iso.languageTag` | `scalar Iso_languageTag` |
| `Order.status` | declarado en la propiedad | `enum Order_status` |

**`currency` sale dos veces con el mismo tipo**, y ahí está el motivo de nombrar por el
concepto y no por el campo: dos columnas que son la misma moneda con dos tipos idénticos y
distintos dejan al cliente pasar una donde va la otra. Nombrarlo por el campo habría dado
`Order_currency` y `Refund_currency`, que es la peor clase de tipo: uno que parece el mismo.

**`status` no es un concepto y por eso se declara en la propiedad.** `02-property` §2 usa
justo esta pareja para explicar la línea: un código de moneda es ISO 4217 en los quince
sistemas donde aparezca; un estado de pedido no lo es en ninguno.

## Lo que estaba en juego

El emisor no emitía enums **en absoluto** —ni heredados ni declarados— y todos salían
`String`. Nada se ponía rojo: el esquema es válido y `graphql-js` lo acepta.

> Un campo `String` donde había un conjunto cerrado no es un contrato incompleto: es uno que
> **admite lo que el dato no admite**. El consumidor deja de tener forma de saber que había
> un conjunto, y un agente deja de tener forma de no inventárselo.

Caerse al escalar base era además la salida que §3.1 ya había descartado una vez, para
`Money<EUR, 2>`: cuando la restricción no cabe en el sistema de tipos del destino, se emite un
tipo propio que la **nombra**. Aquí es la misma decisión aplicada al otro sitio donde hacía
falta, y por eso `Iso_languageTag` sale como escalar y no desaparece.
