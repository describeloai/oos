# Suite de conformidad — v1alpha9

**Borrador.** Certifica el modelo y la funcion con `runtime: model` de
[`spec/v1alpha9/`](../../spec/v1alpha9/), cuyo alcance sigue **abierto** y que **no es normativo**.

---

## Por que vive en su propio arbol

Por lo mismo que los demas borradores: un marcador significa *una implementacion de referencia
pasa esto*, y mezclar casos de un borrador con los de v1alpha1 daria un numero que ya no se sabe
que mide. **Los arboles anteriores no se tocan**: la afirmacion que esta version tiene que
sostener es que no cambia un solo resultado de v1alpha1 a v1alpha8.

## Que cubre

Dos casos que aceptan y siete que rechazan. Se agrupan en tres cosas que afirmar:

| | Casos |
|---|---|
| **el modelo se sostiene solo, y no es una configuracion** | `a-model-in-the-tree` · `a-model-without-profile` · `a-tier-nobody-serves` · `a-model-with-a-runtime` · `a-model-in-v1alpha8` |
| **la funcion lo invoca como un nodo del arbol** | `a-function-invokes-a-model` · `a-function-invokes-a-model-that-is-not-there` |
| **un runtime, una forma** | `a-model-runtime-with-an-entrypoint` · `a-prompt-without-a-model` |

## Los codigos

Ninguno nuevo: `OOS1003` (version), `OOS1004` (forma), `OOS1005` (clave que no es de aqui) y
`OOS2005` (una referencia que no resuelve). Lo que la salida de un modelo sin endoso puede
escribir lo cobra `OOS7002`, que es de v1alpha2 y cuyo caso vive alli.

## De donde sale

De la E0 de ORE 0027 (2026-09-16): una celda alcanzo un modelo servido por un perfil, una
`Function` lo nombro y su salida aterrizo en el arbol. Lo que hizo falta para que compilara
—`runtime: model` sin comprobar, el prompt en una extension, la propiedad en `untrusted`—
es lo que esta version fija.
