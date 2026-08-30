# OOS v1alpha5 — alcance

**Estado:** borrador de alcance. Gobierna los documentos que declaran su `apiVersion`, y es
**alpha**: sin garantías de compatibilidad.

| | |
|---|---|
| `00-scope` | **este documento** — qué entra, qué no, y por qué GraphQL |
| [`01-emision-graphql`](01-emision-graphql.md) | la superficie normativa del mapeo, y **qué significa que esto esté listo** (§6) |

Esta versión **no añade ningún `kind`**, ningún esquema y ningún código de error. Añade **un
objetivo de emisión** y los casos que lo certifican. Es la versión de menor radio de impacto
del proyecto, y eso no es casualidad: la emisión es aditiva por construcción — nada de lo ya
escrito cambia de significado porque exista un destino más.

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

La regla se lee: **la superficie emitida contiene exactamente lo que el conducto admite.**
Ni una propiedad más. Y de ahí sale la frase que decide el diseño entero:

> **La clasificación no se emite. Se ejecuta al emitir.**

Un campo cuya etiqueta excede el techo de `contextSurface` **no sale prohibido: sale
ausente.** El consumidor no puede pedir lo que el contrato no declara, y por tanto no hay
nada que aplicar en el momento de la petición — ya se aplicó al compilar.

Es `G2` en la superficie de consumo. Donde v1alpha1 dice *«si compila, ningún dato
clasificado alcanza un conducto no autorizado»*, esta versión dice **lo mismo mirando desde
fuera**: si el esquema compiló, no contiene un campo que no debiera servirse.

---

## 2. El hueco que ya estaba documentado, y que nadie había nombrado

`00-overview` §7.2-bis degradó a Apache Ossie de anfitrión a objetivo de emisión, y dio la
razón exacta:

> *«El centro de gravedad de Ossie está en la analítica sobre un almacén; el de `Entity`, en
> el dominio. Conformar relajando los campos obligatorios del anfitrión no es perfilar: **es
> fingir**.»*

El diagnóstico era correcto. Lo que no se siguió es la consecuencia: **al quitarle a Ossie un
trabajo que no era suyo, ese trabajo se quedó sin dueño.** La pregunta *«¿qué puedo pedir, y
con qué forma?»* no la contesta ningún objetivo de emisión de v1alpha1 a v1alpha4, y sin
embargo es la que hace un consumidor cada vez que abre una conexión.

### 2.1 · No son cuatro formatos: son cuatro preguntas

| Objetivo | Qué pregunta contesta | Quién pregunta | Cuándo |
|---|---|---|---|
| **ODCS** | ¿cuál es el contrato de este dato? | otro equipo de datos | antes de consumir |
| **Ossie** | ¿cuál es el modelo analítico? | Snowflake · dbt · Cube · Sigma | al modelar |
| **Cedar** | ¿puede este principal, ahora? | el motor | en cada petición |
| **GraphQL** | **¿qué puedo pedir, y con qué forma?** | **una aplicación o un agente** | en cada petición |

Ninguno de los tres primeros fue diseñado para contestar la cuarta. Mientras no existiera la
cuarta columna, esa pregunta **se le empujaba a los otros**, que es exactamente el modo de
fallo que §7.2-bis llama *fingir*.

### 2.2 · Cedar y GraphQL son dos mitades del mismo instante

Los dos son objetivos de **runtime**, y son estrictamente complementarios:

```
GraphQL  →  QUÉ FORMA se puede pedir       un contrato tipado, sin principal
Cedar    →  SI ESTE PRINCIPAL, AHORA        una decisión, sin forma
```

Ninguno puede hacer el trabajo del otro: un esquema GraphQL no tiene dónde alojar un
principal, y Cedar es booleano y no tiene forma. **Que estén separados no es una limitación:
es la razón por la que ninguno de los dos necesita deformarse.**

Y explica una diferencia con las herramientas del ecosistema que conviene tener escrita: los
productos de GraphQL gobernado necesitan directivas de autorización **porque están obligando
a GraphQL a contestar la pregunta de Cedar**. Aquí no hace falta, porque Cedar ya se emite.
GraphQL puede ser solo un contrato, que es lo único en lo que es bueno.

---

