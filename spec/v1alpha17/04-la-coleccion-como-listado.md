# 04 · La colección como listado

**Estado:** normativo. Parte de OOS v1alpha17.

v1alpha16 rechazaba una consulta que nombrara una colección en un `FROM` (`OOS2018`: *«una
colección no se lee con SQL»*). La regla protegía de lo que el estado del arte llama el error de
Spark `binaryFile`: meter los bytes en la fila. v1alpha17 abre la puerta **sin ese error**: en SQL,
una colección es **su listado**.

```sql
SELECT _item, path, content_type, size
FROM legal.contratos
WHERE content_type = 'application/pdf'
```

## 1. Las columnas del listado

| columna | tipo | qué |
|---|---|---|
| `_item` | `Media<c>` | la referencia ([01](01-los-tipos.md) §3) |
| `path` | `String` | la clave relativa |
| `version` | `String` | la versión fijada |
| `digest` | `String` | `sha256:<hex>` o nulo |
| `size` | `Integer` | |
| `content_type` | `String` | el efectivo |
| `content_type_detected` | `String` | el de los bytes, si difiere |
| `checksum` | `String` | |
| `modified` | `DateTimeTz` | |
| `transaction` | `String` | la transacción de la colección en que el ítem entró |

Los campos de `_item` repiten los de sus columnas a propósito: la referencia viaja entera a otra
tabla; las columnas sueltas son para filtrar.

## 2. Lo que el listado no es

- **No lleva bytes.** Ninguna columna del listado es el contenido, ni una URL firmada.
- **No se ordena ni se agrupa por `_item`**: una referencia no tiene orden (Snowflake prohíbe lo
  mismo sobre `FILE`). Se ordena por `path`, `modified` o `size`, y se une por `_item.digest`,
  `path` o `_anchor_id`.
- **Es de una transacción**: una lectura ve la colección en una transacción entera, la actual o la
  que pida (como un *snapshot* de una tabla). Lo decide el motor; la gramática fija que no hay
  lecturas a medias.

## 3. Una vista sobre el listado

Una `View` puede leer una colección como cualquier tabla. Su contrato declara `_item` como
`Media<c>` y hereda las etiquetas de la colección (`OOS4002` si las rebaja).

## 4. Las reglas

| | código | |
|---|---|---|
| una colección en un `FROM` en v1alpha16 | `OOS2018` | como siempre |
| una colección en un `FROM` en v1alpha17 | — | es su listado |
| `ORDER BY` o `GROUP BY` sobre `_item` | `OOS2041` | una referencia no tiene orden |
| una columna que el listado no tiene (`content`) | `OOS2018` | como la que un `ObjectTable` no tiene |
