# v1alpha5 / emit / partial-key-fails

**Regla:** [`01-emision-graphql.md` §5](../../../../spec/v1alpha5/01-emision-graphql.md#5-cuándo-la-emisión-falla) · **Nivel:** L0

---

`Employee` declara `uniqueKeys: [[nationalId]]`, y `nationalId` está en `critical` sobre un
techo `medium`. **Una propiedad puede ser clave y estar gobernada por encima del techo**, y
este caso fija qué pasa entonces.

## Las tres salidas, y por qué solo una es correcta

| | Por qué no |
|---|---|
| emitir `@key(fields: "nationalId")` | referencia un campo que no está en el tipo: **el SDL sería inválido** |
| **omitir ese `@key`** y emitir el resto | **es la trampa.** Federation usaría la clave que queda como si fuera la identidad completa, y dos entidades que solo se distinguían por `nationalId` se resolverían como una |
| **rechazar la emisión del tipo** | ✅ |

La segunda es la que hay que dejar escrita, porque es la que uno escribiría sin pensarlo. Una
clave no es una anotación: **es una afirmación sobre qué distingue una instancia de otra.**
Emitir menos claves de las declaradas no sirve de menos — **afirma otra cosa.**

## Y no es lo mismo que podar un campo

Podar `nationalId` como propiedad es correcto y es lo que hace
[`ceiling-prunes-the-classified`](../ceiling-prunes-the-classified). Lo que no se puede es
podarla **y seguir hablando de identidad como si nada**. La diferencia entre las dos
situaciones es que la segunda cambia el significado de lo que sí se emite.
