# `Ruleset` — la regla que apunta

**Estado:** alcance cerrado, primera versión. Gobierna los documentos que declaran su `apiVersion`, y **sigue siendo alpha**: sin garantías de compatibilidad.
Aplica el régimen de [`01-gobierno`](01-gobierno.md).

---

## 1. Naturaleza

El único documento nuevo de v1alpha3, y reúne las reglas **sin sujeto** —aserciones,
máscaras de materialización, ámbitos de fila y deberes— sobre un objetivo común, con un
dueño.

*«Sin sujeto»* quiere decir que **ningún principal aparece en el documento**, no que las
reglas no dependan de quién pregunta: una máscara con sujeto (§4.1) y un ámbito de fila
(§4.2) los nombra una política de Cedar, y el sujeto lo pone la petición. La definición
—qué se enmascara, qué columna recorta— sigue viviendo en un solo sitio, con dueño.

Lo que lo hace un documento y no un bloque dentro de `Entity` no es su sintaxis:

> **Un paquete de reglas es un sujeto de autoridad.** Sus reglas se agrupan porque responde
> la misma persona por todas y entran y salen juntas.

Y de ahí sale todo lo demás. Un `Ruleset` tiene `owner` propio, versión propia y digest
propio porque **tiene que poder vivir en otro repositorio, con otros revisores y otra
cadencia** que la ontología a la que apunta. En un banco o en un ministerio, el responsable
de cumplimiento tiene que poder restringir el modelo sin poder editarlo; con reglas locales
eso es estructuralmente imposible, porque son el mismo fichero.

```yaml
apiVersion: oos.dev/v1alpha3
kind: Ruleset
metadata: { name: gdpr-minimization, namespace: eu }
spec:
  owner: team:compliance
  targets:
    - atLeast: { gdpr.sensitivity: high }
  assertions:
    - { id: no-nulls, metric: nullValues, mustBe: 0, dimension: completeness }
  masks:
    - { declassifier: tokenize, to: { gdpr.sensitivity: low } }
```

---

## 2. La forma exacta de un objetivo

Es lo que esta versión aporta, y por tanto donde hay que ser exacto.

### 2.1 · Es estructura, no una cadena

La primera redacción de [`01-gobierno`](01-gobierno.md) escribía el objetivo como texto —
`labelled: "gdpr.sensitivity >= high"`—. **Es incorrecto**, y por tres razones que se apilan:

| | |
|---|---|
| **P3** | una cadena es un mini-lenguaje, y un mini-lenguaje exige un analizador. **P3** prohíbe el cómputo arbitrario en un documento que gobierna, y esta es la clase de documento a la que P3 apunta |
| **la forma canónica** | `"gdpr.sensitivity >= high"` y `"gdpr.sensitivity>=high"` son bytes distintos con el mismo significado. **Dos digests para una ontología**, que es exactamente el fallo silencioso que N1–N8 existen para impedir |
| **el diff** | `OOS5xxx` clasifica un cambio por ejes —`CONSUMER`, `POLICY`…—. Sobre una cadena opaca, subir el objetivo de `high` a `critical` y reformatear el espacio en blanco son **el mismo cambio**. La familia de versionado deja de funcionar |

La tercera es la decisiva y no es una preferencia estética: **un objetivo en texto rompe una
familia de códigos que ya existe.**

### 2.2 · La gramática

```yaml
targets:
  - atLeast: { gdpr.sensitivity: high }
  - atLeast: { acme.residency: eu_only, gdpr.sensitivity: medium }
  - named:   [hr.Employee.baseSalary]
```

| | Semántica |
|---|---|
| dentro de un `atLeast` | **Y** — la propiedad debe satisfacer todas las entradas |
| entre elementos de la lista | **O** — la unión de las selecciones |

Dos formas de nombrar el dominio, y **un solo sitio donde escribirlo**: `atLeast` lo
**computa**, `named` lo **escribe**. Un elemento declara una u otra, nunca las dos.

Es deliberadamente la semántica de `matchLabels` de Kubernetes, cuyo comportamiento está
documentado y es conocido: *«todos los requisitos se combinan con Y — deben satisfacerse
todos para casar»*. Se toma la semántica y **no** el resto del selector: `matchExpressions`
existe para etiquetas sin orden, y las nuestras lo tienen.

**Normativo.**

- `targets` es una **lista no vacía**. Cada elemento **DEBE** declarar `atLeast` con al
  menos una entrada **o** `named` con al menos un nombre — exactamente uno de los dos.
- Cada nombre de `named` **DEBE** ser el nombre cualificado de una propiedad existente; si
  no, `OOS2005`, que ya cubre este caso.
- Cada clave de `atLeast` **DEBE** ser el nombre cualificado de un `Lattice` declarado; si
  no, `OOS4003`, que ya cubre este caso.
- Cada valor **DEBE** ser uno de los niveles de ese retículo; si no, `OOS4003`.
- `targets` es un **conjunto**: N4 lo ordena. El orden no significa nada porque la unión es
  conmutativa — y eso lo separa de `Resolution.strategies`, que **sí** es una secuencia
  porque reordenarla cambia qué se fusiona.

