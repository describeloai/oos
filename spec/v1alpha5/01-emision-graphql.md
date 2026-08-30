# 01 · Emisión a GraphQL

**Estado:** borrador. Gobierna los documentos que declaran su `apiVersion`, y es **alpha**:
sin garantías de compatibilidad.

El porqué está en [`00-scope`](00-scope.md). Este documento fija **qué sale**: la superficie
normativa del mapeo, lo que la emisión ejecuta antes de escribir, cuándo se niega a emitir, y
—§6— **qué significa que esto esté listo**, en peldaños que se pueden medir por separado.

---

## 1. Qué se emite, y de qué

> **Un SDL por paquete. El bundle es la entrada; el paquete es la unidad de salida.**

La entrada es el bundle porque hacen falta piezas que no viven en un paquete: el techo de
`contextSurface`, las interfaces y conceptos importados, las máscaras que alcanzan a una
propiedad. La salida es por paquete porque **la frontera de paquete es la frontera de
subgrafo** ([`00-scope`](00-scope.md) §5.1), y porque resuelve el nombrado sin inventar nada:
dentro de un subgrafo, `hr.Employee` es `Employee`.

La emisión **DEBE** ser una función pura del bundle:

```
SDL(paquete) = f(bundle, paquete)
```

Sin red, sin reloj, sin principal. Es la misma invariante que el resto del compilador, y es
lo que hace que §6.3 sea comprobable.

---

## 2. El mapeo

### 2.1 · Tipos y nombres

| OOS | GraphQL |
|---|---|
| `kind: Entity` con `nature: entity` | `type <name>` |
| `kind: Entity` con `nature: event` | `type <name>` |
| `metadata.name` | el nombre del tipo, **literal** |
| `metadata.namespace` | el subgrafo; **no se prefija al nombre** |

Un nombre de OOS es `^[a-zA-Z][a-zA-Z0-9_]*$` y un nombre de GraphQL es
`/[_A-Za-z][_0-9A-Za-z]*/`. **El primero es subconjunto del segundo**, así que la traducción
de nombres es la identidad y no hay escapes que documentar. Que encaje sin ajustar es una de
las señales de que esto es una traducción y no un perfil.

`nature` **no** se emite. Es una distinción de modelado —qué exige clave y qué exige eje
temporal— y ya se comprobó al compilar; llevarla al SDL sería emitir el andamio.

### 2.2 · Escalares — y el defecto que esta versión destapa

**Hay dos vocabularios de escalares en el proyecto y no comparten un solo nombre.** Medido:

| Fuente | Vocabulario |
|---|---|
| `basic.schema.json` §`scalarType` — **normativo** | `string` · `integer` · `number` · `boolean` · `date` · `timestamp` · `bytes` |
| `ore-core/types.rs` — implementación de referencia | `String` · `Integer` · `Decimal` · `Float` · `Boolean` · `Date` · `Time` · `DateTime` · `DateTimeTz` · `Opaque` |
| Uso real | **375 `String`, 20 `Integer`, 3 `DateTime`… y cero de los siete del esquema** |

Cuatro difieren solo en la caja, **tres del esquema no existen en el motor** —`number`,
`timestamp`, `bytes`— y **seis del motor no están en el esquema** —`Decimal`, `Float`,
`Time`, `DateTime`, `DateTimeTz`, `Opaque`—.

Y valida igual, porque `scalarType` es un `oneOf` cuya última rama es `qualifiedName`:
**`String` pasa como «tipo importado de un paquete de tipos» llamado `String`.** Trescientas
setenta y cinco propiedades del repositorio se están validando por la puerta de escape.

> Es la regla de siempre: **un `$def` sin usuario no está esperando, está sin comprobar.**
> Aquí es peor — tiene 375 usuarios y **ninguno lo usa**.

Se destapa aquí y no antes por una razón que conviene dejar escrita: **esta es la primera
versión que necesita una tabla de tipos exacta.** ODCS y Ossie emiten el tipo como texto;
Cedar proyecta la forma sin mirar el escalar. GraphQL exige decir, para cada escalar, cuál es
su destino — y no se puede hacer sobre un vocabulario que no se sabe cuál es.

