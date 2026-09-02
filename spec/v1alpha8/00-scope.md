# OOS v1alpha8 — alcance

**Estado:** borrador de alcance. Gobierna los documentos que declaran su `apiVersion`, y es
**alpha**: sin garantías de compatibilidad.

| | |
|---|---|
| `00-scope` | **este documento** — qué entra, qué no, y por qué lo físico se registra una vez |
| [`01-table`](01-table.md) | la tabla: naturaleza, las dos caras, la forma y las reglas |
| [`02-view`](02-view.md) | la vista, adelgazada: qué pierde, qué conserva, y **las dos reglas nuevas** (§5) |

Esta versión **añade un `kind`** —`Table`—, **adelgaza otro** —`View` pierde `capabilities` y
`version`— y **retira un tercero** —`Binding` deja de estar en la gramática. Añade dos códigos
de error, y los dos son de compilación: `OOS2020` y `OOS2021`.

v1alpha7 dejó escrito que la coexistencia de `Binding` y `View` estaba acotada y tenía fin.
Esta versión es ese fin, y trae además lo que aquella no vio: **el puntero físico no era de la
vista**.

---

## 1. La tesis

Cada versión gobierna un verbo, y aporta **una** regla:

| | Gobierna | Regla |
|---|---|---|
| **v1alpha1** | lo que se puede **saber** | `L ⊑ C` |
| **v1alpha2** | lo que se puede **causar** | `I(f) ⊒ I(destino)` |
| **v1alpha3** | qué debe **sostenerse** | `L(x) ⊒ n ⟹ ∃r` |
| **v1alpha4** | **qué es la misma cosa** | `E implements I ⟹ ∀c ∈ I . ∃p ∈ E . is(p) = c` |
| **v1alpha5** | lo que se puede **pedir** | `S = { p : L(p) ⊑ C(contextSurface) }` |
| **v1alpha6** | **de quién es lo que usas** | `usar(P) ⟹ digest(P) ∈ lock` |
| **v1alpha7** | **de dónde sale lo que sabes** | `L(E.p) ⊒ L(raíz(V, p))` |
| **v1alpha8** | **de qué está hecha una fuente** | `Table = I(changes)` · `View = Q(Table)` · `materialized = I(Q^Δ)` |

La regla se lee: **una tabla es la integral de sus cambios; una vista es una consulta sobre una
tabla; y materializar una vista es integrar el resultado de esa consulta aplicada a los
cambios.** Es la dualidad *stream* / tabla, escrita como gramática.

Y arrastra dos corolarios, que son los dos códigos nuevos:

- **sin `I` no hay lectura** — una tabla que no se deja leer solo se consulta a través de una
  copia. Es `OOS2020`;
- **sin `-1` no hay `I` de una cosa que cambia** — un flujo que solo sabe anexar no puede
  sostener el estado presente de algo mutable. Es `OOS2021`.

Ninguno de los dos es nuevo como hecho del mundo: los dos están documentados por quien los
sufrió. Lo nuevo es que **aquí no compilan**.

---

## 2. Por qué la vista no debía llevar el puntero

v1alpha7 metió el puntero físico dentro de la `View` —`from: {datasource, object}`, `fields`,
`capabilities`, `version`— porque el `Binding` lo tenía así y la absorción se hizo campo a
campo. Fue el puente correcto y es la forma equivocada para quedarse:

| Con el puntero en la vista | Por qué duele |
|---|---|
| cada vista que toca una fuente **repite** el contrato físico | dos vistas sobre `public.employees` declaran dos veces qué se puede empujar; el día que la fuente cambie, una se actualiza y otra no. Es el defecto del binding otra vez, con otro nombre |
| una vista sobre otra vista **no tiene ninguno** | `capabilities` y `version` son opcionales en el eslabón de arriba porque **no son suyos**. Un campo que solo tiene sentido en una de las dos formas de `from` es un campo mal colocado |
| las columnas de la fuente **no se declaran en ninguna parte** | `fields` dice qué columnas usa *esta* vista, no qué columnas **hay**. Sin eso, `OOS2018` sobre una vista de fuente no es comprobable: no hay contra qué comprobar |
| el cambio —cómo se entera el motor de que algo pasó— **cabía en un enum de cuatro valores** | `version.witness` dice *qué prueba* la versión, y no dice *qué llega*: si trae borrados, si trae la imagen previa, si exige clave. El mantenedor incremental necesita justo eso, y lo estaba adivinando |

