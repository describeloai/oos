# v1alpha5 / emit / entity-emits-type

**Regla:** [`01-emision-graphql.md` §2](../../../../spec/v1alpha5/01-emision-graphql.md#2-el-mapeo) · **Nivel:** L0

---

Una entidad completa y el SDL que produce. Certifica el **peldaño 1** de
[§6.1](../../../../spec/v1alpha5/01-emision-graphql.md#61--peldaño-1--existe): que el mapeo
del núcleo está definido y produce un esquema que un motor ajeno acepta.

## Lo que afirma, y por qué cada cosa

| | |
|---|---|
| `Employee` → `type Employee` | el `namespace` es el subgrafo, **no se prefija al nombre** |
| `employeeId` → `ID!` | es clave primaria; el resto es nulable porque OOS no tiene `required` en una propiedad |
| `primaryKey` y `uniqueKeys` → **dos `@key`** | Federation admite varios, así que la traducción es total |
| `manager` → `Employee` | `many_to_one` con `required: false` da el tipo nulable, sin lista |
| `managerId` → campo aparte | *«`managerId` es un DATO y `manager` es una ARISTA»*: cada uno sale por su lado |
| `Money<EUR, 2>` → `scalar Money_EUR_2` | la unidad es **parte del tipo**. Un `Float` haría que sumar euros y dólares dejara de fallar |

## Y lo que **no** sale

`nature` no se emite: es una distinción de modelado que ya se comprobó al compilar. `via`
tampoco: el dato que sostiene la arista ya salió como propiedad, y emitirlo dos veces sería
declarar lo mismo dos veces.