**Este documento no lo arregla:** el vocabulario de escalares es de v1alpha1 y unificarlo es
un cambio de esa versión, con su propio caso y su propia entrada en el registro. Lo que hace
es **nombrarlo y mapear el vocabulario que existe de verdad**, que es el del motor:

| OOS | GraphQL | |
|---|---|---|
| `String` | `String` | |
| `Integer` | `Int` | |
| `Float` | `Float` | |
| `Boolean` | `Boolean` | |
| `Decimal` | `scalar Decimal` | `Float` perdería precisión, y una cifra contable no se redondea al emitirla |
| `Date` · `Time` · `DateTime` · `DateTimeTz` | `scalar Date` · `Time` · `DateTime` · `DateTimeTz` | uno por cada uno: colapsarlos perdería si lleva zona |
| `Opaque` | `scalar Opaque` | |
| `list<T>` | `[T!]` | un solo nivel, como en OOS |
| `Money<M,P>` · `Quantity<U,P>` | §3.1 | |

Los escalares personalizados **DEBEN** emitirse con su declaración `scalar` en el mismo SDL.
Un esquema que referencia un escalar que no declara no es un esquema válido, y §6.1 lo
detectaría — pero es más barato no cometerlo.

### 2.3 · Propiedades y nulabilidad

Una propiedad emite un campo. La nulabilidad **DEBE** derivarse, no declararse:

| | GraphQL |
|---|---|
| propiedad en `primaryKey` | `ID!` |
| propiedad que un `Interface` exige | `T!` |
| cualquier otra | `T` |

**Todo lo demás es nulable**, y no por prudencia: OOS no tiene `required` en una propiedad, y
emitir `!` donde no hay obligación declarada sería inventar un valor — lo que §7.2-bis llama
*fingir*, en la dirección del consumidor.

### 2.4 · Relaciones

Una relación emite un campo cuyo tipo es la entidad destino. `cardinality` y `required`
**DEBEN** traducirse así:

| `cardinality` | `required: true` | `required: false` |
|---|---|---|
| `many_to_one` · `one_to_one` | `T!` | `T` |
| `one_to_many` · `many_to_many` | `[T!]!` | `[T!]` |

La correspondencia es exacta y no hay que decidir nada: **el par (cardinalidad, obligación)
de OOS y el par (lista, nulabilidad) de GraphQL tienen los mismos cuatro estados.**

El campo `via` **no** se emite: es el dato que sostiene la arista y ya está emitido como
propiedad. Emitir los dos sería declarar dos veces lo mismo — la distinción que v1alpha1
defiende (*«`managerId` es un DATO y `manager` es una ARISTA»*) se preserva porque **cada uno
sale por su lado**.

Si la entidad destino está en otro paquete, el campo **DEBE** emitirse igual y el tipo
**DEBE** marcarse como entidad externa del subgrafo. Es Federation haciendo su trabajo.

### 2.5 · Interfaces

| OOS | GraphQL |
|---|---|
| `kind: Interface` | `interface <name>` |
| `Interface.requires: [concepto]` | un campo por concepto, con el tipo del concepto |
| `Entity.implements: [I]` | `type E implements I` |

La subsunción de v1alpha4 es **estructural** y la de GraphQL es **nominal**, y por eso la
dirección importa: OOS computa qué entidades satisfacen una interfaz y **emite el
`implements` ya resuelto**. GraphQL no tiene que inferir nada, que es justo lo que no sabe
hacer.

### 2.6 · Claves

`primaryKey` y cada entrada de `uniqueKeys` emiten un `@key` de Federation. **Federation
admite varios `@key` por tipo**, así que la traducción es total:

```graphql
type Employee @key(fields: "employeeId") @key(fields: "nationalId") @key(fields: "email") {
```

