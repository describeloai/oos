# OOS v1alpha3 — alcance

**Estado:** **alcance cerrado — primera versión.** Los tres documentos están escritos, su
suite va 19/19, **ninguna decisión del plano queda abierta** y la implementación de
referencia va al día. Lo que aquí se cierra es el **diseño**, no la ratificación:
`spec/v1alpha1/` sigue siendo la versión normativa.

| | |
|---|---|
| `00-scope` | **este documento** — qué entra en v1alpha3, qué no, y qué queda abierto |
| [`schemas/v1alpha3/`](../../schemas/v1alpha3/) | `ruleset` y `lattice` — el segundo cierra además un hueco de v1alpha2 |
| [`conformance/v1alpha3/`](../../conformance/v1alpha3/README.md) | 19 casos, árbol y marcador propios |
| [`01-gobierno`](01-gobierno.md) | el núcleo — el régimen de gobierno, del que se deriva todo lo demás |
| [`02-ruleset`](02-ruleset.md) | el documento — el objetivo, las aserciones, las máscaras y los deberes |

---

## 1. La tesis

Cada versión gobierna un verbo distinto, y aporta **una** regla:

| | Gobierna | Regla | Dice |
|---|---|---|---|
| **v1alpha1** | lo que se puede **saber** | `L ⊑ C` | nada fluye por encima de su autorización |
| **v1alpha2** | lo que se puede **causar** | `I(f) ⊒ I(destino)` | nada escribe por encima de su integridad |
| **v1alpha3** | **qué debe sostenerse — y quién responde** | `L(x) ⊒ n ⟹ ∃r` | nada clasificado queda sin gobernar |

Y la tercera no inventa el plano: **lo termina.** v1alpha1 ya declaró el vocabulario de
obligaciones —`mask`, `tokenize`, `redact`, `aggregate`— y lo dejó sin sitio donde
engancharse; `99-errors` registró un hueco *«anotado, no improvisado»* para v1alpha2 que
v1alpha2 no tocó. Las tres frases inertes están en [`01-gobierno`](01-gobierno.md) §1, y las
tres necesitan lo mismo.

> **La autorización apunta por clasificación y todo lo demás enumera.** Esa asimetría es lo
> que esta versión corrige.

---

## 2. Las cinco naturalezas de una regla

Toda regla aplicable sobre una superficie ontológica es una de estas cinco, y se distinguen
por **lo que producen al dispararse**:

| | Naturaleza | Produce | Forma | Se decide en |
|---|---|---|---|---|
| **1** | restricción | un veredicto | `∀x∈T . φ(x)` | L0 la forma · L2 los datos |
| **2** | derivación | contenido nuevo | `∀x∈T . p(x) = e(x)` | L2 |
| **3** | autorización | un permiso sobre una acción | `∀(p,a,r) . permit ⟸ φ` | L3 |
| **4** | **obligación** | **otra acción que debe ocurrir** | `∀x∈T . φ(x) ⟹ □ψ` | L3 + tiempo |
| **5** | transformación | el mismo dato, representado distinto | `∀x∈T . x ↦ f(x)` | L2 / L3 |

Cuatro de las cinco tienen la misma forma —**cuantificador y cuerpo**—, y por eso un solo
mecanismo de objetivo las sirve a las cuatro. La cuarta es de otra familia: introduce un
operador modal —*debe llegar a ocurrir*— y con él el tiempo, aplazado desde v1alpha1.

Una precisión de naturaleza, porque es el error de encuadre más caro:

> **Una regla no es un verbo.** Los verbos son `Function` y `Resolution`, y un verbo cambia
> el mundo. Una regla no cambia nada: **sostiene**.

Dónde vive cada una no es cuestión de gusto: sale de preguntar **si hay sujeto**
([`01-gobierno`](01-gobierno.md) §4). Con sujeto, Cedar. Sin él, un `Ruleset`. Y la
naturaleza 2 ya está colocada en `Entity.expression` desde v1alpha2.

---

## 3. Lo que hay que añadir es una cosa, no cinco

El error caro sería escribir cinco mecanismos para cinco naturalezas. Casi todo está ya:

