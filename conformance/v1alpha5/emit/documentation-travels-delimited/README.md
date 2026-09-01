# v1alpha5 / emit / documentation-travels-delimited

**Regla:** [`01-emision-graphql.md` §2.9](../../../../spec/v1alpha5/01-emision-graphql.md#29--documentación) · **Nivel:** L0

---

§2.9 era normativa y **no la implementaba nadie**: el emisor no escribía un solo docstring.
Un esquema sin documentación es válido y `graphql-js` lo acepta, así que nada se ponía rojo —
y quince conceptos del RGPD llegaban a un agente sin una palabra de lo que significan.

> Un contrato que dice **qué se puede pedir** y no dice **qué es** obliga al consumidor a
> adivinar el significado. Que es exactamente el problema que la ontología existe para
> quitar.

## Las cuatro combinaciones, y qué decide cada una

| campo | qué lleva | qué sale |
|---|---|---|
| `customerId` | nada | **ningún bloque** — un docstring vacío es ruido, y cambia el digest |
| `nickname` | `description` propia | la prosa |
| `email` | `is: gdpr.personalEmail` | prosa, `synonyms` y `guidance` **heredados**, sin escribir una palabra aquí |
| `vatId` | solo `synonyms` | el bloque empieza por los delimitados |

El tipo también lleva el suyo, y sale de **`metadata`** y no de `spec`: en una entidad la
prosa documenta *el documento*; dentro de una propiedad documenta *el dato*. Son dos sitios
distintos porque son dos sujetos distintos.

## Las dos cosas que el caso prohíbe

**Nada de directivas.** `aiContext` es *descriptivo, nunca directivo*, y una directiva es una
instrucción a la herramienta. Un `@synonyms(...)` convertiría en imperativo lo que se adoptó
con la condición expresa de que no lo fuera.

**Los sinónimos salen ordenados**, aunque el fichero diga `mail, correo, email`. No es
estética: la forma canónica los trata como un **conjunto** —`synonyms` no está entre las
secuencias de `90-canonical-form`, al contrario que `enum`—, así que dos ficheros que solo
difieren en su orden **tienen el mismo digest**. Emitirlos en el orden del fichero haría que
el SDL dejara de ser función del bundle, que es el peldaño 3 de §6.

## Y de dónde viene el valor

`02-property` §2 dice que `aiContext` es *«el campo que más gana al subir de nivel»*:
declarar una vez que al `personalEmail` el negocio lo llama *correo*, *email* o *mail* evita
que cada una de cuatro mil columnas lo vuelva a adivinar. Este caso es lo que hace que esa
frase llegue hasta el consumidor — porque un sinónimo declarado en un concepto que nadie
emite no se lo ahorra a nadie.
