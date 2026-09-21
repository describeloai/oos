# OOS v1alpha12 — alcance

**Estado:** borrador de alcance. Gobierna los documentos que declaran su `apiVersion`, y es
**alpha**: sin garantías de compatibilidad.

| | |
|---|---|
| `00-scope` | **este documento** — qué entra, qué no, y por qué lo que se tiene es un documento y no dos disfraces |
| [`01-dataset`](01-dataset.md) | el dataset: naturaleza, las dos formas bajo un kind, la forma, las reglas, lo que se deriva y lo que la gramática no decide |
| [`02-la-vista-y-la-entidad`](02-la-vista-y-la-entidad.md) | lo que cambia en `View` y `Entity` para que compongan sobre un dataset, y la clave que se retira |

Esta versión **añade un `kind`** —`Dataset`—, **abre dos referencias** —`View.from` y
`Entity.backedBy` admiten un dataset— y **retira una clave** —`View.materialized`—. No añade
códigos de error: lo que rechaza lo rechaza con los de siempre —`OOS1003` la versión, `OOS1004`
la forma, `OOS1005` una clave que no es de aquí, `OOS2018` una referencia del plan que no
resuelve, `OOS2019` una cadena que vuelve sobre sí, `OOS2009` un dueño que no lo es, y los del
flujo (`OOS4002`, `OOS4011`) y del mantenimiento (`OOS2021`, `OOS2023`, `OOS2024`) que ya
existían sobre la copia—.

---

## 1. La tesis

Cada versión gobierna un verbo, y aporta **una** regla:

| versión | verbo | la regla |
|---|---|---|
| v1alpha7 | **preguntar** | la vista es la pregunta y compone |
| v1alpha8 | **apuntar** | lo físico se registra una vez, con dos caras |
| v1alpha9 | **razonar** | un modelo que se usa es un documento del árbol, y nombra un perfil medido |
| v1alpha10 | **actuar** | lo que una función toca se lee en su documento, en los dos sentidos |
| v1alpha11 | **publicar** | lo que el código produce y no es una tabla entra en el árbol como un documento que nombra sus bytes |
| **v1alpha12** | **tener** | **lo que un inquilino tiene —bytes en su lago, con historia— es un documento de su paquete, y uno solo, se llene como se llene** |

Lo que esta versión afirma: hasta aquí, lo que un inquilino **tiene** se nombraba con dos
disfraces. La copia de una tabla era una `View` con `materialized` —la pregunta, con una nota
al pie que decía «y además se guarda»—; lo que el código escribía era una `Table` con
`datasource: lago` —el puntero a algo de fuera, apuntando a algo nuestro—. Las dos cosas son la
misma: **una tabla en el lago, con snapshots, con dueño, de la que salen preguntas**. Foundry la
llama *dataset* y hace de ella el asset primario; Unity Catalog registra la *materialized view*
y la *streaming table* como dos tablas gestionadas que se distinguen por cómo se llenan, no por
qué son. Aquí, desde esta versión, es **`kind: Dataset`**.

## 2. Por qué un kind, y no la vista con `materialized`

Porque la clave `materialized` hacía que la vista dijera dos cosas —qué se pregunta y qué se
tiene— y **el registro del inquilino tiene que poder listar lo segundo sin listar lo primero**.
Una base de treinta tablas copiadas enseñaba treinta tablas y treinta vistas que eran la misma
cosa; y lo que un `write()` producía se llamaba como lo que no era.

Lo que había que responder antes de moverlo es **la costura**: la copia era una `View` porque
una `View` lleva un plan —`from`, `fields`, `where`— y sobre el plan decide el conducto
(`materialization.payload`, `OOS4002`) y se apoya el refresco (el testigo, la clave, el rango).
Una `Table` pelada no tiene plan y no hay nada que negar sobre ella. **La respuesta es que la
costura cuelga del plan, no del nombre del documento**: un `Dataset` que lleve `from`, `fields`
y `where` tiene exactamente la misma superficie, y el conducto, el motor de refresco y la
herencia de etiquetas se mueven con él sin cambiar una regla. [`01-dataset` §5](01-dataset.md).

Y no es la `Table` con `datasource: lago` por lo contrario: la `Table` es el puntero a **lo que
es de otro**, registrado una vez, con sus dos caras declaradas porque nadie de aquí las
controla. Lo que es nuestro no se apunta: se tiene. Un `Dataset` que llevara `datasource` +
`object` + `columns` físicas sería `Binding` otra vez.

## 3. Dos formas bajo un kind, y por qué no son dos kinds

Un dataset se llena de una de dos maneras, y el documento lo dice por **una clave**:

| | **mantenido** (`from`) | **escrito** (`columns`) |
|---|---|---|
| quién lo llena | **el sistema**, cumpliendo el plan del documento | **código**: un `write()`, un transform, un trabajo |
| qué dice el documento | de qué sale y cómo se recorta (`from`, `fields`, `where`, `groupBy`, `having`), cada cuánto (`freshness`) | qué columnas tiene (`columns`) y qué escrituras admite (`changes`) |
| dónde está el linaje | **en el documento**: `from` | **en el puntero**: la procedencia de cada snapshot (inputs, transform, código@commit) |
| fuera | *materialized view* (Databricks), *dynamic table* (Snowflake), modelo `table`/`incremental` (dbt) | el dataset de un *transform* (Foundry), el asset de una función (Dagster), la tabla que un *job* escribe |

