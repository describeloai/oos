# v1alpha5 / emit / quorum-travels-to-the-contract

**Regla:** [`01-emision-graphql.md` §2.8.1](../../../../spec/v1alpha5/01-emision-graphql.md) · **Nivel:** L0

---

La misma función de [`human-approval-changes-the-return-type`](../human-approval-changes-the-return-type)
con `quorum: 2`:

```graphql
type Mutation {
  "Requiere 2 firmas humanas distintas."
  approveOrder(note: String, orderId: String!): ApprovalRequired!
}
```

## Dos sitios, y no es duplicación

| Dónde | Quién lo lee | Cuándo |
|---|---|---|
| la documentación del campo | una **persona** | antes de escribir el cliente |
| `ApprovalRequired.quorum` | el **programa** | en cada respuesta |

Ninguno de los dos sirve para lo del otro: una línea de documentación no se puede evaluar, y
un campo de la respuesta no se lee mientras se diseña.

## Y va en documentación, no en una directiva

Lo que se emite es **descriptivo, nunca directivo** — la misma condición con la que se adoptó
`aiContext`. Una directiva es una instrucción a la herramienta, y esto es una descripción
para quien la lee.
