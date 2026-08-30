# v1alpha5 / emit / human-approval-changes-the-return-type

**Regla:** [`01-emision-graphql.md` §2.8.1](../../../../spec/v1alpha5/01-emision-graphql.md) · **Nivel:** L0

---

La misma función que [`mutation-from-function`](../mutation-from-function), con un endoso
más. El tipo de retorno cambia:

```graphql
approveOrder(note: String, orderId: String!): ApprovalRequired!
```

## No es política en el contrato: es aritmética del tipo

`01-efectos` §3.2 fija que `humanApproval` es un endosante **dinámico** — *«el compilador
verifica que la declaración cubre la carencia; **el motor verifica el acto**»*. Así que en el
instante de la llamada **el acto no ha ocurrido**: no hay un `status` que devolver, y tipar la
respuesta como si lo hubiera sería mentir en el contrato.

## Y esto es `G2` en la dirección de escritura

Es la simetría exacta de lo que el conducto hace en lectura:

| | Lectura | Escritura |
|---|---|---|
| lo relaja | un **desclasificador** | un **endosante** |
| en el contrato | el campo **está ausente** | la mutación **devuelve otra cosa** |

> **Una escritura que exige firma humana no se puede consumir como si no la exigiera, porque
> el tipo no encaja.**

Quien esperaba `ApproveOrderResult` no compila. Y esa garantía **no era expresable** mientras
el endoso vivía solo dentro del artefacto: el consumidor no lo veía.

## El nombre que ya tenía

Esto es lo que `00-overview` §7.2 llamaba `autonomy` y declaraba inexistente. Existe desde
v1alpha2, se llama `humanApproval`, y lo que faltaba no era el vocabulario — era **traerlo al
contrato**.
