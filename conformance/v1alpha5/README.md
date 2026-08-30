# Suite de conformidad — v1alpha5

**Borrador — 8 casos.** Certifica la emisión a GraphQL de
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
| `digest/sdl-ignores-how-it-was-written` | dos escrituras del mismo paquete emiten el **mismo SDL** | **3 · es identificable** |
| `diff/raising-a-label-removes-a-served-field` | sacar un campo del contrato se clasifica **sin un código nuevo** | **4 · es versionable** |

## Los dos que cargan la tesis

**`ceiling-prunes-the-classified`** es el único cuya ausencia haría el producto **falso** en
vez de incompleto. Afirma las dos direcciones —una propiedad de más es una fuga de datos, una
de menos es una fuga de disponibilidad— y que lo podado sale **ausente**, no prohibido.

**`orphan-relation-is-pruned`** es el que menos se ve venir. Poda una arista cuyo destino
desapareció, y no por limpieza: un campo `patient: Diagnosis` revela que existe un tipo
`Diagnosis` y que un pedido se relaciona con uno. Es el peldaño de metadatos que `DESIGN` §4.1
llama *el más delicado y el que nadie discute* — **saber que el paciente X está enlazado con
la clínica oncológica Y es el diagnóstico.**

## Los cuatro peldaños, certificados

Los peldaños están en
[`01-emision-graphql` §6](../../spec/v1alpha5/01-emision-graphql.md#6-listo--cuatro-peldaños).
Los dos últimos necesitaban casos de otra forma, y por eso viven fuera de `emit/`:

**`digest/sdl-ignores-how-it-was-written`** compara **dos escrituras**, no dos ejecuciones.
Ejecutar dos veces sobre el mismo fichero solo descarta un mapa sin orden o un reloj; lo que
rompe `G1` de verdad es que **dos autores** describan la misma ontología y obtengan contratos
distintos. Los dos árboles ya dan el mismo digest de paquete —`sha256:80541eff…`—, así que la
forma canónica normaliza las dos diferencias y el caso está bien fundado: lo que exige es que
**la emisión pase por ella**.

**`raising-a-label-removes-a-served-field`** certifica una **ausencia**: que no hace falta un
código nuevo. Medido contra el motor:

```
OOS5009 · CONSUMER · hr.Customer.email · gdpr.sensitivity:low -> high
veredictos: CONSUMER breaking · POLICY compatible · bump major
```

Si emitir a GraphQL hubiera necesitado su propia familia, querría decir que la emisión
introdujo un eje de cambio que el artefacto no tenía. Que reutilice el registro entero es la
prueba de que el SDL es una **proyección** del bundle y no una superficie con vida propia.

## Lo que estos casos encontraron al escribirse

Tres cosas, ninguna de esta versión, las tres anotadas en
[`00-scope` §8](../../spec/v1alpha5/00-scope.md):

1. **El vocabulario de escalares está duplicado y divergente** — el esquema declara siete
   nombres en minúscula que no usa ni un documento del repositorio; el motor acepta diez
   capitalizados; las 375 propiedades existentes validan por la puerta de escape de
   `qualifiedName`.
2. **Una fila de la tabla de compatibilidad quedó obsoleta.** Hay dos caminos para sacar un
   campo del contrato y producen **el mismo síntoma**: elevar la etiqueta de la propiedad
   —`OOS5009`, ruptura de `CONSUMER`— y **endurecer el techo del conducto**, que
   [`91-versioning` §5.4](../../spec/v1alpha1/91-versioning.md) lista literalmente entre los
   cambios **compatibles**. Y lo era: hasta esta versión, endurecer un conducto solo
   restringía materialización, exportación y log — sin consumidor al otro lado.
   `contextSurface` era el único conducto sin consumidor, **y la tabla se escribió cuando eso
   era cierto**. Por el criterio del propio registro —*un código por síntoma, no por causa*—
   los dos deberían compartir veredicto. No es un código que falte: **es una fila mal
   clasificada**.
3. **Un fichero con varios documentos YAML pierde todo menos el primero, en silencio.** Se
   descubrió al escribir `orphan-relation-is-pruned` con dos `Binding` separados por `---`:
   el segundo no existía para el compilador, y `ore validate` decía *ok · sin errores* aunque
   apuntara a un `datasourceRef` inexistente. La especificación **no dice nada** sobre varios
   documentos por fichero y **ningún caso de los 146 usa `---`**. El caso está partido en dos
   ficheros; la ambigüedad sigue ahí.
