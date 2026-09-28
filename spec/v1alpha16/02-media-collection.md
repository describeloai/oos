# 02 · MediaCollection — la colección de ficheros de un tipo

**Estado:** borrador. Parte de OOS v1alpha16.
**Anfitrión:** ninguno. Es gramática propia, hermana del `Dataset` de v1alpha12.

---

## 1. Naturaleza

> **Una `MediaCollection` es lo que un inquilino tiene como colección gobernada de ficheros de
> un solo tipo de medio: cada ítem direccionable por su huella, con retención y con historia.**

Es a los ficheros lo que el `Dataset` es a las tablas: **lo que se tiene**, un documento de un
paquete, con dueño, que se lista, se gobierna, tiene linaje y del que otros leen. Donde el
`Dataset` tiene filas, la colección tiene **ítems**: un fichero, su huella, su tipo y su camino.

Es el *media set* de Foundry y el *volume* de Unity Catalog, con la diferencia que Foundry hace
y los demás no: **el tipo de medio es del documento**, y por eso la colección sabe qué se puede
hacer con lo que guarda.

## 2. Qué **no** es

- **No es un `Dataset`.** Un dataset es tabular (v1alpha12); una colección, ficheros. Su índice
  —un ítem por fila— se puede preguntar, pero eso es una vista sobre la colección, no la
  colección.
- **No es un `ObjectTable`.** El `ObjectTable` dice qué hay en un origen ajeno; la colección es
  lo nuestro, con retención e historia, aunque sus bytes sigan en el origen (`virtual`, §3).
- **No es un `TrainedModel`.** Aquél nombra los ficheros de un modelo por un digest de manifiesto
  y una versión; ésta, ítems sueltos de un tipo, que cambian uno a uno. El `TrainedModel` es el
  caso particular que OOS ya tenía.

## 3. Dos formas bajo un kind, como el dataset

| | **mantenida** (`from`) | **escrita** (sin `from`) |
|---|---|---|
| quién la llena | **el sistema**, desde un `ObjectTable` | **código**: una función, una transformación, una sesión |
| qué dice el documento | de qué `ObjectTable` sale, qué ítems toma (`match`) y si los bytes se copian o se sirven en sitio (`virtual`) | nada del origen: el linaje de cada escritura va en su puntero, como en el dataset escrito |
| fuera | *media set sync* y *virtual media set* (Foundry), *external volume* (Databricks), *external stage* (Snowflake) | lo que un *transform* escribe en un *media set* (Foundry), un *managed volume* (Databricks) |

**`virtual: true`** es la mantenida que **no copia**: sus ítems son los objetos del origen,
servidos desde allí tras comprobar la política. Sin ella —el valor por defecto— los bytes se
copian al lago y la colección vive aunque el origen cambie. Cuál conviene a una base es de la
implementación, y se mide (ORE 0046).

## 4. La forma

```yaml
apiVersion: oos.dev/v1alpha16
kind: MediaCollection
metadata:
  name: contratos
  namespace: legal
  schema: default
  labels: { confidencialidad: interno }   # opcional (§6)
spec:
  owner: team:legal
  media: document                          # uno, y el mismo que el de su origen
  formats: [pdf]                           # los formatos que admite; el primero es el primario
  from:                                    # mantenida; sin `from`, escrita
    objectTable: s3_ventas.nueva_carpeta.contratos
    match: "contrato-*.pdf"                # opcional: qué ítems del origen entran
  virtual: false                           # opcional: `true` sirve desde el origen, sin copiar
  retention: 365d                          # opcional: cuánto vive un ítem retirado
```