| | Estado |
|---|---|
| el cuerpo de una restricción | **existe** — `quality` de ODCS, decidido en v1alpha2 §3.1 |
| el vocabulario de transformaciones | **existe** — desclasificadores, `04-flow` §5, cerrado |
| el cuerpo de un deber | **existe** — `Function`, v1alpha2 |
| la decisión con sujeto | **existe** — Cedar, v1alpha1 |
| la firma del dueño | **existe** — in-toto/Sigstore |
| **el objetivo** | **falta**, y es lo único |

Y el hallazgo que hace que lo único que falta sea gratis:

> **Una etiqueta ya es un conjunto.** v1alpha1 usa el retículo para comparar dos elementos
> —`L ⊑ C`—; el mismo orden, leído en la otra dirección, nombra un conjunto: `{x : L(x) ⊒ n}`.

No hay lenguaje nuevo, no hay motor de consultas, no hay dependencia añadida, y es decidible
al compilar exactamente por la misma razón que `⊑` lo es. Está en
[`01-gobierno`](01-gobierno.md) §3, que es el núcleo de esta versión.

---

## 4. Los documentos

### 4.1 · `Ruleset`

El documento nuevo, y el único. Reúne las reglas **sin sujeto** —aserciones, máscaras de
materialización y deberes— sobre un objetivo común, con un dueño.

```yaml
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
  duties:
    - { call: compliance.NotifyDPO }
```

**Sobre el nombre.** `docs/vision/` tenía un `RuleSet` y v1alpha2 lo retiró
([`v1alpha2/00-scope`](../v1alpha2/00-scope.md) §3.1). Reutilizar el nombre es deliberado y
conviene decir por qué: aquello era **una bolsa de expresiones sin objetivo**, que es
precisamente lo que lo hacía indefendible. Lo que se retiró no fue el nombre — fue la
ausencia de la pieza que lo justifica.

La forma exacta del objetivo está en [`02-ruleset`](02-ruleset.md) §2, y es **estructura, no
texto**: una cadena rompería la forma canónica y dejaría a `OOS5xxx` sin poder distinguir
*«el objetivo subió de `high` a `critical`»* de *«alguien tocó un espacio en blanco»*.

Quedan el esquema JSON y los casos de conformidad.

### 4.2 · Dos campos en documentos que ya existen

| | Dónde | Qué hace |
|---|---|---|
| `requiresGovernance` | `Lattice` | desde qué nivel la cobertura es obligatoria. Es lo que hace que **«GDPR como dependencia» deje de ser una metáfora** ([`01-gobierno`](01-gobierno.md) §6.1) |
| la anotación de máscara | política Cedar | dónde se nombra el desclasificador cuando **sí** hay sujeto. `00-overview` §5 ya decía que las obligaciones son anotaciones de política; falta especificar cuál y qué se comprueba |

### 4.3 · La familia `OOS8xxx`

**Cinco códigos nuevos, y seis condiciones más resueltas por cuatro familias que ya
existían** —`OOS1004`, `OOS2001`, `OOS4003`, `OOS4006` y `OOS7001`—. El detalle está en [`02-ruleset`](02-ruleset.md) §8. `OOS8001`, la cobertura, es
el `OOS4001` de este plano: el defecto **no está escrito en ninguna parte**, porque es la
ausencia de una línea que nadie escribió.

El registro se movió en las dos direcciones al escribir el documento y su esquema: `OOS8006`
apareció, y `OOS8004` se retiró a favor de una reserva que v1alpha1 dejó hecha.

---

## 5. Lo que NO entra

**Ningún motor de reglas.** No se evalúan aserciones, no se planifican deberes, no hay cola
ni programador. Un `Ruleset` es una declaración gobernada, no una tubería. Es la misma
frontera que `01-efectos` §6 puso para las funciones, y por el mismo motivo.

**La exigibilidad de un deber.** Declararlo y comprobar su forma es L0; que llegue a ocurrir
necesita temporalidad, que sigue aplazada. Un deber es **decible ya** y **exigible después**,
y conviene no confundir las dos cosas al describirlo.

**Una segunda superficie de autoría.** El cuerpo de una aserción es `quality` de ODCS y su
destino de emisión también, pero **no se escribe colgando de la propiedad**: un `Ruleset`
admite objetivos por nombre y por predicado, así que el caso enumerado no necesita otro sitio
([`v1alpha2/04-expression`](../v1alpha2/04-expression.md) §3).