### 2.2-bis · Por qué `named` es admisible, y por qué antes no lo era

La primera redacción **prohibía** los objetivos por nombre —*«dos formas de escribir lo mismo
acaban con dos semánticas»*— y con ello obligaba a que el caso enumerado viviera en otro
sitio: `quality` colgando de la propiedad. **La prohibición era autodestructiva**: movía el
problema en vez de resolverlo, y producía exactamente las dos formas que quería evitar.

Lo que la desmonta es una pieza que se escribió después:

> **`OOS8001` vuelve segura la enumeración.**

Enumerar se pudre porque una propiedad nueva se escapa **en silencio**. Con la regla de
cobertura, una propiedad clasificada que ningún objetivo alcanza **rompe la compilación**. La
enumeración deja de ser peligrosa porque el silencio deja de ser posible — y era el silencio,
no la enumeración, lo que hacía daño.

Y lo que se gana al admitirla es lo que se perdía sin ella: **un solo sitio, un solo modelo
de dueño**. Una regla sobre una propiedad y una regla sobre cuatrocientas se escriben en el
mismo tipo de documento, con `owner`, versión y digest propios, y el equipo que clasifica un
dato no puede descargarse a sí mismo la exigencia que le impuso un paquete importado.

> Lo que la propiedad **es** va en la propiedad. Lo que alguien **exige** de ella va donde
> está quien lo exige.

### 2.3 · Un solo operador de orden, y por qué

`atLeast` es el único, y no es una limitación de la primera versión: es una consecuencia.

> **El gobierno es monótono.** Si una regla se aplica a `high`, tiene que aplicarse a
> `critical`. Una regla que **deja** de aplicarse cuando el dato es más sensible es un
> defecto, no una funcionalidad.

Eso descarta `exactly` y `atMost` en un retículo de confidencialidad: los dos permiten
escribir una regla que exime a lo más grave, y ninguno tiene un caso de uso que no sea un
error. Un operador que solo sirve para equivocarse no se añade —**P7**.

Se nombra la relación en lugar de dejarla implícita, y eso sí es una decisión discutible que
conviene justificar. La forma `{ retículo: nivel }` **ya significa dos cosas opuestas** en el
árbol:

| Dónde | `{ gdpr.sensitivity: high }` significa |
|---|---|
| `metadata.labels` | *esto **es** high* — una asignación |
| `ConduitPolicy.conduits.<c>` | *hasta high* — un **techo** |
| `Ruleset.targets[].atLeast` | *high **o por encima*** — un **suelo** |

Un techo y un suelo con la misma forma, distinguidos solo por en qué documento estás, es una
trampa. Una palabra la elimina.

Y `atLeast` es además el que se emite: se corresponde con `odrl:gteq` del vocabulario de
operadores de ODRL, que es la lengua franca de los espacios de datos europeos
([`01-gobierno`](01-gobierno.md) §9).

### 2.4 · Qué selecciona

**Propiedades.** No entidades, y no hace falta ninguna regla nueva para que las etiquetas de
entidad funcionen: `02-entity` §4.1 ya dice que *«una etiqueta declarada en la entidad la
heredan todas sus propiedades»*, y que una propiedad **PUEDE** elevarla y **NO DEBE**
rebajarla (`OOS4012`).

Así que una entidad clasificada `eu_only` entera queda seleccionada por sus propiedades, sin
que este documento tenga que hablar de herencia. La decisión abierta 3 de
[`00-scope`](00-scope.md) queda cerrada así: **no era una decisión, era una comprobación.**

### 2.5 · Dónde se evalúa: el **workspace**, no el paquete

> Un objetivo se evalúa **sobre el workspace que se compila**, no sobre el paquete que lo
> declara.

La primera redacción decía *«sobre el paquete que se compila»*, y **era imprecisa en la
dirección que importa**: lo que se compila es el árbol entero. El manifiesto raíz lo declara
—`workspace: { members, exclude }`, con `members: [packages/*]` por defecto— y esa es la
unidad. Un `Ruleset` en el workspace gobierna **a todos sus miembros**.

No es una capacidad nueva: **era ya el comportamiento, sin escribir.** Se mide quitando el
único `Ruleset` de la ontología de referencia, cuyo espacio de nombres es `eu` y que vive en
la raíz — y lo que se rompe es una propiedad de **otro paquete**, que no lo importa:

```
error[OOS8001]: `customers.Customer.email` exige `constraint` y no lo tiene
```

### 2.5.1 · Dos formas de quedar sujeto, y no son la misma

| | **Importado** | **Local al workspace** |
|---|---|---|
| De dónde viene | una dependencia | `rulesets/` del repositorio |
| Quién decide | **el gobernado**, escribiendo la línea | **el gobernante**, poniendo el fichero |
| Alcance | el paquete que importa | **todos los miembros** |
| Quitarlo | borrar la dependencia | borrar el fichero |