| clave | | |
|---|---|---|
| `owner` | **obligatoria** | `team:`/`user:` (`OOS2009` si no) |
| `media` | **obligatoria** | el vocabulario de `ObjectTable` §4, **sin** `binary` ni `archive`: una colección sabe lo que guarda |
| `formats` | **obligatoria** | formatos de ese medio, no vacía, sin repetidos; el primero es el **primario**. Un ítem de otro formato no entra |
| `from.objectTable` | con `from` | el `ObjectTable` del que sale. Tiene que resolver (`OOS2018`) y ser del mismo `media` (`OOS2040`) |
| `from.match` | opcional | un patrón *glob* sobre la clave, además del del `ObjectTable` |
| `virtual` | opcional | sólo con `from`. `true`: no copia |
| `retention` | opcional | una duración (`30d`, `12h`): cuánto se guarda un ítem que ya no está en la vista actual. Sin ella, no caduca |

## 5. El ítem, y la historia

Un ítem es **un fichero con una identidad**: su **huella** de contenido (la `checksum` del
`ObjectTable`, o la que calcule quien escribe), su camino (`path`, la clave relativa) y su
formato. Dos ítems con la misma huella son el mismo contenido.

La colección cambia **por transacciones**, como un dataset por *snapshots*: una ingesta, una
escritura o una retirada entra entera o no entra. La vista actual es la de la última
transacción; lo anterior vive mientras `retention` lo diga. **Qué transacción es la actual, y qué
ítems tiene, es del puntero** —como el de un dataset—, no del documento: un árbol se lee sin el
bucket.

## 6. Gobierno

- **Nadie accede al almacén.** Un ítem se sirve con una URL firmada y temporal, emitida tras
  comprobar la política; en una colección `virtual`, la firma es del origen, con la credencial de
  la fuente, y la comprobación es la misma.
- **Las etiquetas se heredan y se suman.** La colección hereda la clasificación de su origen (el
  `datasource`, por su `ObjectTable`) y puede **añadir** las suyas en `metadata.labels`: una foto
  de un DNI es `pii` aunque el bucket no lo sea. **No puede quitar** lo heredado: rebajar una
  clasificación es `OOS4002`, como en cualquier flujo.
- **Lo que deriva de ella la lleva.** Un `Dataset` escrito por una función que lee la colección
  (el texto de los contratos) hereda sus etiquetas por `derivedFrom`, como hoy desde una tabla.

Es la diferencia con el `Dataset`, que no admite `labels` porque su clasificación la declara la
entidad que respalda: los ficheros no tienen entidad debajo, y alguien tiene que poder decir que
una foto es un dato personal.

## 7. Las reglas

| | código | |
|---|---|---|
| sin `owner`, `media` o `formats` | `OOS1004` | la forma mínima |
| `media: binary` o `archive` | `OOS1004` | una colección sabe lo que guarda |
| `formats` vacía o con repetidos | `OOS1004` | |
| `virtual` sin `from` | `OOS1004` | sólo se sirve en sitio lo que tiene sitio |
| `retention` que no es una duración | `OOS1004` | |
| `from.objectTable` que no resuelve a un `ObjectTable` | `OOS2018` | |
| **`from.objectTable` de otro `media`** | **`OOS2040`** | una colección de documentos no sale de un conjunto de imágenes |
| una etiqueta que rebaja lo heredado | `OOS4002` | el flujo de siempre |
| `owner` que no es `team:` ni `user:` | `OOS2009` | |
| una clave que no es de aquí (`columns`, `fields`, `sql`) | `OOS1005` | una colección no es una tabla |
| `kind: MediaCollection` en v1alpha15 o antes | `OOS1003` | es un documento de v1alpha16 |

## 8. Lo que la gramática no decide

- **Qué pasa con un ítem que desaparece del origen** en una colección mantenida: se retira, se
  conserva o se marca. Lo decide la iteración de borrados de ORE 0046.
- **Que los bytes estén y la huella sea la suya.** Como en `TrainedModel`: lo coteja quien
  escribe, y un árbol se lee sin el bucket.
- **Cómo se ve un ítem.** La vista previa de un PDF o una imagen es de quien lo sirve. El tipo de
  medio es lo que le deja saber cómo.
