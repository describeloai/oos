# 01 · Los tipos

**Estado:** normativo. Parte de OOS v1alpha17.

Tres tipos nuevos y un valor cambiado. Los cuatro existen porque un resultado sacado de un medio
**tiene forma** —una caja, una lista de segmentos, un vector— y sin ella acaba como JSON en una
cadena: lo que el estado del arte señala como el defecto de Foundry (ORE 0049, anexo).

## 1. `Struct<…>`

```yaml
columns:
  factura:
    type: "Struct<numero: String, total: Decimal<12, 2>, fecha: Date>"
```

- **Campos con nombre y tipo**, en orden. El orden es parte del tipo: dos structs con los mismos
  campos en otro orden son tipos distintos (así los comparan Iceberg, Parquet y DuckDB).
- **Un campo** es un nombre (`[a-z_][a-z0-9_]*`, único en el struct) y un tipo de este
  documento o de los escalares de siempre, sin `Opaque` ni `Media<…>` (§4).
- **Anida**: un campo puede ser otro `Struct<…>`, un `list<…>` o un `Vector<n>`.
- **Se escribe** `Struct<a: T, b: U>`, con un espacio tras cada `:` y cada `,`. Es la forma
  canónica: `parse_type(t.to_string()) == t` se cumple también aquí.

## 2. `list<…>` y `Vector<n>`

- **`list<T>`** admite, además de los escalares de v1alpha1, `Struct<…>` y `Anchor`:
  `list<Struct<t: Float, texto: String>>` es una lista de segmentos.
- **`Vector<n>`** es una lista de **exactamente `n`** valores `Float32`, `1 ≤ n ≤ 16000`. Es un
  tipo aparte y no `list<Float>` porque su dimensión es parte del contrato: un índice de
  vecinos, una distancia y un modelo de embeddings solo se entienden con la dimensión fija
  (`vector(n)` de pgvector, `FLOAT[n]` de DuckDB, `FixedSizeList<float32>` de Arrow y Lance).

| en | `Struct<…>` | `list<…>` | `Vector<n>` |
|---|---|---|---|
| Arrow | `Struct` | `List` | `FixedSizeList<Float32, n>` |
| Parquet | grupo | `LIST` | `LIST` de `FLOAT` (la dimensión, en el esquema del lago) |
| Iceberg | `struct` | `list` | `list<float>` (la dimensión, en el contrato) |
| DuckDB | `STRUCT` | `LIST` | `FLOAT[n]` |

Un `Vector<n>` con un valor de otra longitud **no se escribe**: lo rechaza quien escribe, con la
columna, la fila y las dos longitudes.

## 3. El valor de `Media<c>`: una referencia

En v1alpha16 el valor de `Media<c>` era la huella del ítem (`String`). En v1alpha17 es **la
referencia entera**, con la forma del tipo lógico `FILE` de Parquet —que Databricks usa en su
tipo `FILE` y que Iceberg propone para v4— y los campos que ORE necesita:

| campo | tipo | de | regla |
|---|---|---|---|
| `uri` | `String` | Parquet `FILE.uri` | `ore://<base>.<schema>.<colección>/<ruta>?v=<versión>` |
| `collection` | `String` | — | el nombre cualificado de `c` |
| `path` | `String` | — | la clave relativa del ítem; **no** es su identidad |
| `version` | `String` | S3 `VersionId`, GCS *generation* | fija los bytes; nula, «la actual» |
| `digest` | `String` | descriptor OCI, RFC 9530 | `sha256:<hex>`; nulo mientras no se conoce (§3.1) |
| `size` | `Integer` | Parquet `FILE.size` | en bytes |
| `content_type` | `String` | Parquet `FILE.content_type`, RFC 6838 | el tipo efectivo |
| `content_type_detected` | `String` | WHATWG MIME Sniffing | el que dicen los bytes, si difiere |
| `checksum` | `String` | Parquet `FILE.checksum`, S3 | `<alg>:<valor>` (`crc64nvme:…`); validador, **no** identidad |
| `annotations` | `Struct<…>` o nulo | OCI `annotations` | lo técnico del medio: `width`, `height`, `pages`, `duration_s` |

- **Nunca en la referencia**: una URL firmada, una credencial, quién autoriza.
- **La columna** que respalda una propiedad `Media<c>` es de tipo `Media<c>`, no `String`.
  Físicamente es un struct con estos campos y estos nombres (los de Parquet `FILE` donde los
  hay); el motor puede adoptar el tipo `FILE` del formato cuando exista, sin cambiar el valor.

### 3.1 La identidad

- **Si hay `digest`, es la identidad**: dos referencias con el mismo `digest` son el mismo
  contenido, cambien `path`, `version` o `checksum`.
- **Si no lo hay** (un ítem virtual cuyos bytes aún no se han leído enteros), la identidad es el
  **localizador fijado** `(collection, path, version)`, que en un origen versionado es inmutable.
- **Sin `version` ni `digest`** no hay identidad fuerte: la referencia vale para servir, no para
  decir que dos cosas son la misma.

## 4. Las reglas

| | código | |
|---|---|---|
| `Struct<…>`, `Vector<n>` o `Anchor` en v1alpha16 o antes | `OOS3001` | tipos que no existían |
| un `Struct` sin campos, con un nombre repetido o mal formado | `OOS3007` | |
| `Vector<n>` sin `n`, o con `n` fuera de `1 ≤ n ≤ 16000` | `OOS3007` | |
| un campo de `Struct` de tipo `Opaque` o `Media<…>` | `OOS3007` | una referencia es una columna, no un campo suelto (el ítem se referencia una vez por fila) |
| `list<list<…>>` | `OOS3007` | una lista de listas se escribe como lista de structs |
| una escritura no canónica (`Struct<a:String>`) | — | se acepta y se canoniza; el digest del paquete usa la canónica |

`OOS3007` es **un tipo compuesto mal formado**; `OOS3001` sigue siendo un tipo que no existe.