Una clave compuesta emite sus campos separados por espacio, en **el orden declarado** —
`90-canonical-form` §N4 conserva secuencias y una clave compuesta es una secuencia.

### 2.7 · La raíz de consulta

Cada tipo emitido **DEBE** aportar dos campos a `Query`:

```graphql
type Query {
  employee(employeeId: ID!): Employee
  employees(first: Int, after: String): EmployeeConnection!
}
```

Uno por clave y uno por colección. **No se emite ningún campo de búsqueda libre ni de
filtrado arbitrario**: filtrar es consultar datos, y qué se puede consultar es del protocolo
de servicio, que está fuera de alcance. La raíz declara **por dónde se entra**, no qué se
puede preguntar.

### 2.8 · Mutaciones

Una `Function` emite una `Mutation` **si y solo si** cada propiedad que escribe está en el
contrato. Si una sola de ellas quedó fuera por el conducto, la mutación **no se emite**:
publicar una escritura sobre un campo que el consumidor no puede leer le pediría que confíe
en un efecto que no puede comprobar.

- `input` emite los argumentos, con `!` donde `required: true`.
- `output` emite un tipo de resultado propio, `<Nombre>Result`.
- Sin `output`, la mutación devuelve `Boolean!`. Un `Function` siempre escribe algo
  —`effects` es obligatorio— así que hay un hecho que devolver aunque no haya un valor.

`preconditions`, `authorization` e `idempotency` **NO** se emiten: son condiciones que el
motor comprueba, no forma que el cliente pueda pedir. Emitirlas sería publicar la cerradura
junto a la puerta.

#### 2.8.1 · El endoso no se emite: **se ejecuta al emitir**

Es la misma tesis de §4, en la otra dirección.

> Una `Function` con un endoso `humanApproval` **no puede devolver su `output`**. Devuelve
> `ApprovalRequired`.

Y no es política metida en el contrato: es **aritmética del tipo de retorno**. `01-efectos`
§3.2 fija que `humanApproval` es un endosante **dinámico** —*«el compilador verifica que la
declaración cubre la carencia; el motor verifica el acto»*—, así que en el instante de la
llamada **el acto no ha ocurrido**. No hay resultado que devolver, y tipar la respuesta como
si lo hubiera sería mentir en el contrato.

```graphql
type Mutation {
  recalculateTotals(orderId: ID!): RecalculateTotalsResult!
  refundOrder(orderId: ID!, amount: Money_EUR_2!): ApprovalRequired!
}

"La invocacion quedo propuesta y espera la firma que su endoso declara."
type ApprovalRequired {
  request: ID!
  endorsement: String!
}
```

**Y lo comprueba el sistema de tipos del cliente.** Quien esperaba `RefundResult` de
`refundOrder` no compila. Eso es `G2` en la dirección de escritura, y **es nuevo**: mientras
el endoso vivía solo dentro del artefacto, el consumidor no podía verlo.

> **Una escritura que exige firma humana no se puede consumir como si no la exigiera, porque
> el tipo no encaja.**

#### 2.8.2 · Un endoso condicional **sí** cambia el tipo

`02-function` §6.1 fija que un endoso con `when:` **no cierra** una carencia de integridad.
Aquí cuenta igual que uno incondicional, y la asimetría no es un descuido: **son dos
preguntas distintas sobre el mismo campo.**

| Pregunta | Quién la hace | Un `when:` |
|---|---|---|
| ¿basta este endoso para **escribir**? | la regla `I(f) ⊒ I(destino)` | **no cuenta** — una condición no es una garantía |
| ¿qué recibe **quien llama**? | el contrato | **cuenta** — puede activarse, y entonces no hay resultado |

La primera es sobre lo que la función *tiene*; la segunda, sobre lo que el consumidor *puede
esperar*. Un contrato que prometiera el resultado y devolviera una solicitud rompería a su
cliente en producción, así que la emisión promete lo menos de los dos.

### 2.9 · Documentación

