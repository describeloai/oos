# 02 · View — la vista, adelgazada

**Estado:** borrador. Parte de OOS v1alpha8.
**Sustituye a** [`v1alpha7/01-view`](../v1alpha7/01-view.md), que sigue describiendo los
documentos v1alpha7 y sigue siendo válido para ellos.

---

## 1. Qué cambia, y qué no

Lo que [`v1alpha7/01-view`](../v1alpha7/01-view.md) dice de la **naturaleza** de una vista sigue
valiendo entero: no lleva significado, no decide quién ve, no es un motor, compone, y su copia
lleva lo que llevan sus campos. Nada de eso se repite aquí. *Sigue sin llevar significado, y por
eso `oos.maturity` cabe: no es significado del dato, es el estado del documento — §4.1.*

Lo que cambia es **dónde vive lo físico**:

| | v1alpha7 | v1alpha8 |
|---|---|---|
| `from` | `{datasource, object}` o `{view}` | **`{table}`** o `{view}` |
| `capabilities` | en la vista | **fuera**: es `reads` de la tabla |
| `version` | en la vista | **fuera**: es `changes.witness` de la tabla |
| `fields` | forma breve o `{column, physicalType}` | **solo la breve**: `physicalType` era lo único que la expandida añadía, y ahora lo dice la columna de la tabla |
| `labels` | prohibidas | **`oos.maturity`, y solo esa** — §4.1 |
| `owner`, `where`, `materialized`, `freshness` | en la vista | igual |

La vista queda con **lo que es suyo**: quién responde, qué sale y cómo se llama, qué filas son
suyas, si se copia y dónde, y cuánto retraso se tolera. Todo lo demás era del objeto.

---

## 2. Forma

```yaml
apiVersion: oos.dev/v1alpha8
kind: View
metadata:
  name: empleados
  namespace: hr
spec:
  owner: team:rrhh
  from: { table: erp.employees }     # o { view: … }
  freshness: 15m
  fields:
    employeeId: employee_id          # cada valor DEBE ser una columna de la tabla
    nationalId: national_id
    pais: country
  where:
    deleted: "false"                 # cada clave DEBE ser una columna de la tabla
```

Una vista **sobre otra**, igual que antes:

```yaml
kind: View
metadata: { name: iberia, namespace: hr }
spec:
  owner: team:rrhh
  from: { view: empleados }
  fields:
    id: employeeId
    dni: nationalId
  where:
    pais: [ES, PT]
  materialized:
    datasource: lago
    table: "cache.hr_iberia"
```

Una vista que **agrupa**, que es lo que v1alpha8 añade al vocabulario:

```yaml
kind: View
metadata: { name: ventas_por_pais, namespace: ventas }
spec:
  owner: team:ventas
  from: { table: erp.orders }
  fields:
    pais: country                    # una columna, y DEBE estar en groupBy
    n: "count()"                     # un agregado: el paréntesis lo distingue
    total: "sum(amount)"
  groupBy: [country]
  having:
    n: ">= 8"                        # el comparador va delante, siempre
```

Una vista **sobre un stream** — una tabla con `reads: none`. Sin `materialized` no compila:

```yaml
kind: View
metadata: { name: pedidos, namespace: ventas }
spec:
  owner: team:ventas
  from: { table: bus.orders }
  fields: { id: order_id, cliente: customer_id, total: total }
  materialized: { datasource: lago, table: "cache.pedidos" }
  freshness: 1m
```

---

## 3. La raíz, y la raíz de lectura

Son dos, y la diferencia es el asunto de `OOS2020`.

**La raíz** de una vista es a dónde se llega bajando por `from` hasta que deja de haber `view`:
siempre una **tabla**. De ella salen el `datasource` —para heredar etiquetas, `v1alpha7/01-view`
§5.1—, el objeto, y ahora también las **columnas reales** contra las que se comprueba `fields`.

**La raíz de lectura** es la vista `materialized` más cercana bajando por la cadena, o la tabla
si no hay ninguna. Es de donde salen de verdad las filas cuando alguien consulta.