Son **la misma cosa** —bytes con historia, en el lago, con dueño, de la que se pregunta— con
dos procedencias, y por eso un kind: lo que el catálogo lista, lo que la gobernanza gobierna, lo
que una vista lee y lo que una entidad respalda no distingue cómo se llenó. Lo que sí distingue
es qué escribe cada uno: el sistema **cumple** un plan; el código **registra** lo que dejó. Si
al medirlas resultara que cada forma pide sus reglas propias en más de un sitio, se abren en dos
y se dice (**P7**); hoy piden una regla propia cada una —el conducto sobre el plan; `changes`
como lo que se admite— y comparten todo lo demás.

## 4. Qué entra

- `kind: Dataset` — [`01-dataset`](01-dataset.md).
- `View.from: { dataset }` y `Entity.backedBy` sobre un dataset — [`02-la-vista-y-la-entidad`](02-la-vista-y-la-entidad.md).
- **Se retira `View.materialized`.** Una `View` es la pregunta; si alguien quiere sus filas
  guardadas, escribe un `Dataset` con `from: { view }`. §6.

## 5. Qué no entra, y por qué

- **El puntero.** Qué snapshot es el vigente, dónde está el `metadata_location`, cuántas filas,
  quién escribió, con qué procedencia: es el **estado**, lo escribe quien escribe los bytes, y
  cambia con cada escritura. Dos sitios que dicen lo mismo son dos sitios que discrepan.
- **Un dataset de ficheros.** Un `Dataset` es tabular —una tabla Iceberg, con columnas— porque
  el gobierno de esta gramática cuelga de las columnas. Lo que son ficheros con digest ya tiene
  documento (`TrainedModel`, v1alpha11); si un día hace falta «ficheros a secas», se abre
  entonces, y no estirando éste.
- **`columns` como contrato exigible.** En el escrito, `columns` **sigue** a la tabla: nace con
  la primera escritura y cambia con ella. Un contrato que rechace una escritura que no cuadre
  (los *contracts* de dbt, el *schema* de ODCS) es otra decisión y otra clave, y se toma cuando
  se mida cuántas escrituras rompen el esquema.
- **Calidad.** Las reglas sobre un dataset son un `Ruleset` que lo nombra (v1alpha3/4), como los
  *asset checks* de Dagster viven al lado del asset. No hay `quality` aquí.
- **`labels`.** Ni en `metadata` ni en las columnas: la clasificación de un dato la declara la
  `Entity` que lo respalda y baja por el plan, como hasta hoy. Un dataset que se etiquetara a sí
  mismo sería el segundo sitio que dice qué es una columna.
- **Leer a un snapshot.** Que una vista o una función lean un dataset «tal como estaba en» es
  del verbo que lee, no de la forma del documento.
- **Varias fuentes.** `from` es una, como en la vista: el vocabulario no tiene junta.

## 6. Compatibilidad y migración

Ningún documento de v1alpha1 a v1alpha11 cambia de resultado. `kind: Dataset` en una versión
anterior es `OOS1003`.

**`View.materialized` se retira como se retiró `Binding`** (v1alpha8 §5.4): una `View` de
v1alpha12 que la declare es `OOS1005` —una clave que no es de aquí— con el remedio en el
mensaje: *«esto es un `Dataset` con `from: { view: <ésta> }`»*. En v1alpha8–v1alpha11 sigue
compilando, y sigue significando lo mismo.

La migración es mecánica y **conserva el plan**:

| antes | después |
|---|---|
| `View v` con `from`, `fields`, `where`, `freshness` y `materialized: { datasource, table }` | la misma `View v` **sin** `materialized` (sigue siendo la pregunta) **más** `Dataset v` con `from: { view: v }` y su `freshness`. O, si nadie pregunta por `v` sin copiarla, **sólo** el `Dataset` con el plan de `v` dentro |
| `Table t` con `datasource: lago`, `object`, `columns`, `reads`, `changes` | `Dataset t` con `columns` y `changes: { mode, key? }`; `datasource`, `object` y `reads` se van (son del lago, y se derivan) |
| `View x` con `from: { view: v }` donde `v` era la copia | igual, o `from: { dataset: v }` si `v` pasó a ser sólo dataset |
| `Entity e` con `backedBy: v` donde `v` era la copia | igual: `backedBy` resuelve a la `View` o al `Dataset` que quede con ese nombre |

`materialized.datasource` y `materialized.table` no sobreviven: el lago es **el** sitio de un
dataset (ya lo era: `datasource: lago` en toda copia), y el nombre físico lo pone quien escribe
(`<ns>_<n>`). Un documento que las llevara a otro sitio no existe en ningún árbol conocido, y
la migración lo diría.
