# v1alpha5 / emit / entity-without-binding-fails

**Regla:** [`01-emision-graphql.md` §5](../../../../spec/v1alpha5/01-emision-graphql.md#5-cuándo-la-emisión-falla) · **Nivel:** L0

---

`Employee` está declarada, clasificada y por debajo del techo. No tiene `Binding`.

Falla, y es **la misma causa exacta** que
[`emit/ossie-requires-binding`](../../../emit/ossie-requires-binding): lo que Ossie necesita
del binding —`Dataset.source` y `Field.expression`— es lo que GraphQL necesita para tener
**resolvers**.

## Lo que separa este caso de un error de validación

El paquete **valida**. Una entidad sin binding es legítima en OOS: se puede declarar el
dominio antes de saber dónde vive. Lo que no se puede es **publicar un contrato de consumo**
de algo que nadie sabe resolver.

> Un campo en un SDL es una promesa de que preguntar por él devuelve algo. Emitirlo sin
> resolver convierte el contrato en una lista de deseos.

Y por eso la comprobación es **de la emisión y no del compilador**: la misma entidad, en el
mismo paquete, es válida para `ore validate` y no emitible por este conducto.