Las dos son legítimas y responden a cosas distintas. La importada es la que invierte la
relación de dependencia —**se importa para quedar sujeto a ella**, y manda lo importado—; la
local es la que permite gobernar sin pedir permiso a cada paquete.

| | Una dependencia de código | Un `Ruleset` |
|---|---|---|
| Se importa para | **usarla** | **quedar sujeto a ella** |
| Manda | quien importa | **lo importado** |

Y en los dos casos vale lo mismo, que es la propiedad que hace esto auditable: **quitarlo no
es gratis ni silencioso.** Una propiedad que pierde una clase de gobierno es un cambio
rompedor computado —`OOS5023`— y no una línea que desaparece de un fichero sin que nadie lo
note. El gobernado **puede** salirse; lo que no puede es hacerlo callando.

### 2.5.2 · Hasta el borde del workspace, y ni un paso más

[`01-gobierno`](01-gobierno.md) §3 lo decía como *«sobre el paquete y sus dependientes»*, y
se descartó porque **exigiría un índice inverso que no existe**. Ese descarte sigue en pie, y
ahora se puede decir con precisión de dónde sale el límite:

> **Un `Ruleset` alcanza exactamente lo que la compilación puede ver.** Dentro del
> workspace, todo. Fuera, nada — y no porque falte una funcionalidad, sino porque la
> compilación es **hermética** por invariante III, y un alcance que dependiera de un registro
> central dejaría de ser una función del árbol de ficheros.

Es la frontera que separa lo comprobable de lo prometido. Un sistema con un registro central
—una instancia, una organización— puede decir *«esta regla gobierna aquellos proyectos»* y
comprobarlo; nosotros tenemos **un commit**, y con un commit solo es decidible lo que está
dentro de él. Afirmar más sería una regla que no se puede hacer cumplir, que es peor que no
tenerla.

La misma frontera aparece resuelta igual en el ecosistema de GitLab, y por un motivo
completamente distinto: sus *Organizations* están **aisladas entre sí por defecto**, y *«las
funcionalidades entre espacios de nombres solo funcionan para espacios de nombres que existen
en una sola Organization»*. Ellos lo hacen por aislamiento de inquilinos y nosotros por
hermeticidad, y **la regla que sale es la misma**: lo que cruza fronteras solo funciona
dentro de una.

### 2.5.3 · Y por eso no hay `scope` de miembros

La pregunta evidente es si un `Ruleset` local debería poder decir *«a estos miembros sí y a
estos no»*. **No lo lleva**, y las dos razones ya estaban escritas:

- **Estrechar es de `targets`.** Un objetivo selecciona por clasificación: *«todo lo que sea
  `high`»* no necesita *«excepto `supply`»*. Y si `supply` necesita otra regla, esa regla es
  otro `Ruleset` — probablemente con otro dueño, que es justo lo que este documento existe
  para permitir (§5).
- **La exclusión ya existe, y está un piso más arriba.** `workspace.exclude` quita un
  directorio de la compilación entera. Excluido del workspace es no compilado, luego no
  gobernado: **un concepto en vez de dos.**

El contraste con GitLab es informativo, porque su `policy_scope` **sí** lleva `excluding`, y
se ve por qué lo necesita: allí la unidad de gobierno —el enlace a un proyecto de políticas—
y la unidad de pertenencia —el grupo— **son distintas**, así que hay que reconciliarlas dentro
de la política. Aquí son la misma, y por eso sobra el campo.

### 2.6 · Un objetivo vacío es un defecto

Un objetivo que no casa con ninguna propiedad es `OOS8002`, y conviene decir por qué no es
simplemente *«un conjunto vacío»*.

Casi nunca significa *«no hay nada así»*. Significa que alguien escribió mal un nivel, o que
el retículo cambió de niveles y la regla quedó apuntando a un nombre que ya no existe.
**Una regla que no gobierna nada tiene exactamente el mismo aspecto que una que funciona**, y
es el único fallo de este documento que no produce ningún síntoma.

Kubernetes tomó la decisión contraria —*«un selector de etiquetas vacío casa con todos los
objetos»*— y es una de sus trampas conocidas. Aquí no hay forma de escribir *«todo»*, y es
a propósito: una regla que gobierna todo el modelo no es gobierno, es una opinión.

---

## 3. Las aserciones — el perfil de ODCS

El cuerpo es `quality` de ODCS v3.1, decidido en v1alpha2 y sin cambios. Lo que este
documento fija es **qué parte se perfila**:

| Campo ODCS | En OOS |
|---|---|
| `type: library` | **admitido.** Sin dialecto: puede apuntar a cualquier conjunto |
| `type: sql` | **admitido**, con `OOS8005` — el objetivo no puede abarcar dos fuentes |
| `type: text` | **transportado sin interpretar.** Es prosa |
| `type: custom` | **transportado sin interpretar.** Nombra un motor externo |
| `metric` · `mustBe` · `mustBeGreaterThan` · `mustBeBetween` … | pasan. Vocabulario cerrado de ODCS |
| `dimension` | pasa — `accuracy`, `completeness`, `conformity`, `consistency`, `coverage`, `timeliness`, `uniqueness` |
| `severity` · `businessImpact` · `unit` · `description` | pasan |
| `schedule` · `scheduler` | **excluidos** |
| `customProperties` · `authoritativeDefinitions` | transportados sin interpretar, como en `Package` |

