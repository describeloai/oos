# Suite de conformidad — v1alpha12

**Borrador.** Certifica el kind de [`spec/v1alpha12/`](../../spec/v1alpha12/) —`Dataset`, lo que
un inquilino tiene como un documento— y lo que cambia en `View` y `Entity` para componer sobre
él. El alcance sigue **abierto** y **no es normativo**.

---

## Por qué vive en su propio árbol

Por lo mismo que los demás borradores: un marcador significa *una implementación de referencia
pasa esto*, y mezclar casos de un borrador con los de v1alpha1 daría un número que ya no se sabe
qué mide. **Los árboles anteriores no se tocan**: la afirmación que esta versión tiene que
sostener es que no cambia un solo resultado de v1alpha1 a v1alpha11 —y en particular que los
85 ficheros de conformance que declaran `materialized` siguen dando lo que daban.

## Qué cubre

Cuatro casos que aceptan y nueve que rechazan:

| | Casos |
|---|---|
| **las dos formas** | `a-copy-with-its-plan` · `a-dataset-written-by-code` · `a-dataset-with-both-forms` · `a-dataset-with-neither` |
| **compone** | `a-view-over-a-dataset` · `a-dataset-over-a-view` · `a-field-the-dataset-does-not-expose` · `a-chain-that-comes-back` |
| **la costura no se pierde** | `a-copy-without-a-conduit` · `a-copy-that-leaks-an-entity-label` · `an-append-dataset-backing-an-entity` |
| **lo que se retira / nada anterior cambia** | `a-view-that-still-says-materialized` · `a-dataset-in-v1alpha11` |

Los tres de **la costura no se pierde** son los que importan: son los mismos tres casos de
v1alpha7/v1alpha8 (`materialized-view-without-conduit`, `materialized-view-leaks-entity-label`,
`append-changes-back-a-mutable-entity`) con un `Dataset` donde había una `View` con
`materialized`, y tienen que dar **el mismo código**. Es lo que demuestra que la costura se
movió y no se perdió.

Lo que no tiene caso propio y se comprueba con la forma (`OOS1004`, cubierta por el schema con
21 documentos): `upsert` sin `key`, `key` con `append`, `fields` sin `from`, `changes` en un
mantenido, `history` vacío, `View.freshness` en v1alpha12 (se retira con `materialized`: la
frescura es del dataset).

## Los códigos

Ninguno nuevo. `OOS1003` (versión), `OOS1004` (forma), `OOS1005` (clave que no es de aquí),
`OOS2018` (un nombre que no se expone), `OOS2019` (ciclo), `OOS4011` y `OOS4002` (el conducto),
`OOS2021` (sin retractación no se mantiene lo mutable).