`description` emite la cadena de documentación del tipo o del campo. `aiContext.synonyms` y
`aiContext.guidance` **DEBERÍAN** emitirse dentro de ella, delimitados, y **NO DEBEN**
emitirse como directivas: `aiContext` es *descriptivo, nunca directivo*, y una directiva es
una instrucción a la herramienta.

Y hereda las etiquetas de lo que lo contiene, así que **pasa por el filtro de §4 como
cualquier otra cosa**: un sinónimo puede ser confidencial.

---

## 3. Las decisiones que no tenían respuesta obvia

### 3.1 · `Money<EUR, 2>` — el escalar se especializa, no se aplana

GraphQL no tiene parámetros de tipo. Tres salidas, y la tercera es la buena:

| | Por qué no |
|---|---|
| `Float` | pierde la moneda **y** la precisión. Sumar euros y dólares dejaría de fallar: solo daría cifras incorrectas |
| `type Money { amount: Decimal!, currency: String! }` | convierte un escalar en un objeto, y entonces la moneda es **un dato que el cliente puede leer y elegir ignorar** |
| **`scalar Money_EUR_2`** | **un escalar por combinación**, emitido con su documentación |

La tercera conserva la propiedad que hace útil al tipo paramétrico: **la unidad es parte del
tipo, no un valor**. Dos campos con monedas distintas salen con escalares distintos, y ningún
cliente puede sumarlos por accidente porque el sistema de tipos no se lo permite. Es lo mismo
que hace OOS, dicho en el vocabulario del destino.

Igual para `Quantity<km, 1>` → `scalar Quantity_km_1`.

### 3.2 · `temporal.validTime` — un argumento, no un campo

Una entidad con `temporal.validTime` **DEBE** emitir sus campos raíz con un argumento
opcional:

```graphql
employee(employeeId: ID!, asOf: DateTime): Employee
```

No se emiten `validFrom` y `validTo` como campos. La razón es la de siempre: **son el
mecanismo, no el hecho.** Emitirlos obligaría a cada cliente a saber filtrar por ellos —y el
`aiContext` del ejemplo de referencia ya advierte de que se hace mal: *«para plantilla activa
hay que filtrar por `validTime`, no por la existencia del registro»*. Un argumento pone esa
competencia en el motor, que es donde ya estaba.

Sin `asOf`, la respuesta es el estado vigente. `transactionTime` **no** se emite: la pregunta
*«qué sabía el sistema el martes»* la contesta el digest, y esa es §3.3.

### 3.3 · El digest — en `extensions`, no en el esquema

Cada respuesta **DEBERÍA** llevar, en `extensions`, el digest del bundle del que salió:

```json
"extensions": { "oos": { "bundle": "sha256:…", "package": "hr@1.4.0" } }
```

`extensions` es el único lugar de la especificación de GraphQL para metadatos de respuesta
que no forman parte del dato. Las dos alternativas se descartan por la misma razón: un campo
`_meta` en cada tipo **contamina el modelo de dominio con el mecanismo**, y una cabecera HTTP
ata el contrato a un transporte.

Y el SDL **DEBE** llevar el digest en su documentación de esquema, de modo que **el contrato
diga de dónde salió aunque se lea suelto, sin motor**.

> Es `G1` puesto donde se usa: *«¿qué sabía el agente el martes a las 14:32?»* deja de
> responderse con un log y pasa a responderse con **el esquema que tenía delante**.

---

## 4. Lo que la emisión ejecuta antes de escribir

Este apartado **es** la tesis de la versión. La emisión **DEBE**, en este orden:

1. **Descartar lo que no está listo.** Una entidad o propiedad cuya `oos.maturity` esté por
   encima del techo de madurez de `contextSurface` **no se emite**.
2. **Descartar lo que no puede verse.** Una propiedad cuya clasificación efectiva exceda el
   techo de sensibilidad de `contextSurface` **no se emite**. *Efectiva* incluye lo heredado
   de la entidad, del `datasource` y del concepto.
3. **Aplicar las máscaras.** Una propiedad alcanzada por una máscara emite el **tipo de la
   máscara**, no el suyo: `mask(LAST4)` sobre un `String` emite `String`; una máscara que
   agrega emite el tipo del agregado.