`schedule` y `scheduler` se excluyen por la frontera que `00-scope` §5 ya fija: **ningún
planificador.** Un `Ruleset` declara qué debe sostenerse; cuándo se comprueba es asunto del
motor que lo ejecute, y ODCS mismo dice que ese motor es Soda, Great Expectations o dbt.

```yaml
  assertions:
    - id: no-nulls
      metric: nullValues
      mustBe: 0
      dimension: completeness
      severity: error

    - id: sin-solapes
      type: sql
      query: |
        SELECT COUNT(*) FROM {object} a JOIN {object} b
        ON a.employeeId = b.employeeId AND a.periodEnd > b.periodStart
      mustBe: 0
```

**Normativo.**

- Una aserción `library` es independiente del dialecto y su objetivo puede abarcar cualquier
  número de fuentes.
- Una aserción `sql` está atada a un dialecto, y el dialecto solo se conoce donde se declara
  la fuente. Su objetivo **NO DEBE** seleccionar propiedades de más de una fuente física:
  `OOS8005`.
- `assertions` es un **conjunto**: N4 lo ordena. Todas deben sostenerse, así que el orden no
  significa nada. Es la otra mitad de N4 —*conjuntos ordenados, secuencias preservadas*— y
  la comparación con `Resolution.strategies` deja de ser arbitraria: **allí el orden decide
  qué gana; aquí no hay nada que ganar.**

> **P3 no aplica a una aserción, y ya estaba justificado** (v1alpha2 §3.1): P3 exige datos
> inertes en los documentos que **gobiernan** el acceso. Una aserción de calidad afirma una
> propiedad de los datos, no decide quién los ve. Por eso puede llevar SQL donde una
> precondición de `Function` no puede — y por eso el **objetivo**, que sí decide sobre qué se
> gobierna, no puede llevar ni una expresión (§2.1).

---

## 4. Las máscaras y los ámbitos

Una máscara sin sujeto: el desclasificador que se aplica al construir el índice, que es el
hueco que [`99-errors`](../v1alpha1/99-errors.md) registró para v1alpha2 y v1alpha2 no cerró.

```yaml
  masks:
    - declassifier: tokenize
      to: { gdpr.sensitivity: low }
```

**Normativo.**

- `declassifier` **DEBE** pertenecer al conjunto cerrado de
  [`04-flow`](../v1alpha1/04-flow.md) §5. v1alpha1 prohíbe los definidos por el usuario y esa
  prohibición no se reabre.
- De ese conjunto, **`promote` no es admisible como máscara**, y excluirlo no es retirarlo:
  `promote` sube por un retículo de ciclo de vida y **una máscara tiene que bajar**. Sigue
  siendo un desclasificador para su propio uso. Quedan `mask`, `tokenize`, `redact` y
  `aggregate`.
- `to` **DEBE** declarar el nivel resultante, y ese nivel **DEBE** ser **estrictamente
  menor** que el `atLeast` de cada objetivo del documento. Si no, `OOS8003`.
- `to` **NO DEBE** declararse sobre `redact`: redactar hace desaparecer el valor, luego su
  salida es siempre el ínfimo del retículo. **Un campo derivable no es declarable** —P2, y
  la cuarta vez que este proyecto quita algo por la misma razón. **Y es estructural**: cabe
  entero en el esquema, así que es `OOS1004` —forma— y no `OOS8003`. Escribir el esquema
  dejó a
  `OOS8003` con una sola causa, igual que dejó a `OOS7010` sin ninguna.
- La comprobación es **local al documento**: compara dos niveles declarados. No hace falta
  recorrer las propiedades seleccionadas, porque ninguna puede estar por debajo del `atLeast`
  que las seleccionó.

La regla del descenso estricto es lo que ningún catálogo puede comprobar, y conviene decir
exactamente por qué. Una máscara de Unity Catalog o de Snowflake es una **función opaca**
evaluada en tiempo de consulta: nadie sabe qué clasificación sale por el otro lado, y por
tanto nadie puede decir si lo que sale puede ir a donde va. Un desclasificador que no baja no
es una salvaguarda —es teatro con coste de cómputo—, y aquí el compilador lo demuestra.

### 4.1 · La máscara con sujeto: la anotación de Cedar

La otra mitad, y la que cierra la afirmación de `00-overview` §7.1. `00-overview` §5 ya decía
que las obligaciones son **anotaciones de política**; faltaba decir cuál y qué se comprueba.

```cedar
@oosMask("eu.gdpr-minimization#ssn-last4")
permit(principal in Role::"analyst", action, resource in Label::"gdpr.sensitivity:high");
```

