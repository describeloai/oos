# 01 · Table — la tabla

**Estado:** borrador. Parte de OOS v1alpha8.
**Anfitrión:** ninguno. Es gramática propia. El vocabulario de tipos físicos es el de ODCS,
absorbido; el de codificaciones del cambio es cerrado y se justifica en §4.

---

## 1. Naturaleza

> **Una tabla es el puntero a un objeto físico, registrado una vez, con sus dos caras
> declaradas: qué se le puede pedir —`reads`— y qué cambios produce —`changes`. No contiene
> datos, no lleva significado y no decide quién ve.**

El puntero **no ejecuta: traduce.** Databricks lo dice con precisión para su *foreign table*:
por cada una que se referencia, se programa una subconsulta en el sistema remoto y se devuelve
el resultado por un solo flujo. Lo mismo hacen la *virtual table* de Foundry, el *shortcut* de
Fabric y la *external table* de BigQuery y Snowflake.

La tabla es un **hecho** del origen: el objeto existe, tiene estas columnas, admite estos
filtros, emite estos cambios. Ninguna de las cuatro cosas es una conjetura, y por eso el
descubrimiento puede emitirla mecánicamente y sin inventar.

---

## 2. Qué **no** es

- **No lleva significado.** No admite `labels`, ni `is`, ni conceptos: lo mismo que la vista, y
  por lo mismo — si la tabla supiera qué significa una columna habría dos sitios diciéndolo, y
  el día que discrepen ninguno diría cuál manda. Su incumplimiento es `OOS1005`.
- **No decide quién ve qué.** El `ConduitPolicy` y las políticas Cedar siguen decidiendo.
- **No tiene lógica.** Ni renombre, ni `where`. Recortar y renombrar son de la vista; la tabla
  es el objeto tal cual está. Es la diferencia entre el *shortcut* de Fabric —la referencia— y
  la *shortcut transformation*, que es otra cosa.
- **No es una vista.** No se materializa, no tiene frescura y no tiene dueño de negocio: tiene
  dueño técnico por su `datasource`. **Materializar es una decisión sobre una consulta**, y la
  consulta es la vista.
- **No se escribe.** El puntero es de solo lectura.

---

## 3. Las dos caras

Nadie tiene *«foreign stream»*. Lo que todos tienen es el puntero de lectura y, aparte, un
**changelog** que nunca se lee por clave y que solo se convierte en tabla materializándolo — la
*streaming table* de Databricks, Tableflow de Confluent, el *mirroring* de Fabric. Y hay una
frase de Flink que une las dos:

> *A stream is the changelog of a table.* Y al revés: una tabla es un changelog integrado.

El `STREAM` de Snowflake lo dice todavía más claro: no es una fuente, es **el registro de
cambios de una tabla**, un objeto derivado. Eso es literalmente `D(tabla)`.

Así que una fuente no es *o* tabla *o* stream. Es un objeto con dos caras, y cada una se declara
por separado:

| cara | pregunta | quién la usa |
|---|---|---|
| **`reads`** — la cara `I` | ¿qué se le puede pedir, y con qué filtros? | el planificador de empuje, la *upquery*, la fase de lectura del ejecutor |
| **`changes`** — la cara `D` | ¿qué cambios emite, con qué codificación y con qué testigo? | el mantenedor incremental, el analizador de refresco, el modelo de coste |

Un tema de Kafka es una tabla cuya cara de lectura es `none`. Una API con `modified_since` es una
tabla cuya cara de cambio es `append`. Un PostgreSQL con ranura de replicación tiene las dos.
**Un «stream» es el nombre corriente de una tabla sin cara de lectura**, y por eso no hace falta
un `kind` para él.

---

## 4. `changes.mode`: las tres codificaciones, y por qué el vocabulario es cerrado

Flink documenta exactamente tres formas de convertir una tabla dinámica en un flujo de cambios.
Son tres, no una lista abierta, y cada una dice qué **pesos** son legales en un delta:

| `mode` | qué manda | en el álgebra |
|---|---|---|
| `append` | solo altas | solo `+1` |
| `retract` | un borrado retracta; una actualización retracta la vieja y añade la nueva | `-1` y `+1` |
| `upsert` | exige clave única; un borrado es un mensaje de borrado (*tombstone*) | `+1` por clave, `-1` por *tombstone* |

Y una cuarta que no es codificación sino ausencia:

| `none` | el origen no emite cambios, o no se sabe si los emite |
|---|---|

El *Change Data Feed* de Delta —`insert`, `update_preimage`, `update_postimage`, `delete`— es
`retract` con cuatro nombres. Los *tombstones* de un tema compactado son `upsert`: Tableflow
retira una fila cuando encuentra un *tombstone* con su clave.

**El vocabulario es cerrado**, y por lo mismo que `predicatePushdown`: si un perfil pudiera
inventar una codificación, el mantenedor no podría razonar sobre los pesos que le llegan, y un
delta con un peso ilegal entraría sin que nadie lo notara. Un `append` que trajera un `-1` se
rechaza porque `append` significa algo.

### 4.1 · El testigo

`changes.witness` dice **qué prueba qué versión de los datos se leyó**. Es el `version.witness`
de v1alpha7, mudado al sitio donde el dato ocurre:

| | Qué es | Ejemplos |
|---|---|---|
| `none` | nada. Legal, y tiene precio: sin testigo no hay marca, y sin marca lo materializado no puede decir hasta cuándo era cierto | un CSV, una API sin versión |
| `snapshot` | la versión nativa de un formato de tabla | `snapshot-id` de Iceberg, la versión de Delta |
| `log` | una posición en un flujo de cambios | LSN, SCN, *offset* |
| `field` | una columna de la propia tabla que ordena el avance | `updated_at` |

Todos son **ordinales**. El motor los compara; no los interpreta ni los convierte. Quien adapte
un almacén mapea su testigo a un ordinal, y esa conversión es suya.

`mode` y `witness` son **independientes**: qué llega y qué lo fecha son dos preguntas. Un
`{append, field}` es una API con marca de agua; un `{retract, log}` es una réplica lógica; un
`{retract, snapshot}` es un lago que resta dos instantáneas.

---

## 5. Forma

```yaml
apiVersion: oos.dev/v1alpha8
kind: Table
metadata:
  name: employees
  namespace: erp
spec:
  datasource: erp                    # declarado en el manifiesto raíz (OOS2004)
  object: "public.employees"         # opaco: las reglas de nombrado son del origen

  # Las columnas físicas, tal cual están. Nombre opaco; tipo en vocabulario de ODCS.
  columns:
    employee_id: { physicalType: "varchar(16)" }
    national_id: { physicalType: "varchar(16)" }
    country:     { physicalType: "char(2)" }
    deleted:     { physicalType: boolean }

  # La cara I. Es `capabilities` de v1alpha7, mudado sin cambios — o `none`.
  reads:
    predicatePushdown: [eq, neq, in, range, isNull]
    fullScan: expensive
    requiredFilters: []

  # La cara D. Qué cambios emite, cómo los codifica y qué los atestigua.
  changes:
    mode: retract                    # none | append | retract | upsert
    witness: log                     # none | snapshot | log | field
    # key: [employee_id]             # obligatorio con `mode: upsert`
    # field: updated_at              # obligatorio con `witness: field`
    # retention: 7d                  # cuánto guarda el origen el changelog, si se sabe
```

Un tema, una API y un lago, en la misma forma:

```yaml
# Kafka: se escribe, no se pregunta. Sin cara de lectura.
spec:
  datasource: bus
  object: "orders.v2"
  columns: { order_id: {}, customer_id: {}, total: {} }
  reads: none
  changes: { mode: upsert, key: [order_id], witness: log, retention: 7d }
```