4. **Podar lo que quedó vacío.** Un tipo sin campos no se emite, y una relación cuyo destino
   no se emitió **tampoco**.

El paso 4 no es limpieza: **es la parte que impide una fuga por la topología.** `DESIGN` §4.1
lo dice —*«saber que el paciente X está enlazado con la clínica oncológica Y es el
diagnóstico»*—, y una arista que apunta a un tipo que no se sirve revela que ese tipo existe
y con qué se relaciona.

**Ninguno de los cuatro pasos consulta quién pregunta.** `contextSurface` es un techo del
paquete, no del principal, y por eso la emisión sigue siendo pura.

---

## 5. Cuándo la emisión falla

`expects: emit-fails`, sin código de error propio, como Ossie:

| | Por qué |
|---|---|
| una entidad emitida **sin `Binding`** | sin resolver, el campo existe en el contrato y no se puede servir. Es la misma causa que `ossie-requires-binding` |
| el paquete **no declara `ConduitPolicy`** | sin techo no hay filtro, y emitir sin filtro sería emitir todo. **Denegación por defecto (P4)** |
| una clave compuesta nombra una propiedad **no emitida** | el `@key` referenciaría un campo ausente: el esquema sería inválido |

La tercera es la que conviene tener escrita: **una propiedad puede ser clave y estar
gobernada por encima del techo.** Cuando pasa, no se emite media clave — se rechaza la
emisión de ese tipo, porque un `@key` incompleto es una identidad falsa.

---

## 6. Listo — cuatro peldaños

No son fases de un plan: son **cuatro propiedades independientes**, cada una con un criterio
que se puede medir sin las otras. Y cada una es algo por lo que el ecosistema ya paga.

### 6.1 · Peldaño 1 · **existe**

> Un motor de GraphQL ajeno acepta el SDL **sin retocarlo**.

Criterio: el esquema emitido del ejemplo de referencia se analiza sin errores con al menos
una implementación que no sea la nuestra. Si hay que editarlo a mano, el mapeo describe algo
que no es GraphQL.

### 6.2 · Peldaño 2 · **es honesto**

> Dos bundles que difieren **solo** en su `ConduitPolicy` emiten esquemas distintos, y la
> diferencia es **exactamente** el conjunto gobernado.

Criterio: se baja el techo de `contextSurface` de `medium` a `low` y desaparecen del SDL
justo las propiedades cuya clasificación efectiva está entre los dos niveles. Ni una más —
sería una fuga de disponibilidad—; ni una menos — sería una fuga de datos.

Es el peldaño que certifica la tesis, y el único cuya ausencia haría el producto falso en vez
de incompleto.

### 6.3 · Peldaño 3 · **es identificable**

> El mismo bundle emite **el mismo SDL byte a byte**, y el SDL dice de qué digest salió.

Criterio: `G1` sobre la emisión. Dos ejecuciones, un solo hash. Exige orden determinista en
tipos, campos, `@key` y escalares — y la forma canónica ya fija cómo se ordena un conjunto,
así que no hay que inventar el criterio, solo aplicarlo.

### 6.4 · Peldaño 4 · **es versionable**

> `ore diff` clasifica un cambio del esquema emitido **con los códigos que ya existen**.

Criterio: retirar una propiedad servida se reporta como ruptura de `CONSUMER` sin añadir un
solo código. Si hiciera falta uno nuevo, es que la emisión introdujo un eje de cambio que el
artefacto no tenía — y eso sería un defecto del mapeo, no una carencia del registro.

> Este peldaño es el que convierte al compilador en algo que el ecosistema ya compra: los
> *schema checks* que un registro comercial cobra aparte **se derivan** de `ore diff`, sin
> registro y sin servicio, porque el contrato es función de un commit.

---

## 7. El horizonte

### 7.1 · Absorción del estándar

La emisión cubre hoy el núcleo de GraphQL. Lo que falta, y en qué orden se gana:

| | Qué exige | Estado |
|---|---|---|
| tipos · campos · interfaces · enums · claves · mutaciones | — | **entra en v1alpha5** |
| `union` | una noción de disyunción que OOS no tiene. Candidata: `nature` como discriminante | por decidir |
| tipos de entrada de mutación | `Function.input` ya los describe; es mapeo, no diseño | **entra en v1alpha5** |
| **quórum de endosos** | un conjunto no cuenta: dos `humanApproval` sin atestación colapsan en uno, así que **el control dual no es expresable**. Es la decisión abierta nº1 de [`v1alpha2/00-scope`](../v1alpha2/00-scope.md) §6 | por decidir |
| `subscription` | un modelo de cambio. Es lo mismo que bloquea `Test` y lo temporal: va después de L2 | aplazado |
| directivas de Federation v2 | `@shareable`, `@external`, `@provides`. Salen del grafo de dependencias entre paquetes | siguiente |

**Absorber el estándar no significa emitir todo lo que GraphQL admite.** Significa que
**nada de lo que OOS sabe se quede sin destino**, y que lo que GraphQL admite y OOS no modela
—uniones sin discriminante, campos con lógica arbitraria— **siga sin poder escribirse**. Un
objetivo de emisión que aceptara más que el origen dejaría de ser una traducción.

### 7.2 · Normalización del resto de componentes

Que exista la cuarta superficie **mejora a las otras tres**, y de forma concreta:

| | Deja de que se le pida | Vuelve a ser |
|---|---|---|
| **ODCS** | ser una forma consultable | el contrato: SLA, calidad, servidores, propiedad |
| **Ossie** | ser la vista del consumidor | el modelo analítico, que es su centro de gravedad |
| **Cedar** | crecer directivas por campo | una decisión booleana sobre un principal |

Y hay una normalización que no es de un objetivo sino del propio régimen de flujo, y es la
que más pesa. **`contextSurface` es el único conducto sin consumidor.** Medido: aparece en
cinco sitios de la especificación, los cuatro de v1alpha1 son definitorios, y **ningún caso
de conformidad lo ejercita**. Su definición, escrita en v1alpha1, dice literalmente:

> *`contextSurface` | superficie servida a consumidores (**MCP, GraphQL**, SDK) | qué puede
> ver un agente*

**El conducto nombró a GraphQL desde el primer día y nunca tuvo quien lo atravesara.** Un
conducto sin consumidor está en la misma posición que un `$def` sin usuario: declarado y sin
comprobar. Esta versión es su primer consumidor, y el peldaño §6.2 es su primera medición.

### 7.3 · Lo que esto desbloquea

**Un paquete, un subgrafo.** Una organización con cuarenta paquetes obtiene un supergrafo
federado cuyas fronteras son **fronteras de propiedad**, no de conveniencia técnica. Nadie
diseña eso: se sigue de que las dos particiones ya coincidían.

**El `discover` más barato que existe.** Inducir un paquete `DRAFT` desde un SDL ajeno
—[`00-scope`](00-scope.md) §7.4— sin credenciales, sin driver y sin red.

**Consultas persistidas como artefacto gobernado.** GraphQL permite registrar un conjunto
cerrado de consultas por su hash y admitir solo esas. Es **la misma forma que un bundle**: un
conjunto cerrado, un hash, comprobado antes de ejecutar. Compilar el conjunto de preguntas
que un agente puede hacer —cada una con su digest, ninguna improvisada— convierte *«qué puede
preguntar este agente»* en una pregunta con respuesta auditable. Es el complemento natural del **endoso** en la dirección de
lectura —uno acota qué se puede hacer, el otro qué se puede preguntar— y no exige nada que
GraphQL no tenga ya.

**Las herramientas del agente se derivan.** Un servidor MCP sobre un esquema emitido no
diseña herramientas: las obtiene por introspección. La lista de lo que un agente puede hacer
pasa a ser **función del artefacto**, con todo lo que eso arrastra — digest, `diff`,
promoción y revisión.