La anotación **no declara una máscara: nombra una**. Es la diferencia que evita la trampa de
siempre — con un desclasificador escrito ahí dentro habría dos sitios donde declarar una
máscara, y el `to` no estaría en ninguno de los dos de forma comprobable. Nombrando una del
`Ruleset`, la definición sigue estando en un único sitio, con dueño, versión y descenso
verificado.

Por eso una máscara gana `id`, y por la misma razón que una aserción lo tiene: para que algo
pueda apuntar a ella.

**Normativo.**

- La anotación **DEBE** ser `@oosMask` y su valor `<ruleset cualificado>#<id de máscara>`.
- **DEBE** resolver a una máscara declarada; si no, `OOS2001` — la misma reserva de v1alpha1
  que ya activa el `call` de un deber.
- La etiqueta del ámbito de la política **DEBE** ser alcanzada por el objetivo de ese
  `Ruleset`. Enmascarar con una regla que no gobierna esa propiedad es una máscara que no se
  aplica, y eso ya tiene código: `OOS8003`.

**Y lo que NO se comprueba, que es la mitad importante de la respuesta.** La cláusula `when`
de la política no se evalúa ni se interpreta: hacerlo sería reimplementar el evaluador de
Cedar, que es exactamente lo que **P6** existe para impedir. Lo que se comprueba es
**estructural** —la anotación resuelve, el ámbito y el objetivo se solapan, el descenso es
estricto— y eso basta para el fallo que importa: **una máscara que se nombra y no existe, o
que no baja.** Que la política se dispare para el principal correcto lo decide Cedar, en
ejecución, y es L3.

---

### 4.2 · El ámbito de filas: la máscara recorta el valor, el ámbito recorta la fila

Cedar gobierna **propiedades**, y eso está en la forma de la proyección: el recurso se
posiciona por **pertenencia** —`resource in Label::"…"`— y **no lleva atributos**, porque
describirlo con atributos obligaría al motor a **leer el recurso para autorizarlo**.

De ahí sale la pregunta que aparece en cuanto hay un dato real y que ninguna versión había
contestado: *«compensación **de mi departamento»*. Eso no es una propiedad. Es un **recorte
de filas**, y una política de Cedar no lo puede expresar sin convertirse en una evaluación
por fila — que es exactamente la lectura que decide el acceso a sí misma.

> **Una máscara recorta el valor. Un ámbito recorta la fila.** La misma figura sobre dos
> ejes, y por eso viven en el mismo documento.

```yaml
  scopes:
    - id: own-department
      property: hr.Employee.departmentId
      matches: departmentId            # un ATRIBUTO del principal, por NOMBRE
```

```cedar
@oosScope("eu.hr-scoping#own-department")
permit (
    principal in Role::"hr_analyst",
    action == Action::"read",
    resource in Label::"gdpr.sensitivity:critical"
) when { context.purpose == "compensation_review" };
```

El documento **no nombra a ningún sujeto**: nombra una columna y el **nombre** de un
atributo. Quién es el principal lo pone la petición, igual que en una máscara con sujeto. Por
eso un ámbito cabe en un `Ruleset` sin contradecir §1.

#### 4.2.1 · Por qué no se deriva de la política

Cedar tiene evaluación parcial —`partial-eval`, y sigue siendo **experimental**— y es el
mecanismo que la industria usa para esto: se deja el dato como incógnita, el evaluador
devuelve un **residuo**, y el residuo se traduce a un `WHERE`. Es lo que hace la *Compile
API* de OPA, y lo que hay debajo de las *row access policies* de los almacenes.

No se toma, y no es prudencia ante una funcionalidad experimental:

> **Un residuo se computa al responder. Un ámbito declarado falla al compilar.**

La tesis entera es que la gobernanza se demuestra cuando compila. Un residuo que nombra una
columna que el binding no mapea, o que la fuente no sabe ejecutar, se descubre **con la
consulta en vuelo**. Un ámbito declarado se descubre en el pull request, y con un código que
ya existe y ya dice justo eso de `requiredFilters`: `OOS2015`.

#### 4.2.2 · La gramática es cerrada, y la cierra un argumento ya escrito

[`03-binding`](../v1alpha1/03-binding.md) §3.5.1 lo dejó dicho para el selector:

> **Un predicado no filtra: lee.** Qué filas aparecen es observable, así que un predicado
> sobre una columna clasificada es un canal lateral.

Un ámbito **es** un predicado, luego hereda el problema entero. Lo que lo desactiva es
precisamente la restricción que lo hace útil:

> El lado derecho de un ámbito **DEBE** ser un atributo del principal. Nunca un literal,
> nunca otra columna.

Con un atributo del principal, la presencia de una fila revela *que existe una fila con el
valor que el principal ya traía consigo*. **No se filtra nada que el principal no haya
aportado él mismo**, y el canal lateral se cierra por construcción, no por convención. Con un
literal sí se filtraría —y además sería estático, que es lo que hace un `selector`—; con otra
columna se ordenaría, que es lo que §3.5.1 rechaza.