Una vista virtual sobre una vista materializada sobre un stream **sí** compila: su raíz es una
tabla que no se deja leer, pero su **raíz de lectura** es la copia, y la copia se lee.

Esa operación —bajar la cadena— es **una**, y la usan el enlazado para comprobar que resuelve,
el flujo para heredar la ubicación, y el ejecutor para leer. Si fueran tres copias, divergirían
en el eslabón que ninguna prueba ejerce.

---

## 4. Restricciones

Las de [`v1alpha7/01-view` §4](../v1alpha7/01-view.md#4-restricciones) siguen, con `from.table`
donde decía `from.datasource`:

- `from` es **exactamente una** de dos formas: `{table}` o `{view}`. Una sola fuente, porque el
  vocabulario no tiene junta.
- `from.table` **DEBE** resolver a una tabla del paquete o de una dependencia — `OOS2018`.
- `from.view` y `backedBy` **DEBEN** resolver a una vista — `OOS2018`. Los dos admiten la forma
  corta en el mismo espacio de nombres y se normalizan al nombre cualificado.
- Con `from: {table}`, **cada valor de `fields` y cada clave de `where` DEBE ser una columna de
  `columns` de esa tabla** — `OOS2018`. Es lo que v1alpha7 no podía comprobar.
- Con `from: {view}`, cada valor de `fields` y cada clave de `where` **DEBE** ser un campo que la
  de abajo expone — `OOS2018`, sin cambios.
- `materialized.datasource` **DEBE** estar declarado en el manifiesto raíz — `OOS2004`.
- La cadena **NO DEBE** volver sobre sí misma — `OOS2019`.
- La vista que respalda una entidad **DEBE** exponer su `primaryKey` y los `via` de sus
  relaciones — `OOS2011`.
- Y **DEBE** exponer un campo por cada propiedad de esa entidad que no declare `derivedFrom` —
  `OOS2022`, §5.3.
- La vista admite `labels` en `metadata`, y **la única clave admitida es `oos.maturity`** —
  cualquier otra es una clave desconocida, `OOS1005`. Es §4.1.
- La vista admite `moved` y `reserved` sobre **sus campos**, y un campo **NO DEBE** reutilizar un
  nombre reservado — `OOS2006`. Es §4.2.

Y cambian tres:

- desaparece la de `version.witness: field`, que ahora es de la tabla;
- `fields` pierde la forma expandida. Cada valor es **una cadena**: el nombre en la fuente. La
  expandida existía para llevar `physicalType`, y el tipo físico es del objeto — lo dice
  `columns`. Un documento v1alpha7 con la forma expandida migra tirando el tipo a la tabla, que
  es donde ya debía estar.
- y la vista deja de tener **prohibidas** las `labels`: pasa a admitir exactamente una — §4.1. Un
  documento que no las escriba no cambia de significado, así que la migración no roza.

### 4.1 · `oos.maturity`, y solo `oos.maturity`

> La vista **PUEDE** declarar `metadata.labels`, y la **única** clave admitida es `oos.maturity`.
> Cualquier otra es una clave desconocida — `OOS1005`.

La prohibición anterior era correcta en su sujeto y demasiado ancha en su alcance. Lo que protege
es esto:

> *«Si la vista pudiera declararlas habría dos sitios diciendo qué es una columna, y el día que
> discrepen ninguno diría cuál manda.»*

Y eso es un argumento sobre **el dato**. `oos.maturity` no dice nada de una columna: dice si esta
pregunta está acordada. Son dos sujetos, y la especificación ya los distingue en otro documento —
`metadata.labels` clasifica **el documento**; las de dentro de una propiedad, **el dato**.

**El precedente es `Concept`, y llegó por el mismo camino.** A `Concept` se le negaron las
etiquetas por miedo a esta misma duplicación, y se le devolvieron al ver que un concepto acuñado
por inferencia tiene que poder declararse `DRAFT` — es `OOS9003`. La vista está en esa situación
exacta desde que existe el descubrimiento: **`ore discover` propone vistas, y hasta aquí no podía
marcarlas.** Una vista adivinada de un catálogo y una que una organización acordó preguntarse eran
el mismo documento.

Tres consecuencias, y las tres son de la unidad, no del dato:

- **una pregunta se puede retirar.** `DEPRECATED` es un nivel de `oos.maturity`, y sin esta clave
  la unidad del paquete era lo único que no se podía deprecar;
- **el defecto no se escribe.** Como en la entidad, una vista que no declara nada toma lo que su
  paquete diga en `status`. En el corpus eso son 55 de 56 vistas sin escribir una línea;
- **no abre la puerta a otro retículo.** La restricción es de clave única y su incumplimiento es
  `OOS1005`, el mismo código con el que la prohibición se hacía cumplir antes. No hay código nuevo.

Lo que esta versión **no** decide es si la etiqueta de una vista **fluye** —si `oos.maturity:
DRAFT` sobre una vista clasifica lo que sale de ella, como ya hace la de una entidad—. Se dice
aquí para que no se suponga: hoy no fluye, y `OOS4002` no la ve.

Y **la tabla no la admite**, ni siquiera esta. Una tabla es un hecho del origen —`01-table` §1:
*«ninguna de las cuatro cosas es una conjetura»*— y los cuatro niveles de `oos.maturity` son
verbos de acuerdo. Nadie acuerda un hecho. Lo que le puede pasar a una tabla es dejar de ser
cierta, y eso es otro eje.

### 4.2 · `moved` y `reserved` — un nombre de campo que se retira

```yaml
spec:
  fields: { id: employee_id }
  moved:
    - { from: employeeId, to: id, since: 2.0.0 }
  reserved:
    - { name: dni, reason: se retiró con el nationalId de la tabla }
```

> La vista **PUEDE** declarar `moved` y `reserved` sobre **sus campos**. Reutilizar un nombre
> reservado es `OOS2006`; retirar un campo anunciado **no** es `OOS5001`.

**Es el alcance estrecho de una sola disciplina, y la casa la elige una sola regla:**

> ### Lo dice el que sobrevive. Si no sobrevive nadie, lo dice el paquete.

Renombrar una propiedad deja viva a la entidad, y por eso `moved` vive ahí desde v1alpha1.
Renombrar un campo deja viva a la vista. Renombrar un **documento** no deja vivo a nadie con ese
nombre, y por eso el alcance ancho está en el manifiesto —
[`01-package` §3.4](../v1alpha1/01-package.md).

No es una convención: **se deriva**, y explica de paso por qué `Entity.spec.moved` estaba bien
donde estaba. No era media importación por descuido — era la casa correcta **para su alcance**.

#### Lo que NO comprueba, y es deliberado

Ni que `moved.from` haya dejado de existir, ni que `moved.to` exista. **Es exactamente el rigor
que ya tenía la entidad**, medido: el enlazado solo comprueba `OOS2006`, y `moved` únicamente
alimenta a `ore diff`. Subirlo aquí cambiaría la regla de la entidad de paso, y eso es otra
decisión.

#### Y la tabla no

Las columnas de una tabla no las renombra nadie de aquí: **las renombra el origen**, y eso no se
anuncia — se **detecta**. Es la misma asimetría que con `oos.maturity`: la vista **decide** su
nombre, la tabla lo **espeja**. (Su *documento* sí entra, y por el manifiesto, porque el nombre de
una `Table` lo elegimos nosotros.)

---

## 5. Las reglas nuevas

Tres. Las dos primeras eran, hasta aquí, prosa en la documentación de quien las sufrió; la
tercera no existía porque hasta aquí no hacía falta. Las tres son compilación.

### 5.1 · `OOS2020` — lo que no se puede leer se debe materializar

> Una vista cuya **raíz de lectura** es una tabla con `reads: none` **DEBE** llevar
> `materialized`.

Una tabla con `reads: none` no responde consultas: solo emite cambios. Una vista virtual sobre
ella promete algo que nadie puede servir — y lo promete **en tiempo de compilación**, para
fallar en tiempo de consulta.

Databricks lo descubre cuando `readStream` no existe sobre una *foreign table*. Aquí no compila.

La regla mira la **raíz de lectura**, no la raíz: si un eslabón intermedio ya materializó, hay
de dónde leer, y la vista de arriba puede ser virtual sin mentir.

### 5.2 · `OOS2021` — sin retractación no se mantiene lo mutable

> Una vista `materialized` cuya raíz tiene `changes.mode: append` **NO PUEDE** respaldar una
> entidad con `nature: entity`.

Una entidad es una cosa que **cambia y sigue siendo la misma**: se corrige, se actualiza, se da
de baja. Mantener su estado presente exige poder **quitar** lo que dejó de ser cierto, y un
flujo que solo sabe anexar no puede. Lo que se obtiene copiando un `append` no es el estado
presente: es el histórico de lo que llegó, con las filas viejas dentro.

Un `nature: event` **sí** se respalda de un `append`, y es su forma natural: un hecho ocurrido
no se retira, y por eso solo hace falta anexar.

Foundry documenta esta misma limitación —el soporte incremental está limitado a cambios de solo
anexado— como una nota en su documentación. **Es el peor modo de fallo de todo el motor**: no
produce ningún síntoma. La vista se materializa, la consulta responde, los números salen, y son
los de antes. Convertirlo en un código es la diferencia entre un compilador y un manual.

### 5.3 · `OOS2022` — una propiedad sin campo no tiene de dónde salir

> Cada propiedad de una entidad **DEBE** ser un campo de la vista que la respalda, salvo que
> declare `derivedFrom`.

Esta regla es **la otra cara de una exclusión**, y solo se entiende junto a ella.

`03-binding` §2.1 admitía que *«una entidad PUEDE tener varios bindings; cada uno cubre un
subconjunto de sus propiedades»*. Con eso, una cobertura parcial no solo era legal: era **el
mecanismo**. Preguntar *«¿de dónde sale esta propiedad?»* no tenía respuesta local, porque la
respuesta podía estar en otro documento.

[`00-scope` §6](00-scope.md#6-lo-que-no-entra) retira esa posibilidad: una entidad sale de **una**
vista. Y en cuanto no hay otro documento donde mirar, la pregunta vuelve a tener respuesta local
— y una propiedad sin campo pasa de *«la cubre otro»* a *«no la cubre nadie»*.

Sin esta regla, la migración que esta versión pide produciría exactamente el fallo que este
proyecto persigue: se escribe una vista con la mitad de los campos, la entidad sigue declarando
el doble, **compila en verde**, y las propiedades huérfanas responden vacío para siempre.

**`derivedFrom` es la excepción, y es la única.** Una propiedad derivada declara de qué otras
propiedades sale, y eso *es* su origen: pedirle además una columna sería exigirle que esté
calculada en la fuente. Es justo lo que la migración de `Binding.properties.<x>.expression` deja
de poder hacer ([`00-scope` §5.3](00-scope.md#53)), así que negarle el hueco sería cerrar la
única salida que le queda.

### 5.4 · `OOS2023` — fechar por columna sin clave no se mantiene

> Una vista con `materialized` cuya raíz de lectura declare `changes: { mode: append, witness:
> field }` **NO DEBE** compilar.

Las otras tres reglas de esta versión salen del álgebra o de una exclusión. Esta sale de una
propiedad de los ordinales, y es la única que se puede enunciar sin mirar el modelo:

> **`witness: field` no es un orden total: una columna puede tener empates.**

Y ahí está todo. Refrescar una copia significa pedir *«lo que hay después de `T`»*, y con empates
en `T` no hay forma buena de escribirlo:

| se pide | qué pasa |
|---|---|
| `columna > T` | las filas que comparten `T` y llegaron después **se pierden, para siempre** |
| `columna >= T` | el borde **se re-entrega** en cada refresco |

`snapshot` y `log` no tienen ese problema: nombran una **posición de confirmación**, que es un
orden total sin empates. Retomar desde una posición es exacto.

Con `upsert` o `retract` tampoco lo hay, aunque el testigo sea una columna: hay **clave**, así que
re-entregar el borde es idempotente. Se pide `>=`, llegan repetidas, y la clave las absorbe.

Queda una sola combinación sin salida, y es la que la regla rechaza: **`append` y `field`**. No
hay clave que absorba la re-entrega, y la alternativa es perder filas en silencio.

**Es una regla sobre la copia, no sobre la tabla.** Un registro de eventos fechado por una columna
de tiempo es legítimo, frecuente y a veces lo único que el origen sabe ofrecer. Lo que no se puede
es **mantener una copia suya**: quien la quiera, que declare una clave o que fije un testigo
posicional.

**Y no es teoría.** Es el modo que la industria llama *cursor field*, y su documentación lo dice
con estas palabras: la entrega es **at-least-once** —*«the cursor field will always be greater
than or equal to itself»*— y además se pueden **perder** filas si la columna no se mantiene al
modificar una. El fallo no da ningún síntoma: la copia responde, los números salen, y son de más
o de menos.

### 5.5 · `OOS2025` — lo que se escribe se debe materializar

El gemelo exacto de [§5.1](#51--oos2020--lo-que-no-se-puede-leer-se-debe-materializar), y por eso
comparte su forma: una condición sobre la vista, comprobada **al compilar**, sin abrir nada.

> **Una vista por la que la ontología escribe DEBE declarar `materialized`.** Una vista virtual no
> tiene dónde sostener una edición.

«Por la que la ontología escribe» es derivable y no se declara: existe una `Function` con un
`effect` sobre una propiedad de una entidad que se respalda de esta vista. El mismo camino que
recorre la lectura.

Y con él va su compañera: **esa vista necesita saber qué fila toca un edit**, así que la tabla de
su raíz **DEBE** declarar `changes.key` — `OOS2024`. Las dos condiciones tienen remedios distintos
—una se arregla en la vista, la otra en la tabla— y por eso son dos códigos y no uno.

#### Lo que esta pareja decide, y es lo que más se nota

Que una vista sea **espejo** o **registro** no es una propiedad del producto: se decide **por
vista**, y el compilador dice cuál es cuál.

| la vista | qué es |
|---|---|
| sin escrituras desde la ontología | **un espejo** — puede quedarse virtual, y cada lectura va al origen |
| con escrituras | **un registro** — se materializa, y la copia es el estado |

Las dos clases conviven en el mismo paquete. **Ser un registro íntegro no impide ser un buen
espejo**, mientras no haya ediciones; y en cuanto las hay, hay materialización.

### 5.6 · `OOS7013` — la invertibilidad, que es de otro producto

Una vista es una pregunta. Escribir **a través** de ella es deshacer la pregunta: dada la fila que
se quiere ver, averiguar qué fila del objeto la produce. Y no toda pregunta se deshace.

| lo que hace la vista | ¿se deshace? | por qué |
|---|---|---|
| renombrar | **sí** | es una biyección |
| recortar —`where`— | **sí** | la fila escrita cumple el predicado, o se cae de la vista |
| proyectar —`fields`— | **sí, parcialmente** | faltan columnas, así que la escritura es *parcial*; no es ambigua |
| juntar, agregar, deduplicar, limitar | **no** | de una agregación no se vuelve |

> **Reservado, y no comprobado en esta versión.** Escribir desde la ontología aterriza en la copia
> —§5.5— y la copia guarda **el vocabulario de la vista**, así que un edit cae *dentro* de `Q` y no
> hay nada que invertir. Esta regla es la primera del producto que escribe **de vuelta en los
> sistemas de origen**, que es otro y no está aquí.
>
> Se deja escrita y con código propio porque el análisis vale y la máquina existe; el precedente es
> `OOS2001`, que v1alpha1 reservó sin poder alcanzarlo.

Un efecto cuya entidad se respalde de una vista **no invertible** no podría llevarse hasta el
origen. Se miraría **la cadena entera** y no solo la vista que `backedBy` nombra: componer no
diluye, y si un eslabón de abajo agrega, lo que sale de arriba tampoco se deshace.

#### Y hasta `groupBy` esta regla no podía fallar

Se decía porque callarlo habría sido peor. **El vocabulario de la vista era exactamente el
fragmento invertible** —`owner`, `from`, `freshness`, `fields`, `where`, `materialized`— y eso no
se buscó: [`00-scope`](00-scope.md) §6.1 cuenta que se descubrió al migrar. No había junta, ni
agregado, ni `distinct`, ni límite.

**`groupBy` lo rompe, y a propósito** — [§5.8](#58--la-agrupación--oos2032-y-oos2033). Un documento
conforme puede ya escribir una vista que no se deshace, y por eso la guarda deja de ser una
puerta cerrada por falta de llaves y pasa a tener tres respuestas y no dos:

| | cuándo |
|---|---|
| `NoSeDeshace` | la clave está clasificada y su respuesta es no — hoy, `groupBy` |
| `CampoCalculado` | el campo no sale de una columna: sale de un conjunto de filas |
| `ConstruccionDesconocida` | **el defecto**, para lo que nadie clasificó |

Que la tercera siga siendo el defecto es lo único que no cambia: una clave nueva que nadie mire
niega la escritura en vez de heredar un «sí».

`OOS7013` **sigue reservado**, y no por falta de sujetos: por lo de arriba —escribir aterriza en la
copia—. Lo que se acabó es la coartada de que ningún documento pudiera violarlo.

Y hay una corroboración que salió del propio repositorio, sin buscarla. Lo **único** que la
migración del binding perdió —[`00-scope`](00-scope.md) §5.5— fue `properties.<x>.expression`, un
cálculo físico al modo de `DATEDIFF(...)`, *«que no cabe en `fields`, que solo renombra»*. Lo único
que se cayó es exactamente lo único que habría roto la invertibilidad.

No es una corroboración de andar por casa: es **la misma frontera que SQL trazó**. Las condiciones
de PostgreSQL para que una vista sea auto-actualizable —una sola entrada en el `FROM`, sin
`GROUP BY`, `HAVING`, `DISTINCT`, `LIMIT`, `OFFSET` ni operaciones de conjunto— son, término a
término, lo que la vista de aquí **no puede escribir**. Y `information_schema.views.is_updatable`
es literalmente esta pregunta, estandarizada.

> **Entonces, ¿para qué está la regla?** Para que el día que la gramática crezca, el constructor
> nuevo tenga que **decidir** si se invierte, en vez de heredar un «sí» que nadie escribió. Una
> implementación conforme clasifica cada clave del vocabulario, y lo que no clasifique **no es
> invertible**: el defecto es la negativa, como en todo lo demás de esta especificación.

### 5.7 · Lo que las cuatro tienen en común

Las dos primeras son la regla de la versión leída al revés:

Las dos primeras son la regla de la versión leída al revés:

> `Table = I(changes)` — sin `I` no hay lectura, y sin `-1` no hay `I` de una cosa que cambia.

Y las dos son comprobables **solo** desde que la tabla declara sus dos caras. Ese es el precio
que paga esta versión, y lo que compra.

La tercera no sale del álgebra: sale de haber **quitado** algo. Las reglas que aparecen al retirar
una pieza son las que más fácil se olvidan, porque no las pide nadie — las pide la ausencia.

Y la cuarta sale de mirar la **pareja**. `mode` y `witness` se declaran por separado porque son
preguntas independientes —qué llega, y qué lo fecha— pero la garantía de entrega no la decide
ninguna de las dos: la deciden **las dos juntas**. Tres de las cuatro combinaciones se mantienen;
la que no, no da ningún aviso.

---

### 5.8 · La agrupación — `OOS2032` y `OOS2033`

Una vista agrupa declarando `groupBy`, y agrega escribiendo una llamada como valor de un campo.
No hay una clave aparte para los agregados: **la salida de una vista es una sola lista de
columnas**, y repartirla en dos mapas obligaría a juntarlos para saber qué sale, dejaría a `moved`
y `reserved` sin decir a cuál alcanzan, y admitiría que los dos reclamasen el mismo nombre.

El vocabulario de agregados es **cerrado** —`count` · `sum` · `min` · `max` · `avg`— por lo mismo
que `changes.mode`: si un documento pudiera inventar una función, el motor no sabría qué estado
hace falta por grupo para mantenerla. Y el discriminante es el paréntesis de cierre, que no es una
heurística: un nombre de columna no lleva paréntesis. Una llamada mal escrita **no se degrada a
columna** — es un error de forma, no un `OOS2018` disfrazado de *«la tabla no tiene esa columna»*.

`count(<col>)` se niega: en SQL cuenta los no nulos, este motor no distingue, y admitirlo daría
otro número sin decirlo.

> **`OOS2032`** — con `groupBy`, toda columna que `fields` proyecte y no agregue DEBE estar
> agrupada.

Es la regla de SQL y por su misma razón: en un grupo, una columna que no agrupa tiene varios
valores, y elegir uno sería inventárselo.

> **`OOS2033`** — un agregado DEBE ir con `groupBy`.

Y esta **no** es la regla de SQL, que admite `SELECT count(*) FROM t`. Se midió: el linaje de un
agregado global sale **vacío** —no viene de ninguna columna raíz— así que la regla de flujo no
tiene nada que comprobar y el número de filas se publicaría sin gobierno. Con `groupBy`, el mismo
agregado gana una arista **INDIRECT** por cada clave, que es la que ve el flujo implícito.

| lo que se escribe | linaje de la salida | ¿se mantiene? |
|---|---|---|
| `groupBy` sin agregados | `IDENTITY` — es un `SELECT DISTINCT` | sí |
| `count()` | `GROUP_BY` | sí |
| `sum(c)` · `min(c)` · `max(c)` | `GROUP_BY` + `AGGREGATION` | sí |
| `avg(c)` | `GROUP_BY` + `AGGREGATION` | **no**, y dice por qué |

La última fila es la que conviene leer despacio: `avg` **no se incrementaliza**, y el motor lo dice
en vez de mantenerlo mal. Un promedio no se actualiza con un acumulador —hace falta la suma y la
cuenta por separado— y esa es una decisión de quien escribe la vista, no una reescritura que
ocurra a sus espaldas.

#### `having` — `OOS2034`, y el umbral que faltaba dónde escribir

> **`having` recorta por lo que sólo se sabe después de agrupar, y su sujeto DEBE ser un campo
> agregado de la misma vista.**

Nombrar una clave de grupo no está prohibido por gusto: ese predicado es un `where`, y un `where`
**baja al origen** mientras que un `having` no puede — se aplica encima del grupo. Escribirlo en el
sitio equivocado no da otro resultado: da el mismo, más caro, y en silencio.

El comparador va delante y no se sobreentiende —`n: ">= 8"`, no `n: 8`—, y el vocabulario es
cerrado: `>=` `<=` `!=` `==` `>` `<`.

**Aquí hay rangos y en [`where`](#2-forma) no**, y no es una incoherencia. El `where` recorta por
una **columna**, y un rango sobre una columna clasificada ordena en vez de particionar: ahí empieza
la fuga, y por eso su gramática es igualdad, pertenencia y ausencia —la misma del `selector` del
binding, `01-binding` §3.5—. `having` recorta por un **agregado**, y entonces el rango es justo lo
que hace falta. Lo que el agregado lea sigue gobernado: el linaje deja una arista `INDIRECT` desde
la clave de grupo, así que un `having` sobre `sum(salary)` arrastra la etiqueta de `salary` igual
que la arrastraba la suma.

Y de ahí sale lo que este constructor cierra de verdad. `OOS4007` exige un `minGroupSize` al
desclasificador `aggregate` desde v1alpha3 — *«agregar quita la etiqueta **si el grupo es bastante
grande**»* — y hasta ahora ese umbral sólo podía vivir en una política y comprobarse en ejecución.
`having: { n: ">= 8" }` es el mismo umbral **dentro del plan**: la diferencia entre una promesa y
una consulta. Sin él, `groupBy: [pais, enfermedad]` con `count()` puede devolver grupos de uno, que
no son una estadística sino una reidentificación.

Cambiarlo son los **mismos dos códigos que el recorte** —`OOS5028` al estrechar, `OOS5029` al
ensanchar— con el sujeto cambiado, porque es la misma regla sobre otra cosa. Y ensanchar aquí
tiene nombre propio: **bajar un umbral de k-anonimidad** no puede salir en `patch`. Cuando la
dirección no se puede demostrar —se quita la condición, cambia el operador, el valor no es un
número— se afirman **las dos**: no poder probar que un cambio es seguro no es lo mismo que poder
probar que lo es.

#### Una entidad puede salir de una vista que agrupa

Y una de sus propiedades puede salir de un agregado: `ConteoPais.n` es el `count()` de su vista, y
la clave de la entidad es la clave del grupo — una fila por grupo, que es lo que la identifica.

Lo que **no** cambia es la regla de flujo, y conviene decir por dónde pasa:

> **La etiqueta de una columna sobrevive a agregarla.** La suma de un sueldo clasificado sigue
> clasificada mientras nadie desclasifique.

El linaje ya lo dice —`AGGREGATION` es una arista **DIRECT**, no una frontera— y de ahí sale el
diagnóstico entero: una copia de `sum(salary)` en un conducto que solo admite `low` no compila, y
el motivo nombra la derivación y la columna, no el campo.

Desclasificar agregando es exactamente lo que el desclasificador `aggregate` de
[`04-flow`](../v1alpha1/04-flow.md) existe para decir, y **exige un `minGroupSize`** (`OOS4007`):
un grupo de uno no es una estadística, es una reidentificación.

Y el tipo baja por el mismo camino, con una restricción: `sum`, `min` y `max` devuelven el tipo de
lo que agregan, así que declarar la propiedad tipa la columna. `count` y `avg` **no** — uno cuenta
filas y el otro devuelve `Decimal` sobre una entrada que puede no serlo, y de la salida no se
deduce la entrada.

#### Y cambiar la agrupación rompe — `OOS5033`

> Cambiar el conjunto de claves de `groupBy` es un cambio **CONSUMER breaking**.

Se midió antes de escribirlo, y el resultado fue el equivocado: añadir una clave salía
*compatible · patch*. No lo es. Refinar la agrupación parte cada grupo, así que un `count()` que
valía 400 pasa a valer 250 y 150 — **ningún campo aparece ni desaparece**, y todo consumidor que
leyera esa columna recibe otra respuesta.

Por eso `OOS5033` no se parte en *estrecha* y *ensancha* como el recorte
—[`91-versioning`](../v1alpha1/91-versioning.md) §5.1, `OOS5028` y `OOS5029`—: allí las dos
direcciones tienen consecuencias distintas, una rompe al lector y la otra a la política. Aquí las
dos rompen lo mismo, porque lo que cambia no es qué filas salen sino **qué pregunta se contesta**.

---

## 6. La copia, sin cambios

`materialized` instancia el conducto `materialization.payload`, y lleva lo que llevan sus campos:
lo que el datasource raíz etiqueta, y lo que **cualquier entidad cuya cadena pase por esta
vista** declaró sobre ellos. Es
[`v1alpha7/01-view` §5.2](../v1alpha7/01-view.md#52--la-copia-lleva-lo-que-llevan-sus-campos)
entero, y sigue siendo `OOS4001`, `OOS4002` y `OOS4011`.

Que no cambie es la afirmación: la tabla movió el puntero de sitio, no la regla de flujo.
