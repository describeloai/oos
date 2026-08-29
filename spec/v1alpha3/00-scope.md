# OOS v1alpha3 — alcance

**Estado:** borrador de alcance. Ningún documento de esta carpeta es normativo todavía.
`spec/v1alpha1/` sigue mandando.

| | |
|---|---|
| `00-scope` | **este documento** — qué entra en v1alpha3, qué no, y qué queda abierto |
| [`01-gobierno`](01-gobierno.md) | el núcleo — el régimen de gobierno, del que se deriva todo lo demás |
| `02-ruleset` | el documento — **pendiente** |

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
naturaleza 2 ya está colocada en `Entity.expr` desde v1alpha2.

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
    - labelled: "gdpr.sensitivity >= high"
  assertions:
    - { metric: nullValues, mustBe: 0, dimension: completeness }
  masks:
    - { declassifier: tokenize }
  duties:
    - { when: "gdpr.sensitivity >= critical", call: compliance.NotifyDPO }
```

**Sobre el nombre.** `docs/vision/` tenía un `RuleSet` y v1alpha2 lo retiró
([`v1alpha2/00-scope`](../v1alpha2/00-scope.md) §3.1). Reutilizar el nombre es deliberado y
conviene decir por qué: aquello era **una bolsa de expresiones sin objetivo**, que es
precisamente lo que lo hacía indefendible. Lo que se retiró no fue el nombre — fue la
ausencia de la pieza que lo justifica.

Queda por escribir en `02-ruleset`: esquema, casos de conformidad y la forma exacta de un
objetivo.

### 4.2 · Dos campos en documentos que ya existen

| | Dónde | Qué hace |
|---|---|---|
| `requiresGovernance` | `Lattice` | desde qué nivel la cobertura es obligatoria. Es lo que hace que **«GDPR como dependencia» deje de ser una metáfora** ([`01-gobierno`](01-gobierno.md) §6.1) |
| la anotación de máscara | política Cedar | dónde se nombra el desclasificador cuando **sí** hay sujeto. `00-overview` §5 ya decía que las obligaciones son anotaciones de política; falta especificar cuál y qué se comprueba |

### 4.3 · La familia `OOS8xxx`

Cinco códigos, y tres familias reutilizadas — el detalle está en
[`01-gobierno`](01-gobierno.md) §8. `OOS8001`, la cobertura, es el `OOS4001` de este plano:
el defecto **no está escrito en ninguna parte**, porque es la ausencia de una línea que
nadie escribió.

---

## 5. Lo que NO entra

**Ningún motor de reglas.** No se evalúan aserciones, no se planifican deberes, no hay cola
ni programador. Un `Ruleset` es una declaración gobernada, no una tubería. Es la misma
frontera que `01-efectos` §6 puso para las funciones, y por el mismo motivo.

**La exigibilidad de un deber.** Declararlo y comprobar su forma es L0; que llegue a ocurrir
necesita temporalidad, que sigue aplazada. Un deber es **decible ya** y **exigible después**,
y conviene no confundir las dos cosas al describirlo.

**Objetivos por enumeración.** Una regla sobre una sola propiedad ya tiene sitio —`quality`
colgando de la propiedad— y dos formas de escribir lo mismo acaban con dos semánticas.

**ODRL como modelo interno.** Es Recomendación del W3C y el único estándar con deberes, pero
es RDF, modela licencias entre partes, y sus deberes no tienen semántica de ejecución — el
fallo de XACML otra vez. Se adopta como **objetivo de emisión**, que es la posición que Ossie
ocupa para la entidad ([`01-gobierno`](01-gobierno.md) §9).

---

## 6. Decisiones abiertas

1. **Qué cuenta como cobertura.** Hoy, cualquier regla que apunte. Pero una propiedad con PII
   probablemente exige una **política**, no una aserción de calidad, y una regla de calidad
   que la cubra dejaría pasar el caso que importa. Tipar la cobertura por naturaleza es la
   salida evidente y no está escrita.
2. **La anotación de Cedar para la máscara de política.** Qué anotación, y **hasta dónde se
   puede comprobar sin reimplementar el evaluador de Cedar** — que es justo lo que P6 dice
   que no hagamos.
3. **Si un objetivo puede seleccionar entidades y no solo propiedades.** v1alpha1 admite
   `labels` en `metadata` de `Entity`, así que la pregunta existe y la respuesta cambia qué
   significa cobertura.
4. **Dos clasificaciones importadas con exigencias distintas.** Si un paquete depende de dos
   retículos y cada uno declara su `requiresGovernance`, la interacción no está escrita.

### Heredadas

**La superficie de CEL** y **`maxDepth` en Cedar** siguen abiertas de v1alpha2
([`v1alpha2/00-scope`](../v1alpha2/00-scope.md) §6). La segunda es una pregunta de este
plano y se decide aquí.
