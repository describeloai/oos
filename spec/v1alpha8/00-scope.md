# OOS v1alpha8 — alcance

**Estado:** borrador de alcance. Gobierna los documentos que declaran su `apiVersion`, y es
**alpha**: sin garantías de compatibilidad.

| | |
|---|---|
| `00-scope` | **este documento** — qué entra, qué no, y por qué lo físico se registra una vez |
| [`01-table`](01-table.md) | la tabla: naturaleza, las dos caras, la forma y las reglas |
| [`02-view`](02-view.md) | la vista, adelgazada: qué pierde, qué conserva, y **las tres reglas nuevas** (§5) |

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
| **se crea** | `kind: Table` —con sus tres caras— · `schemas/v1alpha8/` · `OOS2020`, `OOS2021`, `OOS2022`, `OOS2023`, `OOS2024` y `OOS7012` · `conformance/v1alpha8/` |
| **adelgaza** | `kind: View` — pierde `capabilities` y `version`; `from` nombra una tabla o una vista |
| **se reutiliza** | `OOS2004` para `datasource` · `OOS2018` para lo que no resuelve o no es columna · `OOS2019` para el ciclo · `OOS2011` para la clave que la vista no expone · `OOS4001`, `OOS4002` y `OOS4011` para la copia |
| **no se toca** | el retículo, el conducto, el concepto, `is`, la interfaz, `Entity` salvo su `apiVersion`, la forma canónica, el digest, la firma, el log, `ore diff` |
| **se retira** | `kind: Binding` — §5.4 · `effects[].datasourceRef` — §3.1 |

Que los códigos se **reutilicen** en vez de duplicarse vuelve a ser la prueba de que la tabla no
cambia la regla, cambia el sujeto. Un `OOS2018` sobre un campo que no es columna de la tabla
significa exactamente lo que significaba sobre un campo que la vista de abajo no exponía.

Los que **sí** son nuevos lo son porque antes ni siquiera eran comprobables: hasta que la tabla
no declara sus caras, no hay con qué preguntar *«¿esto se puede leer?»*, *«¿esto retracta?»* ni
*«¿esto se puede escribir?»*.

### 3.1 · Y el efecto pierde su `datasourceRef`

Un `effect` declaraba dos cosas: `writes`, la **propiedad** que toca, y `datasourceRef`, la
**fuente** donde cae. En v1alpha8 la segunda sobra, porque el camino ya existe y es el mismo que
recorre la lectura:

```text
entidad  →  backedBy  →  vista  →  raíz  →  tabla  →  datasource
```

Declararlo sería un segundo sitio que puede discrepar del primero, y esta versión entera existe
porque había N sitios describiendo lo físico y pasó a haber uno. `writes` **se queda tal cual**:
nombrar la propiedad es correcto, porque es el idioma de la ontología y la ontología no debe
saber en qué columna cae.

La regla que se apoyaba en él —`OOS7008`, *una función, una fuente*— **no cambia de significado**:
cambia de dónde saca la fuente. Antes la leía del efecto; ahora la deriva por ese camino. Un
paquete que la violaba la sigue violando.

Bajo `oos.dev/v1alpha8` un `datasourceRef` dentro de un `effect` es `OOS1005` —clave desconocida—,
y bajo v1alpha2 sigue siendo obligatorio. Es el mismo trato que recibe el `Binding` en §5.4, por
la misma razón: un documento no caduca por haber sido escrito antes.

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
| `Binding` | una **`Table`** con `datasourceRef`→`datasource`, `source`→`object` y `profile`, `columns` = los valores de `properties` más las claves de `selector`, `reads` = `capabilities`, `changes` = §5.2 — **más** una **`View`** con `fields` = `properties`, `where` = `selector`, y `materialized`/`freshness` de `materialization.payload` si lo había — **más** `backedBy` en la entidad |
| `materialization.topology` | **no se migra**: es derivable —el índice es una vista de aristas— y se computa (P2) |
| `Binding.properties.<x>.expression` | **no se migra, y se pierde.** Un cálculo físico —`DATEDIFF(...)` sobre el origen— no cabe en `fields`, que solo renombra. No es un olvido de esta versión: v1alpha7 ya lo había dejado fuera al absorber el binding, y migrar el escaparate es lo que lo destapó. §5.5 |
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