Los cuatro tienen la misma raíz: **el contrato es del objeto, no de quien lo consulta.**

Es lo que el sector ya había resuelto, con un nombre distinto cada uno: *foreign table* en
Databricks, *virtual table* en Foundry, *shortcut* en Fabric, *external table* en BigQuery y
Snowflake, *connector table* en Trino. La descripción coincide en todos: una referencia a algo
de fuera, registrada en el catálogo, de solo lectura, y sobre la que las vistas componen. No
tiene sentido inventar un nombre para lo que todo el mundo llama igual.

---

## 3. Lo que se añade, lo que adelgaza y lo que se retira

| | |
|---|---|
| **se crea** | `kind: Table` · `schemas/v1alpha8/` · `OOS2020` y `OOS2021` · `conformance/v1alpha8/` |
| **adelgaza** | `kind: View` — pierde `capabilities` y `version`; `from` nombra una tabla o una vista |
| **se reutiliza** | `OOS2004` para `datasource` · `OOS2018` para lo que no resuelve o no es columna · `OOS2019` para el ciclo · `OOS2011` para la clave que la vista no expone · `OOS4001`, `OOS4002` y `OOS4011` para la copia |
| **no se toca** | el retículo, el conducto, el concepto, `is`, la interfaz, `Entity` salvo su `apiVersion`, la forma canónica, el digest, la firma, el log, `ore diff` |
| **se retira** | `kind: Binding` — §5.3 |

Que los códigos se **reutilicen** en vez de duplicarse vuelve a ser la prueba de que la tabla no
cambia la regla, cambia el sujeto. Un `OOS2018` sobre un campo que no es columna de la tabla
significa exactamente lo que significaba sobre un campo que la vista de abajo no exponía.

Los dos que **sí** son nuevos lo son porque antes ni siquiera eran comprobables: hasta que la
tabla no declara sus dos caras, no hay con qué preguntar *«¿esto se puede leer?»* ni *«¿esto
retracta?»*.

---

## 4. La decisión de forma que decide todo lo demás

> **Un objeto físico se registra una vez, con sus dos caras. La vista compone encima.**

Las dos caras son `reads` —qué se le puede pedir— y `changes` —qué cambios emite. No son dos
objetos: son dos preguntas sobre el mismo. De ahí salen tres consecuencias que no hay que
escribir en ninguna parte porque se siguen:

- **no hay `kind: Stream`.** Un *stream* es el nombre corriente de una tabla cuya cara de lectura
  es `none`. Dos nombres para un concepto es el error que este proyecto persigue, y sería el
  tercero: ya pasó con `Property`, que era dos cosas, y con `Binding`, que era media vista;
- **`discover` deja de inferir la mitad física.** Las columnas, lo que el driver sabe empujar y
  lo que el origen sondea son **hechos**, y un hecho se emite sin revisión. Lo que sigue siendo
  conjetura —qué es una entidad, qué significa una columna— sigue reportándose;
- **`backedBy` sigue nombrando una vista, nunca una tabla.** Si nombrara una tabla, las
  propiedades de la entidad tendrían que llamarse como las columnas físicas, y lo semántico
  volvería a saber de lo físico — que es de lo que v1alpha7 vino a sacarnos. Exponer una tabla
  tal cual cuesta una vista de tres líneas, y **esas tres líneas son las que dicen «esto se
  expone»**.

---

## 5. Cómo termina: la migración

### 5.1 · Es mecánica, y cabe en una tabla

