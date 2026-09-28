# OOS v1alpha16 — alcance

**Estado:** borrador de alcance. Gobierna los documentos que declaran su `apiVersion`, y es
**alpha**: sin garantías de compatibilidad.

| | |
|---|---|
| `00-scope` | **este documento** — qué entra, qué no, y por qué los ficheros son dos cosas y no una |
| [`01-object-table`](01-object-table.md) | el `ObjectTable`: el puntero a un conjunto de objetos de un origen |
| [`02-media-collection`](02-media-collection.md) | la `MediaCollection`: una colección gobernada de ficheros de un solo tipo de medio |
| [`03-lo-tabular-y-la-referencia`](03-lo-tabular-y-la-referencia.md) | lo que cambia en `Table` para leer ficheros tabulares, y el tipo `Media<…>` que apunta a un ítem |

Esta versión **añade dos `kind`** —`ObjectTable` y `MediaCollection`—, **abre una clave** en
`Table` —`format`, para los ficheros que son filas— y **añade un tipo** —`Media<colección>`, la
referencia a un ítem—. Añade un código de error, `OOS2040`; lo demás lo rechaza con los de
siempre.

---

## 1. La tesis

| versión | verbo | la regla |
|---|---|---|
| v1alpha8 | **apuntar** | lo físico se registra una vez, con dos caras |
| v1alpha11 | **publicar** | lo que el código produce y no es una tabla entra en el árbol como un documento que nombra sus bytes |
| v1alpha12 | **tener** | lo que un inquilino tiene —bytes en su lago, con historia— es un documento de su paquete |
| **v1alpha16** | **guardar** | **un fichero es un objeto, no una fila: se apunta como objeto, se tiene en una colección de su tipo, y una entidad lo referencia sin copiarlo** |

Hasta aquí OOS cerraba la puerta a propósito: un binario era `Opaque` —*«retira el
gobierno»*—, `Blob` era `OOS3001`, y *«un dataset de ficheros… se abre entonces, y no estirando
éste»* (v1alpha12 `00-scope`). Esta versión la abre, y **no estira `Dataset`**: un dataset sigue
siendo una tabla.

## 2. Por qué los ficheros son dos cosas, y ninguna es un dataset

Un origen de objetos —S3, GCS, Azure Blob, un SFTP, SharePoint— guarda ficheros. Medido contra
un bucket real (ORE 0046 F1), en el mismo prefijo conviven CSV del mismo negocio con esquemas
distintos, Parquet con particiones Hive, PDF con texto y escaneados, fotos, y un zip con todo lo
anterior dentro. Lo que se hace con cada cosa no se parece:

| el fichero es… | lo que se quiere | cómo lo nombra el mercado | aquí |
|---|---|---|---|
| **filas** (Parquet, CSV, JSONL) | preguntarle, copiarlo, respaldar una entidad | *external table* (Snowflake, Databricks), *BigLake table* (BigQuery), esquema aplicado a un dataset (Foundry) | **una `Table`** con `format` ([03](03-lo-tabular-y-la-referencia.md)) |
| **un medio** (documento, imagen, audio, vídeo) | listarlo, verlo, referenciarlo desde un objeto, extraer su texto | *directory table* (Snowflake), *object table* (BigQuery), *volume* (Databricks), *media set* (Foundry) | **un `ObjectTable`** en la fuente y **una `MediaCollection`** que lo tiene |

Todos los fabricantes separan las dos. Ninguno registra las filas de un Parquet y los píxeles de
una foto con el mismo documento.

## 3. Las tres piezas, en una frase cada una

- **`ObjectTable` · apuntar a objetos.** El conjunto de objetos de un origen —un prefijo, un
  patrón, un tipo de medio—, registrado **una vez**, en el paquete de la fuente (ORE 0045). Es
  **el catálogo** de esos objetos: cada fila es un objeto, con su clave, su tamaño, su tipo por
  los bytes, su huella de contenido y su fecha. No copia nada.
- **`MediaCollection` · tener objetos.** Lo que un inquilino tiene como colección gobernada de
  ficheros de **un solo tipo de medio**: cada ítem direccionable por su huella, con retención y
  con historia transaccional. **Mantenida** desde un `ObjectTable` —copiada al lago, o **virtual**,
  servida desde el origen— o **escrita** por código.
- **`Media<colección>` · referenciar.** Un tipo de propiedad: el valor es un ítem de una
  colección. Un `Contrato` tiene su PDF y un `Empleado` su foto sin copiar el fichero en la fila.

Y `Table` gana **`format`**: una `Table` cuyo `object` son ficheros tabulares dice cómo se leen.
Sobre ella, todo lo de siempre —la `View`, el `Dataset`, la copia, la entidad— sin cambiar una
regla.

## 4. La colección está tipada desde el primer día

Foundry es el único que lo hace, y es por lo que hace de la colección algo más que un saco de
ficheros: **el tipo de medio** (`document`, `image`, `audio`, `video`, `spreadsheet`, `email`) es
lo que permite ofrecer lo que sólo el tipo sabe hacer —una vista previa, extraer el texto de un
documento, transcribir un audio— y lo que hace que una referencia `Media<…>` diga qué hay al otro
lado. Una colección de un tipo no admite ítems de otro; lo mixto se separa por tipo al
catalogar, o se queda en su `ObjectTable` (que admite `binary`: «todavía no sé qué es»).

## 5. Qué entra, qué no

**Entra**:

- los dos kinds y su forma;
- `Table.format`;
- el tipo `Media<…>`;
- `OOS2040` (una colección cuyo origen no es de su tipo).

**No entra, y no por olvido:**

- **Borrados y cambios en el origen.** El testigo de un `ObjectTable` es su **listado**
  ([01](01-object-table.md) §5), y lo único que esta versión fija es que tiene que poder decir qué
  desapareció. Si un borrado se propaga a una colección mantenida, y cómo, lo decide la medida de
  ORE 0046, no esta gramática.
- **Si una base estándar copia la colección o la sirve en sitio.** Las dos formas existen
  (`virtual`); cuál elige una base es de la implementación, y se mide.
- **Procesar.** Extraer texto, hacer OCR, transcribir, trocear para *embeddings*: son funciones y
  transformaciones que **leen** una colección y **escriben** un `Dataset`. La gramática ya las
  admite (`reads`, `derivedFrom`); lo que añade esta versión es que tengan algo tipado que leer.
- **El formato de los ficheros.** Como en v1alpha7 (*«Iceberg y Parquet ya existen»*), no es
  cosa de OOS cómo se codifica un PNG. Lo es **qué tipo de medio** es, porque eso decide qué se
  puede hacer con él.
- **Subir ficheros a mano.** Una colección escrita la escribe código; qué interfaz sube bytes es
  de la implementación.
- **Leer ficheros desde una vista por función** (`read_parquet('s3://…')`): sigue siendo
  `OOS2038`. Se lee por lo que está registrado.

## 6. Lo que no cambia

Ningún resultado de v1alpha1 a v1alpha15 cambia. `Opaque` sigue existiendo para lo que no se
modela; `Media<…>` es para lo que sí. Un `Dataset` sigue siendo tabular (v1alpha12 `00-scope`).
`TrainedModel` sigue nombrando sus ficheros por prefijo y digest: es la primera colección de
ficheros que OOS tuvo, y la `MediaCollection` es su generalización a lo que no son pesos.