### 5.3 · Lo que la migración **pierde**, y por qué se dice en vez de taparse

Una migración que solo enumera lo que se conserva es una migración que promete
que no se pierde nada. Esta pierde una cosa, y es mejor tenerla escrita aquí que
descubrirla en el repositorio de alguien:

> **`Binding.properties.<x>.expression`** —un cálculo que el ORIGEN ejecuta— no
> tiene dónde ir.

`fields` de una vista **renombra**, y nada más. Una expresión libre no entra en el
vocabulario, y no por falta de sitio: `v1alpha7/01-view` §8 lo decide y esta
versión no lo reabre — *«lo que no quepa en el vocabulario no entra como
expresión libre; entra, cuando entre, como opaca declarada, y cuesta la garantía
de análisis»*.

Así que una propiedad calculada en el origen se convierte en una propiedad
**derivada de la entidad**, con su `derivedFrom` y su `expression` documental, y
deja de tener columna. Lo que se pierde es que el origen la calcule; lo que se
conserva es la procedencia, que es lo que propaga las etiquetas.

No es una pérdida de v1alpha8: **v1alpha7 ya la había causado** al absorber el
binding en la vista, y nadie lo notó porque nada se había migrado todavía.
Migrar el escaparate es lo que la destapó, que es exactamente para lo que sirve
migrar el escaparate.

### 5.4 · El `Binding` se retira, no se borra

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
antes de admitir la operación. La tabla no cambia ese cálculo — y le añade una segunda razón,
§6.1.

**Una entidad servida desde varios objetos.** `03-binding` §2.1 lo admitía —*«una entidad PUEDE
tener varios bindings; cada uno cubre un subconjunto de sus propiedades»*— y esta versión **no**.
Una entidad tiene un `backedBy`, una vista sale de un sitio, y componer dos objetos por su clave
es una junta.

No es lo mismo que *«un objeto físico PUEDE sostener varias entidades»*, que sí se migra sin
pérdida: es una tabla y N vistas, y está en §5.1.

Lo que se pierde tiene sustituto, y el sustituto dice la verdad sobre el mundo: **dos sistemas son
dos entidades con una relación**, o son **una copia declarada**. Las dos son expresables, y
ninguna mueve un byte que nadie haya mandado mover. Lo que desaparece es que la ontología finja
que dos registros son un solo objeto sin que nadie lo declare.

### 6.1 · Y la segunda razón: por qué las cinco exclusiones son **una**

Las cuatro operaciones de arriba y la federación se excluyeron una a una, cada una por su precio.
Miradas juntas son la misma frontera vista desde el otro lado.

La regla de esta versión dice `View = Q(Table)`. El día que se escriba **a través** de una vista
—y ese día está en la dirección del proyecto: una función sobre la ontología tiene que aterrizar
en algún sitio— escribir es `Q⁻¹`, y una vista solo se deja escribir si `Q` es invertible.

| operación | ¿invertible? | ¿está? |
|---|---|---|
| renombrar | sí, es una biyección | **sí** |
| recortar por partición | sí: la fila escrita cumple el predicado o se cae de la vista | **sí** |
| proyectar | parcialmente — faltan columnas, así que la escritura es *parcial*, no ambigua | **sí** |
| unir *(incluida la federación por clave)* | **no**: no se sabe a cuál de las bases escribir | no |
| agregar | **no**: una fila del resultado no corresponde a una fila de la base | no |
| deduplicar | **no**: la inversa no es una función | no |
| limitar | **no**: qué filas están es un hecho del orden, no del dato | no |

Lo que la vista sabe hacer es **exactamente el fragmento invertible**, y eso no se buscó: se
descubrió al migrar el árbol.

Y hay una corroboración que no venía de aquí. Las *materialized views* de Snowflake **solo pueden
consultar una tabla** y **no admiten juntas, ni siquiera auto-juntas** —tampoco UDFs, ni funciones
de ventana, ni `HAVING`, ni `ORDER BY`, ni `LIMIT`—. Es casi este mismo fragmento, y llegaron por
otro camino: ellos lo restringen por **mantenibilidad incremental**, esta versión lo cerró por **el
precio en la regla de flujo**, y resultó ser **el fragmento invertible**. Tres razones
independientes, la misma frontera. Admitir cualquiera de las cuatro haría el sustrato de solo lectura
para siempre, y esa es una decisión demasiado grande para tomarla por comodidad al migrar un
caso.

