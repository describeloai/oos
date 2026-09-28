# 01 · ObjectTable — el puntero a un conjunto de objetos

**Estado:** borrador. Parte de OOS v1alpha16.
**Anfitrión:** ninguno. Es gramática propia, gemela de la `Table` de v1alpha8.

---

## 1. Naturaleza

> **Un `ObjectTable` es el conjunto de objetos de un origen —un prefijo, un patrón y un tipo de
> medio—, registrado una vez, cuyas filas son los objetos.**

Es a los ficheros lo que la `Table` es a las filas: **lo que es de otro, apuntado**. Vive en el
paquete de la fuente, una vez por conjunto (ORE 0045: el puntero es de la fuente), y lo nombran
quienes lo usan. No copia nada: dice qué hay.

Sus filas son los objetos, con columnas **fijas**, las mismas en todo `ObjectTable`:

| columna | tipo | qué es |
|---|---|---|
| `key` | `String` | la clave del objeto en el origen, tal cual (espacios, mayúsculas) |
| `size` | `Integer` | bytes |
| `contentType` | `String` | el tipo **por los bytes** (`application/pdf`, `image/jpeg`…); el que declare el origen es una pista (§4) |
| `checksum` | `String` | la huella del contenido **entero** (§4) |
| `modified` | `DateTimeTz` | la última modificación que da el origen |
| `version` | `String` | la versión del objeto, si el origen versiona; ausente si no |

Y una columna `String` por cada **partición** declarada (`fecha=2026-09-01` → `fecha`).

Es lo que Snowflake llama *directory table*, BigQuery *object table* y S3 *Metadata inventory*:
un fichero se pregunta como una fila de metadatos.

## 2. Qué **no** es

- **No es una `Table`.** Una `Table` apunta a filas del origen, y las filas de un Parquet o un
  CSV se apuntan con una `Table` que lleva `format` ([03](03-lo-tabular-y-la-referencia.md)). Un
  `ObjectTable` apunta a **objetos**; sus filas son los ficheros, no lo que hay dentro.
- **No es una colección.** No tiene ítems propios, ni retención, ni historia: dice qué hay en el
  origen ahora. Lo que se tiene es la `MediaCollection` ([02](02-media-collection.md)).
- **No lleva `labels`.** Como la `Table`: es un hecho del origen. Su clasificación la da el
  `datasource` y la hereda quien la lee.

## 3. La forma

```yaml
apiVersion: oos.dev/v1alpha16
kind: ObjectTable
metadata:
  name: contratos
  namespace: s3_ventas          # el paquete de la fuente
  schema: nueva_carpeta
spec:
  datasource: s3_ventas
  prefix: "Nueva carpeta/contratos/"
  match: "*.pdf"                # opcional: patrón de claves bajo el prefijo
  media: document               # el tipo de medio de sus objetos
  partitions: []                # opcional: claves `k=v` del camino que son columnas
  reads:
    fullScan: cheap             # listar el prefijo entero
  changes:
    mode: retract               # lo que el listado puede decir (§5)
    witness: listing
```

| clave | | |
|---|---|---|
| `datasource` | **obligatoria** | la fuente, declarada en el manifiesto (`OOS2004` si no) |
| `prefix` | **obligatoria** | el prefijo de claves en el origen, tal cual; `""` es el origen entero |
| `match` | opcional | un patrón *glob* sobre la clave relativa al prefijo (`*`, `**`, `?`). Sin él, todo lo que haya bajo el prefijo |
| `media` | **obligatoria** | `document`, `image`, `audio`, `video`, `spreadsheet`, `email`, `archive` o `binary` (§4) |
| `partitions` | opcional | nombres de las claves `k=v` del camino que se exponen como columnas |
| `reads` | opcional | la cara `I` de v1alpha8, sobre el listado: `fullScan` (`cheap`/`expensive`/`forbidden`) |
| `changes` | **obligatoria** | la cara `D` sobre el listado: `mode` y `witness` (§5) |

**Dónde vive.** En un schema del paquete de la fuente, una vez (ORE 0045), y su nombre
cualificado es `<paquete>.<schema>.<nombre>` (v1alpha13). **Comparte el espacio de nombres del
schema** con la `Table`, la `View`, el `Dataset` y la `MediaCollection`: una consulta nombra por
nombre y no dice qué `kind` lee (v1alpha14 `01` §3), así que dos con el mismo nombre son
`OOS2035`. La carpeta `objects/` es la costumbre; como toda carpeta bajo un schema, ordena y no
nombra.

## 4. El tipo de medio, y la huella