```yaml
# Una API con `modified_since`: se pregunta por clave, y solo sabe de altas.
spec:
  datasource: workday
  object: "Worker"
  columns:
    "Worker_Reference.ID": {}
    "Last_Modified": { physicalType: timestamp }
  reads:
    predicatePushdown: [eq]
    fullScan: forbidden
    requiredFilters: ["Worker_Reference.ID"]
  changes: { mode: append, witness: field, field: "Last_Modified" }
```

```yaml
# Iceberg en el lago: se recorre entero sin drama, y cada snapshot dice qué cambió.
spec:
  datasource: lago
  object: "ventas.pedidos"
  columns: { id: {}, pais: {}, total: { physicalType: "decimal(18,2)" } }
  reads: { predicatePushdown: [eq, in, range], fullScan: cheap }
  changes: { mode: retract, witness: snapshot }
```

### 5.1 · Lo que muda de la vista de v1alpha7, campo a campo

| `View` v1alpha7 | `Table` v1alpha8 | Qué cambia |
|---|---|---|
| `from.datasource` | `datasource` | nada |
| `from.object` | `object` | nada |
| `capabilities` | `reads` | el nombre; que admite `none`; y que `requiredFilters` nombra **columnas**, no propiedades — §6 |
| `version.witness` | `changes.witness` | el sitio: es del objeto, no de quien lo consulta |
| — | `columns` | **nuevo**: qué columnas hay, no cuáles usa una vista |
| — | `changes.mode` | **nuevo**: qué llega, no solo qué lo fecha |
| `fields`, `where`, `materialized`, `freshness`, `owner` | — | se quedan en la vista: son de la consulta |

---

## 6. Restricciones

- `datasource` **DEBE** estar declarado en el manifiesto raíz — `OOS2004`, el mismo que
  `datasourceRef` y que `from.datasource`, porque es el mismo defecto.
- `columns` **DEBE** tener al menos una columna. Una tabla sin columnas no es un puntero a nada:
  es un nombre.
- `reads` es **o** el objeto de capacidades **o** el literal `none`. `none` significa *no se le
  puede pedir nada*, y tiene una consecuencia sobre quien la consulte: `OOS2020`, en
  [`02-view` §5](02-view.md#5).
- Cada nombre de `reads.requiredFilters` **DEBE** ser una columna de `columns` — `OOS2018`.
  Cambia de sujeto respecto al binding, donde eran **propiedades**: un filtro exigido lo exige
  el origen, y el origen habla de columnas. Es lo que deja que un nombre anidado
  —`"Worker_Reference.ID"`— sea un filtro exigido legal, cosa que con un identificador no cabía.
- Con `changes.mode: upsert`, `changes.key` **DEBE** estar presente y **cada uno de sus nombres
  DEBE ser una columna de `columns`** — `OOS2018`. Sin clave, un *tombstone* no dice qué retira.
- Con `changes.witness: field`, `changes.field` **DEBE** estar presente y **DEBE ser una columna
  de `columns`** — `OOS2018`. Una marca de agua que no es columna no la puede leer nadie.
- `changes.key` y `changes.field` **NO DEBEN** aparecer donde no significan nada: `key` solo con
  `upsert`, `field` solo con `witness: field`. Un campo que se ignora es peor que uno que no
  existe, porque promete algo.
- `retention` es informativo y opcional. Dice cuánto guarda el origen su changelog; quien
  planifique un refresco lo usa para saber si puede llegar tarde.
- La tabla **NO** admite `labels`. Estructural: `OOS1005`.

---

## 7. Lo que la tabla hace posible, y antes no lo era

**`OOS2018` sobre una vista de fuente pasa a ser comprobable.** Hasta aquí, una vista que
nombraba `national_id` en `fields` no se podía verificar contra nada: no había ningún documento
que dijera qué columnas tenía `public.employees`. Se comprobaba solo el eslabón vista→vista.
Con `columns`, **la comprobación llega hasta el suelo**.

**El mantenedor deja de adivinar.** Un delta que llega de una tabla `append` con un peso `-1` es
un error del integrador, no un dato raro. Antes no había forma de decirlo.

**El descubrimiento espeja en vez de inferir.** Ver [`00-scope` §4](00-scope.md#4).