## 3. Anfitrión u objetivo: el test ya estaba escrito

§7.2-bis fija el criterio y no hay que inventar otro:

> **¿Puede el documento expresarse como documento válido del anfitrión sin inventar valores?**

Aplicado a GraphQL: una `Entity` sola **no es un esquema GraphQL válido**. Falta la raíz de
consulta, faltan los resolvers —que viven en el `Binding`— y falta el techo de
`contextSurface` para saber qué campos existen. Es **la misma razón** por la que Ossie es
objetivo y no anfitrión: *«su `Dataset` exige `source` y cada `Field` exige `expression`:
ambos viven en el `Binding`»*.

**GraphQL es objetivo de emisión del bundle.** No es anfitrión, así que no hay perfil que
mantener, ni obligación de que todo lo de OOS sea expresable en GraphQL. Y se emite del
**bundle entero** —entidades de v1alpha1, conceptos e interfaces de v1alpha4, conductos de
v1alpha1, funciones de v1alpha2, máscaras de v1alpha3—, que es precisamente lo que permite
que la política vaya en la forma.

Consecuencia para §7.2-bis: la tabla gana una fila. **Es el único texto ya escrito que esta
versión toca.**

---

## 4. Lo que hay que añadir es un documento, y ningún `kind`

| | |
|---|---|
| **se crea** | `spec/v1alpha5/` · `conformance/v1alpha5/emit/` |
| **no se toca** | los ocho documentos de v1alpha1 salvo una fila de §7.2-bis · **ningún esquema** · los 146 casos existentes · la forma canónica · el digest · el registro de errores |

Que no haga falta **ni un código nuevo** no es una economía: es una consecuencia del molde.
La suite ya distingue tres expectativas de emisión, y las tres sirven aquí sin cambios:

```yaml
expects: structure     # se afirman propiedades estructurales del SDL, no su texto
expects: emit-fails    # una emisión imposible falla; no necesita diagnóstico propio
expects: roundtrip     # NO se usa aquí — ver §7
```

---

## 5. Qué mapea, medido

La comprobación se hizo contra `hr.Employee` del ejemplo de referencia, no sobre el papel:

| OOS | GraphQL | |
|---|---|---|
| `Entity` | `type` | ✓ |
| `properties` con `type` | campos tipados | ✓ |
| `relations` · `cardinality` · `required` | nulabilidad y listas | ✓ **exacto** |
| `Interface` + `implements` | `interface` | ✓ mismo nombre, casi misma semántica |
| `enum` | `enum` | ✓ |
| `primaryKey` · `uniqueKeys` | `@key` de Federation, **que admite varios** | ✓ |
| `description` · `aiContext` | docstrings | ✓ |
| `Binding.properties` | resolvers | ✓ |
| `Function` con `effects` | `Mutation` | ✓ |

No es una analogía: es una traducción, y de fidelidad **mayor que la de ODCS o la del esquema
de Cedar**. La separación que v1alpha1 defiende —*«`managerId` es un DATO y `manager` es una
ARISTA»*— **es** la distinción entre campo escalar y campo objeto de GraphQL. Dos diseños
llegaron a la misma frontera por caminos distintos, que es la clase de coincidencia que
justifica un objetivo de emisión y no un perfil.

### 5.1 · Y hay una coincidencia estructural que nadie planeó

Federation particiona un esquema en **subgrafos**, cada uno con su `@key`. OOS particiona una
ontología en **paquetes**, cada uno con su dueño, su versión y su digest. La frontera de
paquete **es** la frontera de subgrafo, y las claves ya están declaradas.

---

## 6. Lo que **no** mapea, y por qué es exactamente el punto

| No mapea | |
|---|---|
| `Money<EUR, 2>` | escalar paramétrico; GraphQL no tiene parámetros de tipo |
| `temporal.validTime` | no existe la noción |
| `derivedFrom` | procedencia, no forma |
| **las etiquetas de clasificación** | **no tienen sitio en el sistema de tipos** |

Los tres primeros son decisiones de mapeo y viven en `01-emision-graphql`. **El cuarto no es
una carencia: es la tesis.**

