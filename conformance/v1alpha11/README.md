# Suite de conformidad — v1alpha11

**Borrador.** Certifica el kind de [`spec/v1alpha11/`](../../spec/v1alpha11/) —`TrainedModel`,
el modelo entrenado como asset del registro—. El alcance sigue **abierto** y **no es
normativo**.

---

## Por que vive en su propio arbol

Por lo mismo que los demas borradores: un marcador significa *una implementacion de referencia
pasa esto*, y mezclar casos de un borrador con los de v1alpha1 daria un numero que ya no se sabe
que mide. **Los arboles anteriores no se tocan**: la afirmacion que esta version tiene que
sostener es que no cambia un solo resultado de v1alpha1 a v1alpha10.

## Que cubre

Un caso que acepta y cinco que rechazan:

| | Casos |
|---|---|
| **la forma minima, y lo que dice de si** | `a-trained-model-with-its-lineage` · `a-trained-model-without-digest` · `a-trained-model-with-version-zero` |
| **el linaje resuelve** | `a-trained-model-trained-from-nothing` |
| **lo que no es de aqui** | `a-trained-model-with-metrics` |
| **nada anterior cambia** | `a-trained-model-in-v1alpha10` |

## Los codigos

Ninguno nuevo. `OOS1003` (version), `OOS1004` (forma), `OOS1005` (clave que no es de aqui),
`OOS2005` (una referencia que no resuelve).
