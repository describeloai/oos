# 01 · Leer el origen

**Estado:** normativo. Parte de OOS v1alpha24.

## 1. Qué es leer el origen

**Leer en vivo** una `Table` es pedirle filas a su origen en el momento en que alguien pregunta,
sin una copia por medio: una consulta que la nombra, una vista virtual cuya raíz de lectura es
ella, una función que la lee. Lo que llega se usa y no queda: no es una materialización.

Una lectura en vivo es **un fragmento de plan**: un objeto, las columnas que se piden, los
predicados conjuntivos sobre ellas, un orden y un límite. Lo que el origen no hace lo hace el motor
de quien pregunta, sobre lo que llega.

## 2. El conducto `federation.read`

Esta versión añade una clase a las de [`v1alpha1/04` §4](../v1alpha1/04-flow.md#4-conductos):

| Conducto | Aparece en | Ejemplo de autorización |
|---|---|---|
| `federation` | la lectura en vivo de un origen | qué puede leerse de un origen sin copiarlo |

```yaml
kind: ConduitPolicy
spec:
  owner: team:datos
  conduits:
    federation.read:          { sensitivity: medium, maturity: REVIEWED }
    contextSurface.workspace: { sensitivity: medium, maturity: REVIEWED }
```

**Normativo.**

- Toda lectura en vivo de una `Table` **ES** un flujo hacia `federation.read`, se declare o no.
  Sin autorización ese conducto es `⊥` (P4) y la lectura **NO DEBE** hacerse: `OOS4011`.
- Lo que fluye por él son **las columnas pedidas**, y sólo ellas: la proyección es estructural
  ([`v1alpha8/01` §6](../v1alpha8/01-table.md#6-restricciones), `projectionPushdown`). Si la
  etiqueta efectiva de una columna pedida excede la autorización, la lectura **NO DEBE** hacerse:
  `OOS4002`, o `OOS4001` si la etiqueta es computada. Las columnas que la tabla tiene y no se piden
  no cuentan.
- Las columnas que un predicado nombra **cuentan como pedidas**: un predicado empujado revela al
  origen algo de quien pregunta, y uno que se evalúa en el motor necesita la columna.
- Si lo leído va a otra superficie —un entorno de trabajo, un agente— atraviesa además su conducto
  (`contextSurface.<instancia>`), con su autorización. Las dos se aplican; ninguna afloja a la
  otra ([`v1alpha1/04` §4.1](../v1alpha1/04-flow.md#41--combinacion-de-varias-politicas)).

> **Por qué una clase propia y no `materialization`.** Copiar y leer en vivo dejan cosas distintas:
> una copia **queda** —sellada con su clasificación, servida después a quien la pida— y una
> lectura en vivo **se usa y no queda**. Un mismo origen puede poder leerse en vivo para explorar
> y no poder copiarse, o al revés: son dos decisiones y necesitan dos autorizaciones.

## 3. Lo que se empuja

Dos partes dicen qué puede hacer el origen, y **mandan las dos**:

- **la tabla** (`reads`): lo que quien la declaró admite que se le pida — su política;
- **el conector** de su familia: lo que sabe expresar en el lenguaje del origen.

**Normativo.**

- Un predicado se empuja al origen sólo si su operador está en `reads.predicatePushdown` **y** el
  conector lo sabe expresar. Lo que no, lo **DEBE** evaluar el motor sobre lo que llega; **NO DEBE**
  descartarse. Una lectura que devuelve más filas de las pedidas sin decirlo es el fallo que esta
  regla existe para impedir.
- El vocabulario de operadores sigue cerrado (`eq`, `neq`, `in`, `range`, `like`, `isNull`,
  `fullText`). Un conector que no conoce un operador no lo inventa: no lo declara.
- `maxRowsPerRequest`, cuando está, es lo más que se pide al origen **por petición**: una lectura
  que necesita más se parte en varias, y el resultado es el mismo.
- Un límite (`LIMIT n`) se empuja sólo si nada de lo que queda en el motor puede quitar filas
  antes de él: un predicado que no se empujó, una junta, un agregado. Empujarlo por debajo de un
  filtro que se evalúa después devuelve menos filas de las pedidas.

## 4. El coste que la tabla declara, aplicado

`fullScan` y `requiredFilters` existen desde v1alpha8 para que **el planificador rechace un plan
antes de abrir una conexión**. Esta versión dice cuándo.

**Normativo.** Al planificar una lectura en vivo de una `Table`:

| la tabla declara | qué pasa al leerla en vivo | código |
|---|---|---|
| `fullScan: forbidden` | **NO DEBE** leerse si ningún predicado empujado acota la lectura | `OOS2044` |
| `requiredFilters: [c, …]` | **NO DEBE** leerse si falta un predicado `eq` o `in` **empujado** sobre cada `c` | `OOS2045` |
| `fullScan: expensive` | se lee, **con presupuesto** (abajo) | — |
| `fullScan: cheap` (o sin declarar) | se lee | — |

Las dos primeras son **lo que el dueño de la tabla exige**, y por eso son errores: es el
`require_partition_filter` de BigQuery y el `always_filter` de Looker. `expensive` no exige nada a
quien pregunta: dice que recorrerla **cuesta** —dinero, tiempo o carga sobre el origen—, y lo que
la industria hace con lo caro es **un presupuesto, no una regla de sintaxis** (el
`maximum_bytes_billed` de BigQuery, el límite de datos escaneados de un *workgroup* de Athena,
`query.max-scan-physical-bytes` de Trino). Exigir un `LIMIT` tampoco protegería al origen: en
BigQuery un `LIMIT` sobre SQL no reduce lo que se lee ni lo que se cobra.

**Normativo**, para `fullScan: expensive`:

- Una implementación **DEBE** aplicar a la lectura en vivo de una tabla `expensive` un
  **presupuesto de lectura** —filas o bytes que se piden al origen, y tiempo— y **DEBE** cortarla,
  diciendo por qué, si lo supera. Cuánto es el presupuesto es de la implementación.
- Si el origen permite estimar antes de leer (el *dry run* de BigQuery, el `EXPLAIN` de un SQL),
  la implementación **DEBERÍA** estimar y no empezar una lectura que lo superaría.
- La implementación **DEBERÍA** avisar de que una lectura recorre la tabla entera.

- Lo que cuenta es lo **empujado**: un filtro que se evalúa en el motor no protege al origen, que
  ya devolvió todo.
- Una vista no cambia esto: si se lee una vista virtual, lo que importa es lo que llega a la tabla
  de su raíz, juntando los predicados de la vista y los de quien la lee.
- El código se emite **al planificar**, antes de conectar. Una implementación **DEBERÍA** decir
  qué filtro falta, sobre qué columna, y cómo leerla (con un filtro, con un límite, o desde una
  copia).
- Un **trabajo que copia** (una materialización) lee la tabla entera por definición y no es una
  lectura en vivo: estas reglas no le aplican. `fullScan: forbidden` sobre una copia ya tiene su
  respuesta en el testigo y el rango.

## 5. Las vistas sobre una `Table`

Una vista virtual cuya raíz de lectura es una `Table` es una lectura en vivo cada vez que alguien
la lee.

**Normativo.**

- Una `View` de v1alpha24 o posterior cuya raíz de lectura sea una `Table` **DEBE** tener
  `federation.read` autorizado en el árbol para compilar: `OOS4011`. Aunque un dataset la copie,
  la vista sigue pudiéndose leer en vivo, y compilar no sabe quién la leerá. Las columnas
  de su contrato que vienen de la tabla son las que fluyen por él (`OOS4002`, `OOS4001`).
- Una vista de una versión anterior **sigue compilando**: leerla en vivo pide el conducto al leer,
  con el mismo código.
- La regla de `OOS2020` no cambia: una tabla con `reads: none` no responde, y una vista virtual
  sobre ella no se puede leer en vivo.

## 6. Errores

| Código | Condición |
|---|---|
| `OOS2044` | lectura en vivo de una tabla `fullScan: forbidden` sin un predicado empujado que la acote |
| `OOS2045` | lectura en vivo de una tabla sin un predicado `eq`/`in` empujado sobre cada columna de `requiredFilters` |
| `OOS4011` | (existente) `federation.read` sin autorización: la lectura en vivo, o una vista de v1alpha24 sobre una `Table` |
| `OOS4002` / `OOS4001` | (existentes) una columna pedida —o nombrada por un predicado— con una etiqueta por encima de lo autorizado |
