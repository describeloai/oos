# 01 · Dataset — lo que se tiene

**Estado:** borrador. Parte de OOS v1alpha12.
**Anfitrión:** el plan es el de [`v1alpha8/02-view`](../v1alpha8/02-view.md) —`from`, `fields`,
`where`, `groupBy`, `having`— tal cual, y las columnas son las de
[`v1alpha8/01-table`](../v1alpha8/01-table.md) §5.0. No se repite aquí lo que aquellos dicen;
se dice qué cambia al vivir en un dataset.

---

## 1. Naturaleza

> **Un dataset es lo que un inquilino tiene: una tabla en su lago, con historia, nombrada por
> un documento de su paquete. Tiene dueño y columnas, y se llena de una de dos maneras: el
> sistema cumple el plan que el documento declara, o código la escribe y el sistema registra
> lo que llegó.**

Es **el asset primario del registro**: lo que el catálogo lista cuando lista lo que el cliente
tiene, lo que una vista lee cuando no lee de fuera, lo que una entidad respalda cuando sus filas
son nuestras, lo que un modelo entrenado nombra en `trainedFrom`, y lo que un transform produce.
Sus **versiones son sus snapshots**; su **estado** —cuál es el vigente, dónde está, cuántas
filas, quién y de qué— es el puntero, que no está en el documento (§8).

## 2. Qué **no** es

- **No es una `Table`.** La tabla es el puntero a lo que es de otro, con las dos caras que
  hay que declarar porque nadie de aquí las controla. Un dataset es nuestro: sus caras se
  saben (§6), y no se declaran.
- **No es una `View`.** La vista es la pregunta y no tiene bytes. Un dataset puede **nacer de
  una pregunta** (`from: { view }`) y entonces es sus filas guardadas; la pregunta sigue siendo
  la vista, y se puede hacer sin él.
- **No es un `TrainedModel`.** Aquél nombra ficheros por digest; éste, una tabla con columnas.
- **No lleva `labels`**, ni en `metadata` ni en las columnas (`OOS1005`). La clasificación la
  declara la `Entity` que lo respalda y baja por el plan.
- **No lleva calidad.** Un `Ruleset` lo nombra.
- **No es el trabajo que lo escribió.** El código vive en un commit; el puntero lo nombra.

## 3. Las dos formas

La clave que las distingue es **`from`**: si está, el dataset es **mantenido**; si no, y hay
`columns`, es **escrito**. Exactamente una de las dos —`OOS1004` con las dos o con ninguna—.

### 3.1 · Mantenido: el sistema cumple el plan

```yaml
apiVersion: oos.dev/v1alpha12
kind: Dataset
metadata:
  name: customers
  namespace: olist
  description: …                          # opcional
spec:
  owner: team:olist
  from: { table: olist.customers }        # o { view: … } o { dataset: … }
  fields: { id: customer_id, city: city } # opcional: sin `fields`, todo lo que `from` expone
  where: { country: BR }                  # opcional
  freshness: 15m                          # opcional: cuánto retraso se tolera
  history: { maxAge: 30d, minSnapshots: 3 } # opcional: cuánta historia se guarda
```

Es la copia de una tabla (identidad: sin `fields` ni `where`), las filas guardadas de una vista,
o una copia derivada de otra copia. **Lo que hasta v1alpha11 era una `View` con `materialized`**,
con el plan en el mismo sitio y las mismas reglas (§5). Con `groupBy`/`having` es un agregado
guardado.

### 3.2 · Escrito: código lo llena, el sistema registra

```yaml
apiVersion: oos.dev/v1alpha12
kind: Dataset
metadata:
  name: resumen
  namespace: ventas
spec:
  owner: team:ventas
  columns:                                # sigue a la tabla Iceberg
    pais: { type: String }
    n: { type: Integer }
    total: { type: Decimal, description: en euros }
  changes: { mode: upsert, key: [pais] }  # qué escrituras admite
  derivedFrom: [ventas.pedidos]           # lo que el código leyó para escribirlo
  history: { maxAge: 7d }                 # opcional
```

Es **lo que hasta v1alpha11 era una `Table` con `datasource: lago`**. Su esquema **sigue a los
bytes**: el documento nace con la primera escritura, sus columnas cambian cuando la tabla
cambia, y lo que se le añada a mano —`description`, un `type` afinado— se conserva. Su linaje
por snapshot está **en el puntero** (§8); lo que **lleva puesto** está aquí: `derivedFrom`
nombra lo que el código leyó para escribirlo (vistas o datasets), y por ahí baja la
clasificación (§5). Lo escribe el sistema en el mismo acto que `columns` —de la procedencia de
la escritura: los `inputs` del transform, o lo que la sesión leyó—, y una persona puede
corregirlo. Un escrito sin `derivedFrom` es un dataset que dice no haber leído nada: lleva lo
que sus columnas digan, y nada más.

