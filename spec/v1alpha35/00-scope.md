# OOS v1alpha35 — alcance

**Estado:** borrador de alcance, **alpha**: sin garantías de compatibilidad. La gramática es **del
documento** que declara v1alpha35.

| | |
|---|---|
| `00-scope` | **este documento** — qué entra, qué no, y por qué |
| [`01-el-binario`](01-el-binario.md) | **`Binary`**: una secuencia de bytes; su valor, cómo viaja en texto, cómo se guarda y cómo se relaciona con `Opaque` |

Esta versión **añade un tipo**, `Binary`, y **un código**: `OOS3010`.

---

## 1. Lo medido

Medido el 2026-10-26 al mapear Oracle a OOS (ORE 0075) y contrastado con los demás orígenes de la plataforma:

- **Siete orígenes entregan bytes y todos acaban en `Opaque`.** `RAW`, `LONG RAW` y `BLOB` (Oracle), `bytea`
  (PostgreSQL), `blob` (Cassandra), `binData` (MongoDB), `BINARY`/`VARBINARY` (Phoenix), los bytes de HBase y
  `BYTES` (BigQuery). No es una decisión de ninguno: es lo que el documento permite.
- **`Opaque` mezcla dos cosas.** *«Son bytes y lo sé»* y *«no sé qué es»*. La primera se puede guardar, medir,
  comparar por igualdad y devolver intacta; la segunda, no.
- **Costes reales de no tenerlo.**
  - Un `bytes` que un cliente escribe desde un SDK llega a la copia como una columna de **texto** en base64, y
    lo que lee de vuelta no es lo que escribió.
  - BigQuery pierde su camino rápido (Storage Read, Arrow nativo) con una columna `BYTES`.
  - Un campo de un `Struct` **no puede** ser `Opaque` (`OOS3007`), así que un compuesto con bytes no se expresa.
- **El ecosistema ya lo tiene.** Arrow `Binary` y `FixedSizeBinary`, Parquet `BYTE_ARRAY`, Iceberg `binary` y
  `fixed(L)`, Spark `BINARY`, Foundry `BINARY`, DuckDB `BLOB`. Y la plataforma ya escribe `Binary` en el lago:
  una geometría (v1alpha32) es un `binary` con su extensión.

## 2. Lo que entra

1. **`Binary`**: un tipo sin argumentos (no se añade a los diez escalares de v1alpha1 §3.1: lo añade la versión); una secuencia de bytes de cualquier longitud, incluida la vacía
   ([`01`](01-el-binario.md) §1).
2. **Nulo y vacío son cosas distintas**; se compara **por igualdad** y por el orden de los bytes (§2).
3. **Cómo viaja en texto**: base64 (RFC 4648, alfabeto estándar, con relleno) (§3).
4. **La correspondencia** con Arrow, Parquet, Iceberg y DuckDB (§4).
5. **Dónde vale, y cómo se relaciona con `Opaque`** (§5), con el código `OOS3010`.
6. **La firma de una función**: `bytes` y `Uint8Array` derivan `Binary`, con la regla de la versión del documento (§6).

## 3. Lo que no entra (todavía)

- **Una longitud fija** (`Binary<16>`, un hash, un UUID de 16 bytes): es una restricción más, no un tipo
  aparte; se decidirá cuando algo la pida (Arrow e Iceberg la distinguen).
- **Un binario enorme por celda** (decenas de MB): pide otro tratamiento, por referencia, como `Media<c>`.
  `Binary` es para valores que caben en una fila; el límite exacto es de la implementación.
- **`Map<K, V>`, `Interval` y un semiestructurado** (`Variant`): son otras versiones. `Map` es un compuesto
  y se ve a la vez que sus correspondencias en el lago; `Interval` y `Variant` siguen en `Opaque`.
- **Funciones** sobre bytes (longitud, subcadena, hash): las da el motor que calcula.
- **Migrar las copias que ya guardan base64 como `String`**: cambiar `Opaque` o `String` por `Binary` en una
  columna ya publicada **no es un ensanche** (§5). Cómo se hace es de la implementación y de la ontología,
  no del tipo.

## 4. Lo que se acepta a cambio

- **Subir la versión del documento para declarar una columna `Binary`.** La puerta es del documento, como en
  v1alpha17 y v1alpha32.
- **El texto es base64 y la geometría es hexadecimal.** Dos formas de escribir bytes en texto, cada una por
  su razón: la geometría fijó el WKB en hex (v1alpha32 01 §5) por su tradición (PostGIS, GeoParquet) y
  `Binary` toma base64, que es lo que ya viaja de los orígenes y pesa un tercio más en vez del doble. Solo
  afecta al texto de tránsito: en Arrow, Parquet e Iceberg son los mismos bytes.
