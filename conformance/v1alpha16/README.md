# Suite de conformidad — v1alpha16

**Borrador.** Certifica lo que añade [`spec/v1alpha16/`](../../spec/v1alpha16/) —guardar: el
`ObjectTable`, la `MediaCollection`, `Table.format` y el tipo `Media<…>`—. El alcance sigue
**abierto** y **no es normativo**.

---

## Por qué vive en su propio árbol

Por lo mismo que los demás borradores: un marcador significa *una implementación de referencia
pasa esto*. **Los árboles anteriores no se tocan**: la afirmación que esta versión tiene que
sostener es que no cambia un solo resultado de v1alpha1 a v1alpha15.

## Qué cubre

Nueve casos que aceptan y treinta y ocho que rechazan. Se escribieron **desde la spec, antes que
la implementación** (ORE 0046, E1): los `expects` salen del texto, y se cotejan contra la de
referencia según se implementa (E2). Un caso que la implementación contradiga se discute, no se
ajusta en silencio.

Todos parten del mismo mundo: la fuente `s3_ventas` (un bucket), cuyo paquete tiene el schema
`docs` con el `ObjectTable` `contratos` —los PDF de `Nueva carpeta/contratos/`— y el schema
`ventas` con la tabla `pedidos` —Parquet con partición Hive—; y la base `legal`, cuyo schema
`archivo` tiene la colección `contratos`, y cuya entidad `Contrato` apunta a su PDF.

| | Casos |
|---|---|
| **el `ObjectTable`** (01) | `an-object-table` · `an-object-table-without-media` · `a-media-it-does-not-know` (OOS1004) · `a-listing-ordered-by-a-field` · `an-object-upserted` (OOS1004) · `an-object-table-with-labels` · `an-object-table-with-columns` (OOS1005) · `an-object-table-from-nowhere` (OOS2004) · `an-object-table-in-v1alpha15` (OOS1003) |
| **un nombre, una cosa** | `an-object-table-named-like-its-table` · `a-collection-named-like-a-view` (OOS2035) |
| **se lee como una tabla** (01 §7) | `a-query-over-an-object-table` · `a-column-objects-do-not-have` (OOS2018) · `a-copy-of-a-listing-carries-its-source` (OOS4002: la raíz es el listado, y lleva lo de su `datasource`) |
| **las formas de la colección** (02 §3) | `a-collection-kept-in-the-lake` · `a-virtual-collection` · `a-collection-written-by-code` |
| **la forma** (02 §7) | `a-collection-without-formats` · `a-collection-of-archives` · `the-same-format-twice` · `a-virtual-collection-with-no-origin` · `a-retention-that-is-not-a-duration` (OOS1004) · `a-collection-with-columns` (OOS1005) · `a-collection-owned-by-nobody` (OOS2009) · `a-collection-in-v1alpha15` (OOS1003) |
| **de dónde sale** | `a-collection-from-nowhere` (OOS2018) · `a-source-that-keeps-its-objects-to-itself` (OOS2028) · **`documents-from-images` (OOS2040)** · `a-query-over-a-collection` (OOS2018) |
| **el gobierno** (02 §6) | `a-collection-that-lowers-its-origin` (OOS4012) · `a-copy-without-a-conduit-for-files` (OOS4011) · `a-copy-that-leaks-the-origin-label` (OOS4002) |
| **lo tabular** (03 §1) | `a-table-over-parquet-files` · `a-csv-table-with-its-options` · `a-format-in-v1alpha15` · `csv-options-on-parquet` (OOS1005) · `a-pdf-is-not-rows` · `a-partition-that-is-not-a-column` · `a-listing-without-files` (OOS1004) · `a-csv-table-that-rescues` · `a-parquet-that-rescues` · `a-rescue-that-is-not-text` (OOS1004) |
| **la referencia** (03 §2) | `a-reference-to-an-item` · `a-reference-in-v1alpha15` · `media-without-its-collection` (OOS3001) · `a-reference-to-a-dataset` (OOS2018) · `a-reference-carries-its-collection-label` (OOS4002) |

Los que importan son dos parejas. **`a-virtual-collection` y
`a-copy-without-a-conduit-for-files`** son la misma colección con y sin `virtual`: lo que decide si
cruza `materialization.payload` es si copia bytes, no cómo se llama. Y **`a-collection-kept-in-the-lake`
y `a-collection-that-lowers-its-origin`** son la misma etiqueta en dos sentidos: elevar lo heredado
es lo que una colección está para hacer —una foto de un DNI es `high` aunque el bucket no lo sea—,
y rebajarlo es `OOS4012`, como una propiedad que rebaja la de su entidad.

`a-reference-carries-its-collection-label` es `v1alpha12/a-copy-that-leaks-an-entity-label` con la
etiqueta puesta por el tipo: nadie escribe `high` en la entidad, y la copia de abajo la lleva
porque la propiedad es `Media<…>` de una colección `high`. Su colección es virtual para que sea
la referencia, y no la colección, lo que cruce el conducto.

Lo que se comprueba y no tiene caso propio: el `match` de un `ObjectTable` y de un `format`, las
particiones de un `ObjectTable` y `encoding` (son forma, y la cubren los esquemas de
[`schemas/v1alpha16/`](../../schemas/v1alpha16/)); que una colección `virtual` sirva desde el
origen y que su retención dependa de la del origen (es de quien sirve, no de la gramática: 02 §8).