Las dos piezas quedan separadas y sin solaparse:

| | `selector` · binding | `scope` · ruleset |
|---|---|---|
| Dice | qué filas **son** la entidad | qué filas **ve este principal** |
| Vive en | el plano físico | el plano de gobierno |
| Compara contra | un literal | **un atributo del principal** |
| Es | una partición | un recorte |
| Se aplica | siempre | cuando una política lo nombra |
| Alcance | ese binding | **toda la entidad, en todos sus bindings** |

La última fila es la razón de que no viva en el binding, y no es de comodidad: una entidad
tiene varios bindings —los dos ejes de materialización, varias fuentes— y una regla de
gobierno repetida por binding **diverge en silencio** el día que alguien añade el cuarto.

#### 4.2.3 · Normativo

- Un ámbito **DEBE** declarar `id`, `property` y `matches`, y **NO DEBE** declarar nada más.
  No hay operador: la igualdad es el único que cierra el canal lateral de §4.2.2, así que
  nombrarlo sería ofrecer una elección que no existe.
- `property` **DEBE** ser el nombre cualificado de una propiedad existente; si no, `OOS2005`.
- `matches` **DEBE** ser el nombre de una propiedad de alguna entidad `principal: true`; si
  no, `OOS2005`. Es la comprobación que importa: un ámbito que apunta a un atributo que nadie
  declara **no falla, deja de casar**, y la fila queda visible.
- Todo binding de la entidad de `property` **DEBE** mapear esa propiedad; si no, no hay con
  qué construir el filtro y la fuente es inconsultable: `OOS2015`, ampliado.
- La anotación **DEBE** ser `@oosScope` y su valor `<ruleset cualificado>#<id de ámbito>`, y
  **DEBE** resolver; si no, `OOS2001` — la misma reserva que ya activa `@oosMask`.
- Una política **PUEDE** nombrar varios ámbitos. **La conjunción es implícita**, igual que en
  un `selector`.
- Una política **sin** ámbito no recorta filas. No es un descuido ni contradice **P4**: el
  `permit` ya afirmó que ese principal puede leer esa propiedad, y sin recorte eso significa
  todas sus filas. Un recorte implícito dejaría sin efecto toda política ya escrita.
- Un ámbito **NO descarga** ninguna clase de `requiresGovernance` (§6.1). Quien descarga
  `authorization` es la política que lo nombra; un ámbito solo **no gobierna nada**, y
  contarlo permitiría satisfacer la cobertura con un recorte que ninguna política invoca.
- `scopes` es un **conjunto**: N4 lo ordena. Se aplican todos los nombrados, así que el orden
  no significa nada — la misma razón que en `assertions`.

**Y no hay ningún código nuevo.** Tres comprobaciones, tres familias que ya existían, y la
tercera reutiliza una condición que [`05-ejecutor`](../v1alpha1/05-ejecutor.md) §5.3 ya había
escrito para otro origen: *un filtro exigido que nadie mapea hace inconsultable el binding*.
Que un requisito de la fuente y un requisito de la política produzcan el mismo defecto no es
una coincidencia — **son el mismo defecto**.

---

## 5. Los deberes

```yaml
  duties:
    - call: compliance.NotifyDPO
```

**Normativo.**

- `call` **DEBE** resolver a una `Function` declarada; si no, **`OOS2001`**.
- La función **DEBE** alcanzar la integridad que exija su propio destino. No hace falta
  código nuevo: es `OOS7001`, aplicado donde ya estaba.
- Un deber **NO TIENE** condición propia. **El objetivo del documento es la condición.**

Esa última es la decisión de forma que más se va a echar de menos, y por eso lleva motivo. Un
`when:` dentro del deber sería un **segundo lenguaje de selección** dentro del mismo
documento, y un documento con dos alcances es más difícil de auditar que dos documentos con
uno cada uno. Si el deber aplica a un subconjunto más estrecho, ese subconjunto tiene su
propio `Ruleset` — probablemente con otro dueño, que es justo lo que el documento existe para
permitir.

**Y lo que hoy no es.** Un deber declara **qué función responde** por un conjunto. *Cuándo*
tiene que correr es temporalidad, que sigue aplazada. Es la pieza más delgada de las tres en
esta versión, y se escribe ahora por una razón concreta: fijar el vocabulario **antes** de
que llegue el operador temporal. La lección está escrita en v1alpha2 §2 — el endosante
apareció inventado tres veces con tres nombres, y un concepto con tres nombres acaba con tres
semánticas.

Lo que sí hace falta desde el primer día es la restricción que lo hace exigible:

> **Un deber DEBE nombrar una `Function`.**

XACML murió de lo contrario. La crítica documentada es que *«contiene funcionalidades, como
las obligaciones, que no se corresponden limpiamente con ningún sistema de control de acceso
conocido»*: nombraban deberes que ningún runtime sabía ejecutar. Una referencia a una función
declarada trae su integridad computada, sus precondiciones, su endoso y su destino
comprobado.

