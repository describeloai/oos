# 03 · Lo tabular, y la referencia a un ítem

**Estado:** borrador. Parte de OOS v1alpha16.

Dos cambios en lo que ya existe: la `Table` de v1alpha8 aprende a leer ficheros que son filas, y
el sistema de tipos gana `Media<…>`.

---

## 1. `Table.format`: un fichero que es filas es una tabla

Un Parquet, un CSV o un JSONL no son medios: son **filas**. Se apuntan con una `Table`, como
cualquier otra fila de un origen, y todo lo que ya compone sobre una tabla —una `View`, un
`Dataset` mantenido, la copia, una entidad— compone sobre ésta sin cambiar una regla.

Lo único que la tabla necesita saber es **cómo se leen**, y lo dice `format`:

```yaml
apiVersion: oos.dev/v1alpha16
kind: Table
metadata: { name: pedidos, namespace: s3_ventas, schema: ventas }
spec:
  datasource: s3_ventas
  object: "Nueva carpeta/ventas/pedidos/"   # un prefijo, o la clave de un fichero
  format:
    type: parquet                            # parquet | csv | jsonl
    match: "**/*.parquet"                    # opcional, como en ObjectTable
    partitions: [fecha]                      # opcional: `fecha=…` del camino, columna
  columns:
    id: { type: String, physicalType: string }
    total: { type: "Decimal<12, 2>", physicalType: "decimal128(12, 2)" }
    ts: { type: DateTimeTz, physicalType: "timestamp[us, tz=UTC]" }
    fecha: { type: String }
  reads: { fullScan: expensive, predicatePushdown: [eq] }
  changes: { mode: append, witness: listing }
```

| clave de `format` | | |
|---|---|---|
| `type` | **obligatoria** | `parquet`, `csv` o `jsonl` |
| `match` | opcional | patrón *glob*, como en `ObjectTable` |
| `partitions` | opcional | claves `k=v` del camino que son columnas; tienen que estar en `columns` |
| `header`, `delimiter`, `encoding` | sólo `csv` | si la primera fila es cabecera (por defecto sí), el separador (`,`), la codificación (`utf-8`; un BOM se ignora) |

**Un prefijo es una tabla si sus ficheros comparten formato y esquema**; si no, cada fichero es
la suya y su `object` es su clave. Lo mide quien cataloga, no la gramática. Y las columnas de una
tabla sobre ficheros **se deducen** —de un pie de Parquet, de una muestra de CSV—, así que el
tipo deducido es una propuesta que alguien confirma: medido, un código postal con ceros a la
izquierda sale `Integer` de una muestra, y como entero pierde los ceros.

En una `Table` con `format`, `changes.witness: listing` es legal por lo mismo que en un
`ObjectTable`: lo que cambió son los ficheros.

| | código | |
|---|---|---|
| `format` en una `Table` de v1alpha15 o antes | `OOS1005` | |
| `format.type` fuera de `parquet`/`csv`/`jsonl` | `OOS1004` | un PDF no es filas: es un `ObjectTable` |
| una partición que no está en `columns` | `OOS1004` | |
| `header`/`delimiter`/`encoding` sin `type: csv` | `OOS1005` | |
| `changes.witness: listing` en una `Table` sin `format` | `OOS1004` | una tabla de filas no tiene listado |

## 2. `Media<colección>`: el tipo de una referencia a un ítem

```yaml
kind: Entity
metadata: { name: Contrato, namespace: legal }
spec:
  properties:
    id: { type: String }
    documento: { type: "Media<legal.contratos>" }
```

El valor de una propiedad `Media<c>` es **un ítem de la colección `c`** —su huella, que lo
identifica—. No es el fichero: es a dónde apuntar. Es la *media reference* de Foundry, el
`ObjectRef` de BigQuery y el tipo `FILE` de Snowflake.

- **Resuelve a una `MediaCollection`**: `Media<x>` con `x` que no lo es, `OOS2018`.
- **Lleva el tipo de medio de la colección**: quien consuma la propiedad sabe si es un
  documento o una imagen sin mirarlo.
- **Hereda la clasificación de la colección**: la propiedad lleva, como mínimo, las etiquetas de
  su colección. Proyectarla hacia algo menos clasificado es `OOS4002`.
- **Sustituye a `Opaque` para ficheros.** `Opaque` sigue siendo «no lo modelamos»; `Media<…>` es
  «lo modelamos, y está en una colección».

En la vista que respalda la entidad, la columna es `String` —la huella del ítem—, y el contrato
la declara `Media<…>`.

| | código | |
|---|---|---|
| `Media<…>` en v1alpha15 o antes | `OOS3001` | un tipo que no existía |
| `Media<x>` con `x` que no resuelve a una colección | `OOS2018` | |
| `Media` sin colección, o con dos | `OOS3001` | |