## 4. Las claves

| clave | forma | | |
|---|---|---|---|
| `owner` | las dos | **obligatoria** | `team:<n>` o `user:<n>`; `OOS2009` si no lo es |
| `from` | mantenido | **obligatoria** | **exactamente una** de `{ table }`, `{ view }`, `{ dataset }`. Forma corta en el mismo espacio de nombres (N1). Debe resolver (`OOS2018`); la cadena no vuelve sobre sí (`OOS2019`) |
| `fields`, `where`, `groupBy`, `having` | mantenido | opcionales | **la gramática de `v1alpha8/02-view`** §2 y §4, sin cambio alguno: los valores de `fields` y las claves de `where` son lo que `from` expone (§6), `OOS2018` si no. Sin `fields`, el dataset expone todo lo que `from` expone, con sus nombres |
| `freshness` | mantenido | opcional | duración: cuánto retraso se tolera respecto a `from`. Es el *target lag*. Superado sin refresco, el dataset está degradado y no se sirve como fresco |
| `columns` | escrito | **obligatoria** | `<nombre>: { type?, description? }`, como `Table.columns` sin `physicalType` (el físico es Iceberg y no se cita). Al menos una |
| `derivedFrom` | escrito | opcional | lista de `<paquete>.<nombre>` de vistas o datasets, **lo que el código leyó para escribirlo**. Cada nombre resuelve (`OOS2018`); no se nombra a sí mismo (`OOS2019`). Por aquí baja la clasificación (§5) |
| `changes` | escrito | **obligatoria** | `{ mode: append \| upsert, key? }`: **qué escrituras admite**. `append`: sólo altas; una escritura que funda por clave se niega. `upsert`: exige `key` (`OOS1004` sin ella), cada nombre una columna (`OOS2018`), y es por lo que se funde. No lleva `witness`: es `snapshot`, siempre, porque es Iceberg |
| `history` | las dos | opcional | `{ maxAge?: duración, minSnapshots?: entero ≥ 1 }`, al menos una: cuánta historia se conserva. Sin ella, la que el inquilino tenga por defecto |
| `metadata.namespace` | las dos | **obligatoria** | vive en un paquete |
| `metadata.description` | las dos | opcional | |

Lo que **no** admite, y es `OOS1005`: `materialized`, `datasource`, `object`, `reads`,
`profile`, `labels`, `quality`, `retention` (es `history`), `witness`.

## 5. La costura: lo que un dataset mantenido instancia

Un dataset mantenido **copia datos**, y por eso instancia el conducto `materialization.payload`
exactamente como lo instanciaba la vista con `materialized`: cada campo del plan fluye por él
y lleva lo que llevan sus campos —lo que el datasource raíz etiqueta y lo que cualquier entidad
respaldada por la cadena declaró sobre ellos— (`OOS4001`, `OOS4002`, `OOS4011`). **Que esto no
cambie es la afirmación de esta versión**: la clave se movió de documento; la regla de flujo,
no. La forma más fuerte de aplicar una máscara sigue siendo no pedir la columna, y la
proyección del dataset es donde una tabla copiada pierde una.

**Y lo escrito lleva lo que leyó.** Un dataset escrito con `derivedFrom` lleva, en **cada**
columna, el join de lo que llevan **todos** los campos de lo que leyó: el código no declara qué
columna salió de cuál, y quedarse corto no produce ningún síntoma (P4). Es lo que hace que la
etiqueta no muera en la escritura: un mantenido sobre el escrito, una vista encima, una entidad
que lo respalda o una función que lo lee ven esa carga como ven la de una raíz. La máscara sigue
siendo la de siempre —no leer el campo—, y aquí se declara en `derivedFrom`: leer una vista que
no expone `dni` es no llevar `dni`.

Y por lo mismo, **las reglas del mantenimiento** que v1alpha8 escribió sobre «una vista
`materialized`» se leen ahora sobre «un dataset mantenido», sin cambiar de código:

| | |
|---|---|
| `OOS2021` | un dataset cuya raíz tiene `changes.mode: append` **no puede** respaldar una entidad con `nature: entity`. Vale para el mantenido (por su raíz) y para el escrito (por su propio `changes.mode`) |
| `OOS2023` | un dataset mantenido cuya raíz de lectura declara `changes: { mode: append, witness: field }` **no** compila |
| `OOS2024` | un dataset mantenido con `fields` sobre una raíz `upsert` exige que la raíz declare `changes.key` |
| `OOS2020` | una vista cuya raíz de lectura es una tabla con `reads: none` **debe** tener un dataset por debajo: el dataset es siempre raíz de lectura (§6) |

**La raíz** de un dataset mantenido es a donde se llega bajando por `from` hasta que deja de
haber `view` o `dataset`: una `Table`, o un dataset **escrito**, que es raíz por derecho (no
tiene `from`). **La raíz de lectura** de cualquier cadena es el primer dataset que se encuentre
bajando, o la tabla si no hay ninguno: es de donde salen las filas.