El razonamiento largo, y lo que se construye encima, está en `docs/sustrato.md` de la
implementación de referencia. No es normativo; esto sí.

**Una entidad servida desde varios objetos.** `03-binding` §2.1 lo admitía —*«una entidad PUEDE
tener varios bindings; cada uno cubre un subconjunto de sus propiedades»*— y aquí **no entra**.
Es la única cosa que v1alpha1 sabe decir y v1alpha8 no, así que conviene decir por qué.

Federar no es una decisión de modelado: es una de **operación**. Que `Employee.baseSalary` viva
en Workday y `Employee.alias` en un fichero no es un hecho sobre qué es un empleado — es un hecho
sobre cómo está montada una empresa hoy, y mañana no. Escribirlo en la capa física convertía esa
circunstancia en parte de la ontología, y la hacía invisible: el plan se abría en dos lecturas y
ningún documento decía que eso iba a pasar.

Y hay una razón más honda, que es la que Foundry y Cognite **sí** pueden saltarse.

Federar une por una clave que alguien **afirma** compartida. En sus arquitecturas esa afirmación
ya ocurrió aguas arriba: Cognite direcciona cada instancia por `space` + `externalId`, y ese
identificador lo pone quien ingiere; un objeto multi-fuente de Foundry une sus fuentes por la
clave primaria que la tubería dejó consistente. El modelo la da por hecha porque **hubo una
ingesta donde ocurrió**.

Aquí no hay ingesta, así que no hay ningún sitio donde haya ocurrido. Y **materializar no la
crea**: copiar filas no reconcilia identidades. Dos copias con una clave que colisiona siguen
siendo dos copias, y la afirmación *«estas dos filas son la misma cosa»* es exactamente la misma
antes y después de copiar.

Por eso no es del sustrato. Es de [`v1alpha2/03-resolution`](../v1alpha2/03-resolution.md), cuya
estrategia `deterministic` está descrita allí, literalmente, como **«un `join`»**, con su `match`
entre fuentes, su `normalize` y su conducto. El binding hacía eso mismo **sin declarar ninguna de
las tres cosas**: la resolución de identidad más difícil de los datos empresariales, escondida
dentro de un documento físico.

Y el día que haya un almacén propio —una copia en casa— reconciliar pasa a ser **posible**, y
sigue sin ser del sustrato: pasa a ser un **acto declarado**, con el documento que ya existe. Lo
que cambia entonces es quién responde de la reconciliación, no dónde se escribe.

Sin ella hay dos formas de decir lo mismo, y las dos son más honestas que la que se va:

- **dos entidades y una relación** por la clave que comparten. Son dos sistemas y dos registros;
  el modelo lo dice y el consumidor recorre. Nada se mueve;
- **una copia declarada**: se materializa lo que haga falta en un sitio y se registra como una
  `Table`. El coste se escribe donde se paga.

Lo que desaparece es que la ontología finja que son un solo objeto sin que nadie lo declare.

La consecuencia hay que vigilarla, y por eso esta exclusión **tiene un código**: quitada la
federación, una cobertura parcial deja de ser legal, porque ya no hay otro documento que cubra
el resto. Es `OOS2022`, en [`02-view` §5.3](02-view.md#53).

**`UNNEST`.** Un documento con un array no se aplana sin un operador que la gramática no tiene.
`columns` lo hace **visible** —dice qué hay, con el tipo que el origen le da— sin resolverlo.

**Nulos.** El límite real de lo semi-estructurado. La tabla lo enseña; no lo arregla.

**Escritura.** El puntero es de solo lectura, y `05-ejecutor` §6.2 ya lo era. Toda la industria
coincide en esto, y las excepciones recientes —escribir sobre Iceberg externo— son otra pieza,
con otro contrato.

**Quién ve qué.** Sigue siendo el `ConduitPolicy` y las políticas Cedar. Una tabla dice qué
existe; el conducto dice quién puede. Es lo que deja que una tabla gobernada siga siendo
componible.
