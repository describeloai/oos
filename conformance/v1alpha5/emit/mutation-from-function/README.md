# v1alpha5 / emit / mutation-from-function

**Regla:** [`01-emision-graphql.md` §2.8](../../../../spec/v1alpha5/01-emision-graphql.md) · **Nivel:** L0

---

`scm.approveOrder` escribe `PurchaseOrder.status`, que está en el contrato. Emite:

```graphql
type Mutation {
  approveOrder(note: String, orderId: String!): ApproveOrderResult!
}
```

`required: true` da el `!`; su ausencia, no. Y `output` emite un tipo propio en vez de
aplanarse: un mapa de parámetros no es un escalar, y GraphQL exige un tipo de retorno.

## Lo que NO sale

`preconditions`, `authorization` e `idempotency` son condiciones que el motor comprueba.
Emitirlas sería **publicar la cerradura junto a la puerta**: no le sirven a quien llama y le
cuentan cómo está cerrada.