**`media` es un vocabulario cerrado**, y por lo mismo que `changes.mode`: lo que se puede hacer
con un objeto depende de qué es, y quien lo lea tiene que poder razonar sobre ello.

| `media` | qué es | ejemplos |
|---|---|---|
| `document` | texto paginado | PDF, DOCX, PPTX |
| `image` | una imagen | PNG, JPEG, TIFF, WebP, DICOM |
| `audio` | sonido | WAV, MP3, FLAC |
| `video` | vídeo | MP4, MOV |
| `spreadsheet` | una hoja con celdas, no filas declaradas | XLSX, ODS |
| `email` | un mensaje con adjuntos | EML, MSG |
| `archive` | un contenedor de otros ficheros | ZIP, TAR |
| `binary` | todavía no se sabe | lo que el catálogo no reconoce |

Tres cosas que salen de medir un bucket real (ORE 0046 F1) y que la gramática fija:

1. **El tipo es el de los bytes, no el que declara el origen.** La consola de AWS subió Parquet y
   JSONL como `application/x-www-form-urlencoded`. La columna `contentType` es la que dicen los
   primeros bytes del objeto; la del origen no cuenta.
2. **La huella es del contenido entero**, no la etiqueta de transporte del origen. El ETag de S3
   de un fichero subido por partes (`"…-4"`) depende de cómo se partió; el `CRC64NVME` de objeto
   completo, no. `checksum` es una huella del contenido que dos copias iguales comparten.
3. **`archive` no se abre al catalogar.** Su índice se puede leer barato, pero expandirlo es una
   transformación que escribe otro conjunto de objetos.

## 5. La cara `D`: el testigo es el listado

`changes.mode` es el de v1alpha8: `append`, `retract`, `none` (`upsert` no, porque un listado no
tiene más clave que la del objeto, y cambiar un objeto es retirar su huella vieja y dar la nueva:
`retract`).

`changes.witness` gana **un valor**, sólo en `ObjectTable`: **`listing`**. El estado de un
`ObjectTable` es su listado —el conjunto de pares (`key`, `checksum`)— y lo que cambió entre dos
lecturas es **la diferencia de dos conjuntos**, no un ordinal que avanza. Con él, un `retract` es
legal: una clave que estaba y ya no está es un `-1`.

| `witness` | legal en `ObjectTable` | |
|---|---|---|
| `listing` | sí | la diferencia de dos listados. Altas, cambios (otra huella) y **bajas** |
| `snapshot` | sí | el origen versiona (versiones de objeto, un inventario con fecha): un ordinal nativo |
| `log` | sí | el origen emite eventos (notificaciones, un diario de cambios) |
| `none` | sí | no se sabe qué cambió: cada lectura es el listado entero |
| `field` | **no** | un listado no tiene columna propia que ordene el avance |

Lo que esta gramática **no** decide es qué hace con una baja quien lee el `ObjectTable` (una
colección mantenida la retira, la conserva o la marca); lo decide la iteración de borrados de ORE
0046, y lo que salga se escribirá en la colección, no aquí.

## 6. Las reglas

| | código | |
|---|---|---|
| sin `datasource`, `prefix`, `media` o `changes` | `OOS1004` | la forma mínima |
| `media` fuera del vocabulario | `OOS1004` | es cerrado |
| `changes.witness: field` | `OOS1004` | un listado no tiene columna que ordene |
| `changes.mode: upsert` | `OOS1004` | un objeto no tiene más clave que su nombre |
| `labels` en `metadata`, o una clave que no es de aquí (`columns`, `object`, `format`) | `OOS1005` | lo tabular es una `Table` |
| el `datasource` no está declarado | `OOS2004` | como en `Table` |
| un nombre que ya tiene otro documento del schema (`Table`, `View`, `Dataset`, `MediaCollection`) | `OOS2035` | un nombre, una cosa |
| una consulta que nombra una columna que no es de las fijas (§1) ni una partición | `OOS2018` | sus columnas no se declaran: son éstas |
| `kind: ObjectTable` en v1alpha15 o antes | `OOS1003` | es un documento de v1alpha16 |

## 7. Quién lo lee

- una **`MediaCollection`** mantenida: `from: { objectTable: <ref> }`
  ([02](02-media-collection.md));
- una **`View`** de una base foránea: `SELECT key, size, checksum FROM <fuente>.<schema>.<ot>`,
  como lee una `Table`: lo que una consulta lee (v1alpha14 `01` §3) resuelve ahora también a un
  `ObjectTable`. Sus columnas son las fijas del §1 y las particiones, y ninguna más (`OOS2018`);
- una **función** que procesa objetos (`reads`).

Nadie lo lee por su bucket: se lee por el documento.
