# 01 · El binario

**Estado:** normativo. Parte de OOS v1alpha35.

Un tipo para columnas de `Table`, `Dataset` y `View`, y para propiedades de entidad. Existe porque un valor
que son bytes **es de una naturaleza** —se guarda, se mide, se compara por igualdad y se devuelve intacto— y
`Opaque` dice lo contrario: *«no lo modelamos»* ([`00`](00-scope.md) §1).

## 1. `Binary`

```yaml
columns:
  guid:
    type: "Binary"                 # RAW(16) de Oracle, bytea, un uuid como bytes
    physicalType: "RAW(16)"
  firma:
    type: "Binary"
  miniatura:
    type: "Binary"                 # una imagen pequeña, que cabe en la fila
```

- Un tipo **sin argumentos**: una secuencia de bytes de cualquier longitud, **incluida la vacía**. Como `Anchor`
  (v1alpha17), es un nombre que añade esta versión: **no entra en los diez escalares** de
  [v1alpha1 `02-entity` §3.1](../v1alpha1/02-entity.md), que quedan como estaban.
- **El nulo y el vacío son distintos.** Una columna `Binary` con `NULL` no tiene valor; con una secuencia
  de cero bytes lo tiene, y es vacío.
- **`physicalType`** guarda el tipo del origen (`RAW(16)`, `bytea`, `BYTES`, `blob`), como en los demás tipos.

## 2. El valor y cómo se compara

- Un valor **es** su secuencia de bytes; no tiene codificación de texto ni juego de caracteres.
- Dos valores son **iguales si lo son byte a byte**. Se ordenan **lexicográficamente por byte sin signo**
  (como `memcmp`).
- **No** se admite `like`, aritmética ni conversión implícita a `String`. Lo que mira dentro de los bytes
  (longitud, subcadena, hash, decodificar) lo da el motor que calcula, no el documento.
- Vale como clave (`primaryKey`, `key`): la igualdad es exacta, a diferencia de la geometría.

## 3. Cómo viaja en texto

En una fila JSON, un caso de prueba o una muestra, el valor es su **base64** (RFC 4648 §4, alfabeto
estándar con relleno `=`), en una cadena. El vacío es `""`; el nulo es el nulo del formato, no una cadena.

- **Sin saltos de línea** ni espacios dentro de la cadena.
- Una cadena que no es base64 válido **no es un `Binary`**: lo rechaza quien lo escribe, con la columna y la fila.
- **La geometría no cambia**: su texto sigue siendo el WKB en hexadecimal (v1alpha32 01 §5).

## 4. Correspondencia

| en | `Binary` |
|---|---|
| Arrow | `Binary` (o `LargeBinary` si la columna lo pide por tamaño) |
| Parquet | `BYTE_ARRAY` |
| Iceberg | `binary` |
| DuckDB | `BLOB` |

Y con los orígenes: `RAW`, `LONG RAW` y `BLOB` (Oracle), `bytea`, `blob` (Cassandra), `binData`,
`BINARY`/`VARBINARY` y `BYTES` → `Binary`. El tipo físico queda en `physicalType`.

## 5. Dónde vale, la relación con `Opaque` y los errores

**Dónde vale.**
- Como tipo de columna de `Table`, `Dataset` y `View`, y de propiedad de entidad.
- Como campo de un `Struct<…>`: `Struct<nombre: String, firma: Binary>`. (Un campo `Opaque` sigue siendo `OOS3007`.)
- Como elemento de un `list<…>`: `list<Binary>`.

**Relación con `Opaque`.**

| de | a | |
|---|---|---|
| `Opaque` | `Binary` | **afina**: añade gobierno, y no es un estrechamiento. Una fuente ya catalogada con `Opaque` que se vuelve a descubrir **ofrece** `Binary`, no lo impone |
| `String` (base64) | `Binary` | **no ensancha**: cambia el tipo físico de la copia; es una vista nueva o una migración explícita (v1alpha1 02 §3.4) |
| `Binary` | `Opaque` | como siempre: retira el gobierno |
| `Binary` | `String` | **no ensancha** |

| | código | |
|---|---|---|
| `Binary` en un documento de v1alpha34 o antes | `OOS3001` | un tipo que no existía |
| `Binary` con argumentos (`Binary<16>`, `Binary()`) | `OOS3010` | un `Binary` mal formado: en esta versión es un escalar sin argumentos |
| una escritura no canónica (`binary`, `Binary ` con espacios) | — | se acepta si el nombre casa y se canoniza; el digest del paquete usa la canónica |

`OOS3010` es **un `Binary` mal formado**; `OOS3001` sigue siendo un tipo que no existe.