**ODRL como modelo interno.** Es Recomendación del W3C y el único estándar con deberes, pero
es RDF, modela licencias entre partes, y sus deberes no tienen semántica de ejecución — el
fallo de XACML otra vez. Se adopta como **objetivo de emisión**, que es la posición que Ossie
ocupa para la entidad ([`01-gobierno`](01-gobierno.md) §9).

---

## 6. Decisiones abiertas

**Ninguna del plano.** Las cuatro que quedaban se cerraron a la vez, y merece verse por qué
en conjunto: tres de ellas se contestaban con algo que ya estaba escrito, y la cuarta se
contestó **dejando de tratarla como una pregunta**.

| | Cómo cierra |
|---|---|
| **la frontera entre cobertura y utilidad** | **la adecuación es indecidible**, y decirlo es la respuesta. El compilador decide la cobertura —ahora **tipada por naturaleza**, lo que elimina el error de categoría—; el endoso registra la adecuación. [`01-gobierno`](01-gobierno.md) §6.2 |
| **la anotación de Cedar para la máscara con sujeto** | `@oosMask("<ruleset>#<id>")`, que **nombra** una máscara en vez de declararla: la definición sigue en un solo sitio. Se comprueba lo estructural y **no** la cláusula `when` — evaluarla sería reimplementar Cedar, que es lo que P6 prohíbe. [`02-ruleset`](02-ruleset.md) §4.1 |
| **dos clasificaciones importadas con exigencias distintas** | **conjunción, nunca elección.** Si bastara una, importar un paquete laxo sería la forma de escapar de uno estricto. [`01-gobierno`](01-gobierno.md) §6.1 |
| **el eje de integridad** | **ya está gobernado, y en otro documento**: su regla de cobertura es `I(f) ⊒ I(destino)` de v1alpha2. `OOS8006` deja de ser un aplazamiento y pasa a ser una frontera. [`02-ruleset`](02-ruleset.md) §9 |

Lo que sigue abierto **no es del plano de gobierno**: la exigibilidad de un deber necesita el
operador temporal, que lleva aplazado desde v1alpha1 y va con `Test`, después de L2.

### La implementación va al día

La tabla de divergencia que esta sección tuvo **está vacía**: `requiresGovernance` tipado, el
`id` de una máscara y `@oosMask` están construidos y certificados. Lo que la especificación
dice de este plano es lo que el compilador hace.

Es la comprobación que quedaba antes de poder **reclamar v1**.

### Cerradas antes

**La proyección de las aserciones a ODCS** — construida. Salen colgando de la propiedad, que
es donde ODCS las espera, y con `x-oos-ruleset` diciendo **quién las exige**. La selección no
se recomputa al emitir: la da la misma fase que decide `OOS8001`, porque dos selecciones
serían dos semánticas ([`v1alpha2/04-expression`](../v1alpha2/04-expression.md) §3.4).

**¿Una regla inline descarga una exigencia importada?** — **por construcción ya no hay reglas
inline.** `quality` se retiró como superficie de autoría
([`v1alpha2/04-expression`](../v1alpha2/04-expression.md) §3) y el caso enumerado pasó a ser
un objetivo `named` dentro de un `Ruleset`, que tiene dueño propio. La pregunta deja de
existir en vez de contestarse, que es la mejor forma de cerrar una.

**Si un objetivo selecciona entidades o propiedades** — selecciona **propiedades**, y no hizo
falta decidir nada: `02-entity` §4.1 ya dice que una etiqueta de entidad la heredan todas sus
propiedades. Era una comprobación, no una decisión
([`02-ruleset`](02-ruleset.md) §2.4).

### Heredadas

**`maxDepth` en Cedar** era de este plano y se decide aquí: **no se admite implícitamente.**
El operador `in` de Cedar es el cierre transitivo completo, y dar por bueno un `maxDepth`
escrito en otra sintaxis significaría conceder **más** alcance del que su autor pidió — la
dirección insegura. Quien necesite una profundidad acotada **materializa la profundidad como
propiedad** y la compara en un `when` normal. Lo que el compilador no puede hacer es
adivinar cuál de las dos se quiso: `resource in principal` es una política legítima, y por
eso esto es una regla de escritura y no un código.

**La superficie de CEL** sigue abierta de v1alpha2
([`v1alpha2/00-scope`](../v1alpha2/00-scope.md) §6), y no es de este plano: un objetivo no
lleva expresiones — es el orden del retículo leído al revés.