Que la clasificación no quepa en el SDL es lo que obliga a que se **ejecute** al emitir en
vez de viajar. `nationalId` es `critical`; si `contextSurface` admite hasta `medium`, ese
campo no está en el esquema. Un consumidor no puede pedirlo, un agente no puede alucinarlo, y
una pasarela no puede olvidarse de filtrarlo — **no hay nada que filtrar.**

> Lo que no cabe en la traducción es justo lo que no debe viajar.

---

## 7. Una sola dirección — pero no la que parecía

La regla que este documento iba a fijar era *«una emisión con pérdida no tiene importador»*,
y **la refuta una sección que ya estaba escrita**. `02-entity` §9.3 permite importar Ossie
—que pierde exactamente lo mismo que GraphQL: la clasificación no existe en él— y la
seguridad no viene de prohibir el importador:

> *«Los datasets se convierten en entidades en `DRAFT` […] Sin etiquetas de origen, las
> propiedades quedan sin etiquetar y **el paquete NO compila hasta que se decidan** —
> denegación por defecto (P4). Si falta `primary_key`, **NO DEBE** inventarse.»*

Y v1alpha4 §7 ya lo había anticipado en voz alta: la propiedad que el molde debe satisfacer
la tendría que cumplir *«cualquier inductor, **incluida una importación desde una herramienta
ajena**»*.

### 7.1 · La regla correcta se deduce de §7.2-bis

La distinción anfitrión/objetivo, que ya existe, decide también qué es importar:

> **Del anfitrión se importa invirtiendo. Del objetivo de emisión se importa induciendo.**

| | Posición | Importar es | Qué produce |
|---|---|---|---|
| **ODCS** | anfitrión | **invertir** | el paquete, sin pérdida (§4.3) |
| **Ossie** | objetivo | **inducir** | entidades en `DRAFT`, sin etiquetar (§9.3) |
| **GraphQL** | objetivo | **inducir** | entidades en `DRAFT`, sin etiquetar |

La regla se sostiene en las dos instancias que ya existen y no la contradice ninguna. No es
vocabulario nuevo: es la consecuencia de §7.2-bis que nadie había sacado.

### 7.2 · Que no haya ida y vuelta es un teorema, no una política

Para GraphQL, `roundtrip` no es indeseable: **es imposible**, y se demuestra con un
contraejemplo de una línea.

> Un bundle donde `nationalId` es `critical` y el conducto admite hasta `medium`, y otro
> bundle donde `nationalId` **no existe**, emiten **el mismo SDL**.

La emisión no es inyectiva, luego no tiene inversa. **El SDL no puede distinguir un campo
ausente porque está gobernado de un campo que nunca existió** — y esa indistinguibilidad es
justo lo que hace segura la emisión. Por eso `expects: roundtrip` no aparece en esta versión,
y no por decisión: por aritmética.

### 7.3 · Y lo que de verdad impide modelar para la superficie

No es la ausencia de importador —quien quiera puede escribir OOS a mano copiando un esquema—.
Es que **la promoción exige resolver la clasificación**, y la superficie no la tiene ni la
tendrá nunca. Un paquete inducido desde un SDL entra en `DRAFT` con cero etiquetas, no
compila por denegación por defecto (P4), y `OOS9003` impide promoverlo mientras quede una
conjetura sin resolver.

La barandilla ya estaba puesta. Prohibir el importador habría sido poner una segunda, más
tosca, en el sitio equivocado.

### 7.4 · Lo que esto abre, y es la mejor vía de adopción que hay

Importar un SDL es **el `discover` más barato que existe**: no necesita credenciales, ni
driver, ni red. Lee un artefacto que el cliente ya tiene —su esquema de GraphQL escrito a
mano, que es su modelo de dominio de facto— y devuelve, en segundos, un paquete en `DRAFT`
con la lista de lo que le falta para estar gobernado.

Esa lista *«estas cuarenta propiedades no tienen clasificación»* **es la propuesta de valor
del proyecto entregada en los primeros cinco minutos**, sin conectar nada.

---

## 8. Lo que NO entra

**Un esquema por clase de principal.** Ninguna emisión actual toma parámetros: `--format
odcs` es función pura del paquete. Emitir un SDL distinto por rol metería un parámetro en la
emisión y rompería la forma de los cuatro precedentes. Y no hace falta para la tesis:
**`contextSurface` es un conducto, y un conducto es un techo que no depende de quién
pregunta.** Lo que sí depende del principal se decide en runtime, que es donde ya vive Cedar.
Queda anotado como decisión posterior y separable.

