# Suite de conformidad — v1alpha5

**Borrador — 6 casos.** Certifica la emisión a GraphQL de
[`spec/v1alpha5/`](../../spec/v1alpha5/), cuyo alcance sigue **abierto** y que **no es
normativo**.

---

## Por qué vive en su propio árbol

Por lo mismo que los de v1alpha2, v1alpha3 y v1alpha4. `74/74` significa algo preciso —*una
implementación de referencia pasa la especificación completa*— y mezclar casos de un borrador
no daría un número falso: daría **un número que ya no se sabe qué mide**.

Cinco árboles, cinco marcadores.

## Qué afirma

Ningún caso lleva código de error. **No es una economía: es una consecuencia del molde.** Una
emisión imposible es una *expectativa* —`expects: emit-fails`—, no un diagnóstico sobre el
documento: los paquetes de los tres últimos casos **validan perfectamente**. Lo que no pueden
es viajar por este conducto.

| Caso | Afirma | Peldaño |
|---|---|---|
| `emit/entity-emits-type` | el núcleo del mapeo: tipo, `@key` múltiple, nulabilidad derivada, escalar especializado | **1 · existe** |
| `emit/ceiling-prunes-the-classified` | el techo del conducto quita **exactamente** lo gobernado | **2 · es honesto** |
| `emit/orphan-relation-is-pruned` | una arista hacia un tipo no emitido **tampoco se emite** | **2 · es honesto** |
| `emit/nothing-survives-the-ceiling` | si no queda un tipo, no hay esquema que emitir | — |
| `emit/entity-without-binding-fails` | sin `Binding` no hay resolver, y un campo sin resolver es una promesa vacía | — |
| `emit/partial-key-fails` | **media clave no es una clave**: un `@key` incompleto es una identidad falsa | — |

## Los dos que cargan la tesis

**`ceiling-prunes-the-classified`** es el único cuya ausencia haría el producto **falso** en
vez de incompleto. Afirma las dos direcciones —una propiedad de más es una fuga de datos, una
de menos es una fuga de disponibilidad— y que lo podado sale **ausente**, no prohibido.

**`orphan-relation-is-pruned`** es el que menos se ve venir. Poda una arista cuyo destino
desapareció, y no por limpieza: un campo `patient: Diagnosis` revela que existe un tipo
`Diagnosis` y que un pedido se relaciona con uno. Es el peldaño de metadatos que `DESIGN` §4.1
llama *el más delicado y el que nadie discute* — **saber que el paciente X está enlazado con
la clínica oncológica Y es el diagnóstico.**

## Qué falta para los peldaños 3 y 4

Los cuatro peldaños están en
[`01-emision-graphql` §6](../../spec/v1alpha5/01-emision-graphql.md#6-listo--cuatro-peldaños).
Este árbol certifica los dos primeros. Los otros dos necesitan casos de otra forma:

- **3 · es identificable** — un caso `digest/`: el mismo bundle emite el mismo SDL byte a
  byte. Es `G1` sobre la emisión, y se afirma comparando dos ejecuciones, no una estructura.
- **4 · es versionable** — un caso `diff/`: retirar una propiedad servida se clasifica como
  ruptura de `CONSUMER` **sin añadir un código**. Si hiciera falta uno nuevo, el defecto
  estaría en el mapeo, no en el registro.

## Lo que estos casos encontraron al escribirse

Dos cosas, ninguna de esta versión, las dos anotadas en
[`00-scope` §8](../../spec/v1alpha5/00-scope.md):

1. **El vocabulario de escalares está duplicado y divergente** — el esquema declara siete
   nombres en minúscula que no usa ni un documento del repositorio; el motor acepta diez
   capitalizados; las 375 propiedades existentes validan por la puerta de escape de
   `qualifiedName`.
2. **Un fichero con varios documentos YAML pierde todo menos el primero, en silencio.** Se
   descubrió al escribir `orphan-relation-is-pruned` con dos `Binding` separados por `---`:
   el segundo no existía para el compilador, y `ore validate` decía *ok · sin errores* aunque
   apuntara a un `datasourceRef` inexistente. La especificación **no dice nada** sobre varios
   documentos por fichero y **ningún caso de los 146 usa `---`**. El caso está partido en dos
   ficheros; la ambigüedad sigue ahí.