| de | a |
|---|---|
| `View` v1alpha7 con `from: {datasource, object}` | una **`Table`** con ese `datasource` y `object`, `columns` = los valores de `fields` más las claves de `where`, `reads` = `capabilities`, `changes.witness` = `version.witness`, `changes.mode` = §5.2 — **más** la misma `View` con `from: {table}` y sin `capabilities` ni `version` |
| `View` v1alpha7 con `from: {view}` | la misma, con el `apiVersion` nuevo |
| `Binding` | una **`Table`** con `datasourceRef`→`datasource` y `source`→`object`, `columns` = los valores de `properties` más las claves de `selector`, `reads` = `capabilities`, `changes` = §5.2 — **más** una **`View`** con `fields` = `properties`, `where` = `selector`, y `materialized`/`freshness` de `materialization.payload` si lo había — **más** `backedBy` en la entidad |
| `materialization.topology` | **no se migra**: es derivable —el índice es una vista de aristas— y se computa (P2) |
| `Entity` | sin cambios salvo `apiVersion` y `backedBy` |

Dos bindings sobre el mismo objeto con selectores disjuntos —lo que `OOS2014` vigilaba— pasan a
ser **una tabla y dos vistas**, que es la forma que aquel código tenía a medias: el objeto era
uno, y por eso hacía falta un código para recordarlo.

### 5.2 · `changes.mode` para lo que no lo declaraba

Un documento anterior a v1alpha8 no sabe de codificaciones del cambio. La migración lo deduce
de lo que sí declaraba, **y lo deja escrito como deducción**:

| tenía | `mode` | por qué |
|---|---|---|
| `strategy: table_version` o `witness: snapshot` | `retract` | dos snapshots se restan, y la resta tiene signo |
| `strategy: cdc` o `witness: log` | `retract` | un changelog de base de datos trae la imagen previa; **si no la trae**, quien migra baja a `append` y `OOS2021` se lo cobrará donde toque |
| `strategy: poll` o `witness: field` | `append` | una marca de agua no ve borrados |
| nada | `none` | no se sabe, y no se inventa |

### 5.3 · El `Binding` se retira, no se borra

`kind: Binding` **deja de estar en la gramática a partir de v1alpha8**. Un documento que declare
`apiVersion: oos.dev/v1alpha8` y sea un `Binding` falla con `OOS1003`.

Un documento que declare `apiVersion: oos.dev/v1alpha1` y sea un `Binding` **sigue compilando**,
porque v1alpha1 es normativo y sigue diciendo lo que decía. La suite de conformidad de v1alpha1
no se toca, ni la de ninguna versión anterior.

Esto es lo que hace que la migración no roce: **el `apiVersion` es por documento**. Un paquete
puede tener entidades v1alpha8 respaldadas por vistas sobre tablas y, al lado, un binding
v1alpha1 que nadie ha migrado todavía. Los dos caminos convergen donde ya convergían —en la
operación que resuelve de dónde sale un dato—, que es una y no dos. Se migra documento a
documento, y **ningún día es el día en que todo se rompe**.

---

## 6. Lo que **no** entra

**Un `kind: Stream`.** §4. Sería un segundo nombre para una tabla sin cara de lectura.

**Unir, agregar, deduplicar, limitar.** Siguen fuera del vocabulario de la vista, y por la misma
razón que en v1alpha7: cada una tiene un precio en la regla de flujo, y el precio se decide
antes de admitir la operación. La tabla no cambia ese cálculo.

**`UNNEST`.** Un documento con un array no se aplana sin un operador que la gramática no tiene.
`columns` lo hace **visible** —dice qué hay, con el tipo que el origen le da— sin resolverlo.

**Nulos.** El límite real de lo semi-estructurado. La tabla lo enseña; no lo arregla.

**Escritura.** El puntero es de solo lectura, y `05-ejecutor` §6.2 ya lo era. Toda la industria
coincide en esto, y las excepciones recientes —escribir sobre Iceberg externo— son otra pieza,
con otro contrato.

**Quién ve qué.** Sigue siendo el `ConduitPolicy` y las políticas Cedar. Una tabla dice qué
existe; el conducto dice quién puede. Es lo que deja que una tabla gobernada siga siendo
componible.