**Servir GraphQL.** Emitir el contrato es de esta especificación; servirlo es un protocolo de
servicio, y `00-overview` §1 lo pone fuera de alcance junto con el lenguaje de consulta. La
distinción se mantiene: OOS dice qué tiene que cumplir lo servido, no cómo se sirve.

**Suscripciones.** `subscription` exige un modelo de cambio que OOS no tiene.

**Unificar el vocabulario de escalares.** Escribir la tabla de tipos de
[`01-emision-graphql`](01-emision-graphql.md) §2.2 destapó que **hay dos vocabularios y no
comparten un solo nombre**: `basic.schema.json` declara siete en minúscula —`string`,
`integer`, `number`, `boolean`, `date`, `timestamp`, `bytes`— y el motor acepta diez
capitalizados —`String`, `Integer`, `Decimal`, `Float`, `Boolean`, `Date`, `Time`,
`DateTime`, `DateTimeTz`, `Opaque`—. **Las 375 propiedades del repositorio usan el segundo**,
y validan solo porque la última rama del `oneOf` es `qualifiedName` y se las traga como
«tipo importado». Se destapa aquí porque **esta es la primera versión que necesita una tabla
de tipos exacta**; arreglarlo es un cambio de v1alpha1, con su caso y su entrada en el
registro, y no cabe en esta pieza sin dejar de estar acotada.

**Fijar el modelo de fichero.** Escribir
[`orphan-relation-is-pruned`](../../conformance/v1alpha5/emit/orphan-relation-is-pruned) con
dos `Binding` separados por `---` destapó que **un fichero con varios documentos YAML pierde
todo menos el primero, en silencio**: el segundo no existía para el compilador y
`ore validate` decía *ok · sin errores* aunque apuntara a un `datasourceRef` inexistente. La
especificación **no dice nada** sobre varios documentos por fichero, y **ninguno de los 146
casos usa `---`**, así que nada lo habría descubierto. El caso quedó partido en dos ficheros;
decidir si un documento por fichero es normativo —y hacerlo cumplir— es de v1alpha1.

**El importador — aplazado, no prohibido.** §7 fija su regla: se importa **induciendo**, en
`DRAFT` y sin etiquetas. Lo que no entra aquí es su implementación y sus casos, porque la
suite no tiene hoy una expectativa para una importación sola —`roundtrip` no sirve, y §7.2
demuestra por qué— y añadirla duplicaría esta pieza. La regla queda escrita ahora, como
`01-package` §4.2 escribió la importación de ODCS antes de que nada la implementara.

**La superficie de escritura completa.** `Function` mapea a `Mutation`, pero una mutación que
exige firma humana no cabe en petición/respuesta, y el vocabulario que lo gobernaría
—`autonomy`— **no existe**: se nombra en `00-overview` §7.2 como uno de los siete
diferenciadores de OOS y no aparece en ningún esquema. Esta versión emite las mutaciones que
hoy son expresables y deja dicho que la otra mitad depende de un vocabulario que falta.

---

## 9. La prueba de fuego

La misma clase de comprobación que decidió v1alpha4, y por la misma razón — *el diseño se
decide con contacto, no con analogía*:

> **Un esquema emitido tiene que ser servible por un motor de GraphQL ajeno, sin
> modificarlo.**

Si el SDL que sale necesita ser retocado a mano para que Apollo, Strawberry o gqlgen lo
acepten, el mapeo está mal y es mejor saberlo antes de escribir los casos que después.

Y tiene una segunda mitad, que sale gratis desde §7.4:

> **Un esquema ajeno tiene que poder entrar y decir qué le falta.**

Tomar un SDL escrito a mano —el modelo de dominio de facto de cualquier equipo con una API de
GraphQL— e inducir de él un paquete en `DRAFT` cuya lista de decisiones pendientes sea
*legible*. Si esa lista no le dice nada útil a un arquitecto, el mapeo describe la sintaxis y
no el significado, y eso también es mejor saberlo antes.
