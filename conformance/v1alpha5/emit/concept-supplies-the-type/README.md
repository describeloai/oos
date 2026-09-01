# v1alpha5 / emit / concept-supplies-the-type

**Regla:** [`01-emision-graphql.md` §2.2](../../../../spec/v1alpha5/01-emision-graphql.md#22--escalares--y-el-defecto-que-esta-version-destapa) · **Nivel:** L0

---

Una propiedad que declara `is` **no tiene tipo propio**. El esquema lo prohíbe con un
`oneOf` —*el tipo lo pone el concepto, y si la copia deja de coincidir no hay nada a lo que
apelar para decidir quién gana*— así que al emitir hay que ir a buscarlo.

**GraphQL es la única emisión obligada a resolverlo.** ODCS transporta la referencia
(`x-oos-is`) y no pierde nada; un SDL exige escribir un tipo concreto para cada campo, y no
hay dónde poner *«el que diga aquel documento»*.

## Por qué tres escalares y no uno

| propiedad | concepto | tipo de OOS | sale |
|---|---|---|---|
| `born` | `gdpr.birthDate` | `Date` | `Date` + `scalar Date` |
| `reports` | `hr.employeeCount` | `Integer` | `Int` |
| `employeeId` | — declara `type` | `String` | `String` |

Las tres familias del mapeo de §2.2 están representadas a propósito: la que GraphQL nombra
igual, la que **renombra** y la que exige **declarar el escalar**. El defecto que este caso
fija —caerse a `String` cuando no había `type`— habría acertado en `employeeId` por
casualidad, y con un solo escalar el caso habría pasado en verde midiendo nada.

## Lo que estaba en juego

Se encontró emitiendo el primer paquete de vocabulario de verdad: `born` apuntaba a un
concepto `Date` y el SDL decía `born: String`. Nada se ponía rojo —el esquema es válido, y
`graphql-js` lo acepta— y el contrato afirmaba un tipo que el dato no tiene.

> Un contrato al que le falta un campo se nota. Uno que **miente sobre el tipo** de un campo
> se descubre en el consumidor.

Y la contrapartida está en `mustNotContain`: el concepto **no viaja** al SDL. Es la
procedencia del tipo, no parte de la forma — quien consume pide un `Date`, y de dónde salió
ese `Date` no cambia lo que puede pedir.