**Y el código no es propio, que es lo interesante.** El borrador le dio `OOS8004`; escribir
los casos dejó ver que `OOS2001` lleva reservado desde v1alpha1 para exactamente esto:

> *«Se reserva porque `Function`, `Resolution` y `Test` introducen tipos de referencia nuevos
> en v1alpha2.»*

Un deber es el primer tipo de referencia nuevo que llega. **Activar una reserva es mejor que
inflar una familia**, así que `OOS8004` queda retirado antes de implementarse.

---

## 6. Qué cuenta para la cobertura

`OOS8001` exige que toda propiedad que exija gobierno esté cubierta. Aquí se define
**cubierta**, y no es *«aparece en algún objetivo»*.

> **Solo cuenta lo que el compilador puede leer y lo que puede fallar.**

Una regla, tres consecuencias, y las tres cierran un agujero antes de que exista:

| | ¿Cuenta? | Por qué |
|---|---|---|
| aserción `library` o `sql` con `severity: error` | **sí** | legible y puede fallar |
| aserción con `severity: warning` | **no** | un aviso es, por definición, *«lo vimos y no paramos nada»*. No descarga la obligación de gobernar |
| aserción `type: text` o `type: custom` | **no** | se transporta sin interpretar. El compilador no sabe qué afirma |
| **máscara** | **sí** | el compilador la lee, `OOS8003` la puede rechazar, y una propiedad enmascarada está gobernada |
| **ámbito de fila** | **no** | recorta filas, no gobierna una propiedad. Quien descarga `authorization` es la política que lo nombra (§4.2.3) |
| **deber** | **solo si se pide** | no puede fallar al compilar, así que no descarga una exigencia genérica. Pero un retículo **puede exigir `obligation`**, y entonces lo que se comprueba es que el deber exista y nombre una `Function` — que sí es decidible |

Sin esta regla, `OOS8001` se satisface con una aserción `severity: warning` que no para nada,
y **la cobertura pasa a medir que alguien escribió un fichero**. Es el modo de fallo más
probable de todo v1alpha3, porque es el que aparece cuando alguien tiene prisa por hacer
verde una compilación.

### 6.1 · Y de la clase que se exige

Lo legible que puede fallar es la mitad de la respuesta. La otra la pone
[`01-gobierno`](01-gobierno.md) §6.1: `requiresGovernance` nombra **qué clases de regla**
descargan la exigencia, y una propiedad tiene que satisfacerlas todas.

| El retículo exige | Lo descarga |
|---|---|
| `constraint` | una aserción legible con `severity: error` |
| `authorization` | una política de Cedar cuyo ámbito alcance esa etiqueta |
| `transformation` | una máscara |
| `obligation` | un deber que resuelva a una `Function` |

Es lo que impide el error de categoría, que es el frecuente: una comprobación de nulos **no**
descarga la exigencia que un paquete de protección de datos puso sobre una columna con PII,
porque lo que ese paquete pedía era una política. El fallo no era que faltara una regla —era
que sobraba la equivocada.

Y el límite se mantiene, escrito y no disimulado: **el compilador decide la cobertura, el
endoso registra la adecuación** ([`01-gobierno`](01-gobierno.md) §6.2).

---

## 7. Lo que **no** es un campo

Quinta vez que la ley aparece, y ya no sorprende:

| | Por qué no |
|---|---|
| `when` en un deber | el objetivo del documento es la condición (§5) |
| `to` en un `redact` | derivable: es el ínfimo del retículo (§4) |
| `enabled` | una regla desactivada es una regla que no está |
| `priority` / orden | `assertions` es un conjunto: todas se sostienen. No hay nada que desempatar (§3) |
| el operador del objetivo | el gobierno es monótono, luego solo hay uno (§2.3) |
| el operador de un ámbito | la igualdad es la única que cierra el canal lateral (§4.2.2) |

La cuarta fila conviene leerla junto a `Resolution`. Allí `strategies` **es** una secuencia y
N4 preserva su orden, porque la primera que casa gana. Aquí no gana ninguna: se sostienen
todas. **La misma regla de forma canónica trata los dos casos distinto porque los dos casos
son distintos**, y ahora está escrito por qué.

---

## 8. Errores

| Código | Condición |
|---|---|
| `OOS8001` | propiedad que exige gobierno y ninguna regla **que cuente** la cubre (§6) |
| `OOS8002` | objetivo que no casa con ninguna propiedad (§2.6) |
| `OOS8003` | máscara cuyo `to` no es estrictamente menor que el `atLeast` del objetivo (§4) |
| `OOS8005` | aserción `sql` cuyo objetivo abarca más de una fuente física (§3) |
| `OOS8006` | **objetivo** sobre un retículo de eje `integrity` (§9) |

`OOS8006` salió de escribir este documento, igual que `OOS7008` salió de escribir `Function`.
No estaba en el registro de [`01-gobierno`](01-gobierno.md) §8 y se añade.

