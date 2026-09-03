# Un efecto sobre un objeto que no acepta que lo actualicen

Un efecto cambia una propiedad de algo que **ya está**, así que es un `update`. Si la tabla de la
que sale la entidad no lo acepta, el paquete afirma algo que el origen desmentiría.

La tabla de aquí **no declara `writes` en absoluto**, y eso ya es la respuesta: la ausencia es una
negativa, igual que `reads: none` significa *no se le puede pedir nada*. Es la doctrina de OOS
desde v1alpha1 — lo que no se declara, no se puede — y por eso el caso no necesita un
`writes: none` explícito para ser exactamente el mismo caso.

El camino que lo descubre es el mismo que recorre la lectura: entidad, `backedBy`, vista, raíz,
tabla. Nadie declara nada dos veces.

Se rechaza con `OOS7012`.