## 6. Lo que un dataset expone, y lo que se deriva

Quien lee un dataset —una vista con `from: { dataset }`, otro dataset, una entidad con
`backedBy`, una función con `reads`— necesita saber qué columnas tiene y con qué caras. **No se
declaran: se saben.**

| | mantenido | escrito |
|---|---|---|
| **lo que expone** (los nombres contra los que se resuelve `fields`, `where`, `backedBy`) | las claves de `fields` si las hay; si no, lo que `from` expone, con sus nombres | las claves de `columns` |
| **el tipo** de cada columna | el de la columna de la raíz, o el derivado del agregado (`02-view` §5) | `columns.<c>.type`, o texto si no lo dice |
| **`reads`** (la cara `I`) | **las del lago**: `fullScan: cheap`, `predicatePushdown: [eq, neq, in, range, isNull]`, `projectionPushdown: true`. Constantes: es Iceberg, y una implementación las conoce |
| **`changes`** (la cara `D`) | **derivada**: `mode` y `key` los de la raíz, `witness: snapshot` | **declarada**: `changes.mode` y `changes.key`, `witness: snapshot` |

Es la misma asimetría que entre tabla y vista: la tabla **declara** porque espeja; el dataset
**deriva** porque es nuestro. Un documento que dijera `reads` de un dataset diría algo que la
implementación ya sabe mejor que él.

## 7. Las reglas

| | código | |
|---|---|---|
| sin `owner`, o sin `metadata.namespace` | `OOS1004` | la forma mínima |
| `owner` que no es `team:` ni `user:` | `OOS2009` | |
| ni `from` ni `columns`, o los dos | `OOS1004` | una forma o la otra |
| `fields`, `where`, `groupBy`, `having` o `freshness` sin `from` | `OOS1004` | son del plan |
| `changes` o `derivedFrom` sin `columns` | `OOS1004` | son del escrito: el mantenido lo deriva y su linaje es `from` |
| un nombre de `derivedFrom` que no resuelve a una vista o un dataset; el propio nombre | `OOS2018`, `OOS2019` | |
| `columns` vacío; `changes` sin `mode`; `mode` fuera de `append`/`upsert` | `OOS1004` | |
| `changes.mode: upsert` sin `key`; `key` con `append` | `OOS1004` | como en `Table` |
| un nombre de `key` que no es una columna | `OOS2018` | |
| `history` vacío, `minSnapshots` < 1 | `OOS1004` | |
| `from` que no resuelve a una tabla, una vista o un dataset | `OOS2018` | |
| un valor de `fields`, una clave de `where` o de `groupBy` que `from` no expone | `OOS2018` | |
| la cadena vuelve sobre sí (`from` que llega a este mismo documento) | `OOS2019` | |
| un mantenido sin conducto que lo admita, o cuyo plan lleve lo que el conducto niega —también lo que llega por `derivedFrom` de un escrito de su cadena— | `OOS4011`, `OOS4002` | §5 |
| respalda una entidad `nature: entity` con `mode: append` | `OOS2021` | §5 |
| mantenido sobre raíz `append` + `witness: field` | `OOS2023` | §5 |
| una clave que no es de aquí (`materialized`, `datasource`, `object`, `reads`, `labels`, `quality`…) | `OOS1005` | |
| `kind: Dataset` en v1alpha11 o antes | `OOS1003` | |

## 8. Lo que la gramática no decide

**El puntero.** `metadata_location`, el snapshot vigente, las filas, `escrito_por`, la
**procedencia** —de qué inputs, con qué transform, con qué código en qué commit— de cada
snapshot: lo escribe quien escribe los bytes, en el mismo acto, y es el estado. En un
mantenido, la procedencia es el plan cumplido en un instante (qué snapshot de la raíz se leyó);
en un escrito, es lo que el código declaró leer y quién era. Un árbol tiene que poder leerse
sin el lago, así que la gramática admite un dataset cuyo puntero no existe todavía: es un
dataset **sin escribir**, y el catálogo lo dice.

**La rama.** El puntero es de la rama del árbol en la que se escribió; la tabla es una, y la
rama apunta a su snapshot como una *ref* de Iceberg. Que una rama sin puntero lea el de `main`
es del que sirve, no de la gramática.

**Que el esquema cuadre.** En un escrito, `columns` sigue a la tabla: si una escritura añade
una columna, el documento la gana en el mismo commit; si la quita, la pierde. Lo que la
gramática no dice es que una escritura **se niegue** por no cuadrar: eso es un contrato, y es
otra decisión (`00-scope` §5).

**Cuándo se cumple el plan.** `freshness` dice cuánto retraso se tolera; quién refresca, con
qué testigo y en qué orden, es del mantenedor.