**Y escribir el esquema encogió tres de ellos**, que es el mismo mecanismo en la otra
dirección:

| | Antes | Ahora |
|---|---|---|
| `OOS8003` | dos causas | **una** — `to` sobre un `redact` cabe en el esquema |
| `OOS8006` | dos causas | **una** — `requiresGovernance` en un eje `integrity` también cabe |
| `OOS8004` | un código | **retirado** — es `OOS2001`, reservado desde v1alpha1 (§5) |

Y los que **no** hacen falta, que es igual de informativo:

| Condición | Código | De dónde sale |
|---|---|---|
| `Ruleset` sin `owner`, sin `targets`, o sin ninguna regla | `OOS1004` | forma |
| `to` declarado sobre un `redact` | `OOS1004` | forma |
| retículo o nivel inexistentes en un objetivo | `OOS4003` | v1alpha1 |
| desclasificador fuera del conjunto cerrado | `OOS4006` | v1alpha1 |
| deber que no resuelve a una `Function` | `OOS2001` | reservado en v1alpha1 |
| la función de un deber no alcanza su destino | `OOS7001` | v1alpha2, sin tocar nada |

**Cinco códigos nuevos y seis condiciones resueltas por cuatro familias que ya existían**, y
esa proporción es la señal de que la partición de [`01-gobierno`](01-gobierno.md) §4 estaba
bien hecha: casi nada hubo que inventarlo.

---

## 9. Aplazado

- **`atMost` — descartado, no aplazado.** La sospecha que quedó anotada resultó ser la
  respuesta: **el eje de integridad ya está gobernado, y en otro documento.** Su regla de
  cobertura es `I(f) ⊒ I(destino)` de v1alpha2 —escrita, implementada y certificada—, y el
  remedio de la baja integridad es un endoso, que es asunto de `Function`. Un `Ruleset`
  apuntando a un retículo `integrity` sería un **segundo mecanismo, más débil**, para algo
  que ya falla cerrado. Por eso `OOS8006` deja de ser un aplazamiento y pasa a ser una
  frontera: no está sin escribir — está escrito en otro sitio. El caso enumerado sobre datos
  poco fiables se escribe con un objetivo `named`, que no necesita operador de orden.
- **La exigibilidad de un deber.** Necesita el operador temporal. Va con `Test` y con lo
  temporal, después de L2.
- **El tercer estado de la cobertura: `pendiente`, con ventana.** §6 dice *«solo cuenta lo
  que el compilador puede leer y lo que puede fallar»*, y de ahí que una aserción `custom`
  se transporte sin interpretar y **no cuente**. Es honesto y deja un hueco:

  > **Una comprobación que nadie ejecutó tiene exactamente el mismo aspecto que una que
  > pasó.**

  Hoy la cobertura es binaria, y por eso *«hay una regla que nadie corrió»* y *«no hay
  ninguna regla»* se renderizan igual. Son dos situaciones distintas y la segunda es peor.

  La forma que falta la tiene medida el ecosistema de GitLab, cuyos *external controls*
  son exactamente esta figura: una llamada a un tercero que devuelve `pending`, `pass` o
  `fail` — y **un `pending` que dura más de seis horas se convierte en `fail`**. Es la
  tercera opción entre *decidir* y *encogerse de hombros*, y la que este documento no
  tiene.

  La versión que encaja aquí: **una aserción que el compilador no puede decidir DEBE
  nombrar quién la decide y en qué ventana, y un veredicto que no llega es un fallo.**
  Entonces `custom` deja de ser prosa transportada y pasa a contar —como `pendiente`—,
  que es lo que permite distinguir las dos situaciones de arriba.

  No se escribe todavía porque **necesita el operador temporal**, igual que la fila de
  arriba: *«en qué ventana»* no es expresable sin él. Las dos esperan a lo mismo, y ahora
  se sabe que son la misma espera.

  Y conviene decir lo que **no** bloquea. Un informe de cobertura no depende de esto:
  aquí una propiedad sin la clase de gobierno que exige su clasificación **no compila**,
  así que un informe **no puede tener filas rojas**. No es una lista de incumplimientos
  —que es lo que un catálogo puede ofrecer— sino un registro de qué gobierna qué y quién
  responde. El `pendiente` no lo habilita: le añade la única fila que podrá ser ámbar.
- **La adecuación de una regla — y no está aplazada: es indecidible.** §6.1 tipa la
  cobertura por naturaleza y con eso elimina el error de categoría, que es el frecuente. Lo
  que no elimina, y ningún análisis estático eliminará, es que **una política que permite todo
  cubre igual que una que no permite nada**: la diferencia no está en el documento, está en
  lo que la organización quería. Se responde con un dueño y, cuando hace falta más, con un
  endoso ([`01-gobierno`](01-gobierno.md) §6.2). **Escribirlo como límite y no como pendiente
  es la diferencia entre una especificación honesta y un cuadro de mando con un porcentaje.**
