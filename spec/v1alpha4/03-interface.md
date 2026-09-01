# `Interface` — la forma

**Estado:** borrador. Gobierna los documentos que declaran su `apiVersion`, y es **alpha**:
sin garantías de compatibilidad.

El régimen está en [`01-significado`](01-significado.md). Este documento fija **la superficie
normativa del documento**: qué se escribe, qué no cabe, qué significa satisfacerlo y qué
alcanza una regla que apunte a él.

---

## 1. Naturaleza

Un `Interface` nombra un conjunto de entidades **por lo que tienen**.

```yaml
apiVersion: oos.dev/v1alpha4
kind: Interface
metadata: { name: Party, namespace: acme }
spec:
  requires:
    - gdpr.personalEmail
    - acme.legalName
  description: >
    Cualquiera con quien la empresa mantiene una relación contractual.
```

```yaml
kind: Entity
metadata: { name: Customer, namespace: crm }
spec:
  implements: [acme.Party]
```

Toda la diferencia está en una palabra de `requires`: **exige el concepto, no el nombre.**

| | `crm.Customer` | `erp.Supplier` | `legacy.Kunde` |
|---|---|---|---|
| el correo se llama | `email` | `contactEmail` | `kunde_email` |
| el nombre legal se llama | `name` | `razonSocial` | `firma` |
| **implementa `acme.Party`** | ✓ | ✓ | ✓ |

Ninguna se renombró. Si la interfaz exigiera nombres, para gobernar las tres habría que
renombrar dos — y el que manda no es el modelo, es el sistema que produce el dato y que lleva
veinte años llamándolo `razonSocial`.

> **Modelar sin esto obliga a limpiar antes de gobernar, que es el orden imposible.**

Y esa es la razón de que exista, no una elegancia: un patrimonio real llega sucio y disperso,
y la única manera de gobernarlo es **describirlo tal como está**.

---

## 2. Lo que **no** es un campo

| | Por qué no |
|---|---|
| **acciones** | en Foundry una interfaz lleva propiedades, enlaces y *actions*. Aquí una acción es una `Function`, y **una `Function` no puede apuntar a una interfaz** — §9 |
| **herencia** | y no porque falte: `I ⊑ J` **se computa** de la inclusión entre sus `requires`. Un `extends` sería un segundo sitio donde decirlo, y podría contradecirlo — **P2**, §4.2 |
| `owner` | un `Ruleset` lo necesita porque **restringe lo ajeno**; una interfaz solo nombra. Un campo del que nada se computa acaba adquiriendo un significado que nadie escribió |
| `labels` | no porta datos, luego no tiene clasificación. Lo mismo que `Ruleset` |
| **exigencias estructurales** | `primaryKey`, `timeKey`, cardinalidades. Es el apartado 5, y es lo más importante que este documento excluye |

---

## 3. Anatomía

### 3.1 · `metadata`

`name` y `namespace` **obligatorios**, `description` opcional. Con `namespace` viene lo de
siempre: dueño, versión, digest y fijación en el lock. Un paquete sectorial puede publicar
`Party`, `Product` y `Location` y que veinte ontologías declaren implementarlas.

### 3.2 · `spec.requires`

Lo único, y **obligatorio**.

- Es una lista de **nombres cualificados de `Concept`**. Nunca de otra `Interface` —la
  herencia no está escrita— ni de nombres de propiedad de una entidad.
- Un nombre que no resuelve es `OOS2001`.
- Es un **conjunto**: el orden no significa nada y la forma canónica lo ordena. Dos
  interfaces que exigen lo mismo en otro orden tienen el mismo digest.
- **No puede estar vacía.** Una forma sin exigencias la satisface cualquier cosa, y entonces
  no nombra ningún conjunto: es `OOS8002` visto desde el otro lado, y el esquema lo impide
  antes — `OOS1004`.

---

## 4. Qué significa satisfacerla

> `E implements I ⟹ ∀c ∈ I . ∃p ∈ E . is(p) = c`

Para cada concepto que la interfaz exige, **alguna** propiedad de la entidad tiene que
declarar `is` sobre él. Nada más:

- **Ni el nombre de la propiedad ni su número importan.** Dos propiedades pueden mapear al
  mismo concepto y la forma se satisface igual.
- Una entidad puede tener cuarenta propiedades que la interfaz no menciona. No estorban.
- Una entidad puede implementar varias formas a la vez.

Y es decidible al compilar por lo de siempre: **los dos lados se computan del paquete, sin
tocar un dato.** El conjunto exigido sale del documento de la interfaz; el conjunto mapeado,
de los `is` de la entidad. Es una diferencia de conjuntos.

Que falte uno es `OOS9001`, y el diagnóstico nombra **qué concepto falta**, no que «la
interfaz no se satisface»: el error tiene que decir dónde está la línea que no se escribió.

### 4.1 · El caso que un chequeo por nombre no vería

```yaml
kind: Entity
metadata: { name: Supplier, namespace: erp }
spec:
  implements: [acme.Party]
  properties:
    email: { type: String }              # se llama como el que falta
    razonSocial: { is: acme.legalName }
```

`erp.Supplier` **tiene una propiedad llamada `email`** y aun así no satisface `acme.Party`,
porque no mapea `gdpr.personalEmail`. Que se llame igual que lo que falta es precisamente el
modo de fallo: una comprobación por nombre la habría dado por buena, y esa columna habría
quedado fuera de todo lo que gobierna a `Party` **pareciendo que estaba dentro**.

### 4.2 · La jerarquía **se computa**, no se declara

`Employee` exige `{personalEmail, legalName, employeeId}`; `Party` exige
`{personalEmail, legalName}`. Entonces:

> `Party.requires ⊆ Employee.requires`, luego **toda entidad que satisface `Employee`
> satisface `Party`**. No es una declaración: es un teorema sobre dos documentos.

De ahí sale la respuesta a si debe haber herencia entre interfaces: **no como campo.** Un
`extends: [acme.Party]` sería un segundo sitio donde decir algo que `requires` ya dice, y
podría **contradecirlo** — declararse extensión de `Party` sin exigir lo que `Party` exige.
Es **P2** literal: *lo derivable no se declara*.

**Y esto no es una analogía prestada de los lenguajes de programación: es la respuesta de la
propia disciplina.** En OWL, una clase con condiciones **necesarias y suficientes** es una
*clase definida*, y un razonador **computa** su lugar en la jerarquía; la jerarquía asertada
se reserva para las clases *primitivas*, cuya pertenencia no se puede calcular. Un `Interface`
es una clase definida por construcción —`requires` es exactamente una condición necesaria y
suficiente de la forma—, así que **su jerarquía es inferida por definición**.

La misma decisión, tomada desde el otro extremo de la informática: Go no tiene palabra clave
`implements`, y un tipo satisface una interfaz en cuanto su conjunto de métodos es un
superconjunto del de ella. Es la misma inclusión de conjuntos, comprobada en compilación.

**Normativo.**

- `I ⊑ J` **si y solo si** `J.requires ⊆ I.requires`. Se computa; no hay campo.
- Un objetivo `implements: [J]` alcanza también a las entidades que declaran `I`, para
  cualquier `I ⊑ J`.
- Dos interfaces con el mismo `requires` se subsumen mutuamente: **son la misma forma con dos
  nombres**, y con esta regla eso queda a la vista en lugar de escondido.

La monotonía se comporta como en `atLeast`, que es el precedente que lo hace seguro: si una
regla se aplica a una forma, aplicarla también a una forma **más exigente** es la dirección
correcta. Una regla que dejara de aplicarse cuando la entidad tiene *más* de lo que se pide
sería un defecto, igual que una que dejara de aplicarse cuando el dato es más sensible.

### 4.3 · Entonces ¿por qué `implements` **sí** se declara?

Es la pregunta que la sección anterior obliga a contestar. Si la subsunción entre interfaces
se computa, computar la satisfacción de una entidad también sería posible: mirar sus `is` y
ver si cubren lo que `Party` exige. No hace falta adivinar nada. Go lo hace exactamente así y
no lleva `implements`.

**Se declara porque no es un hecho: es un compromiso.**

| | Qué dice | Qué pasa cuando deja de cumplirse |
|---|---|---|
| **computado** | *«esta entidad, hoy, cubre lo que `Party` exige»* | deja de cubrirlo, **y no pasa nada** |
| **declarado** | *«esta entidad se compromete a cubrirlo»* | `OOS9001`, y la compilación se rompe |

Sin la declaración, borrar una propiedad haría que la entidad dejara de satisfacer `Party` en
silencio, y una regla que apunta a `Party` dejaría de alcanzarla **sin que nadie lo note**.
Es el mismo argumento que `OOS8002` y `OOS9004`, por tercera vez:

> **Lo que deja de gobernar tiene exactamente el mismo aspecto que lo que gobierna.**

Así que la asimetría tiene nombre en cada lado y no es una incoherencia:

| | Naturaleza | Cómo se obtiene |
|---|---|---|
| `I ⊑ J` entre interfaces | una relación entre **dos definiciones**, estable | **se computa** |
| `E implements I` | un compromiso sobre **algo que cambia** | **se declara** |

---

## 5. Por qué no absorbe `nature`

El borrador de esta versión decía que `entity` y `event` pasarían a ser dos interfaces
incorporadas y que `OOS2010` se absorbería en `OOS9001`. **La implementación lo refutó**, y
la refutación es lo que fija qué clase de documento es este.

Basta intentar escribirlo:

```yaml
kind: Interface
metadata: { name: Entity, namespace: oos }
spec:
  requires: [???]        # `primaryKey` no es un concepto
```

`requires` nombra conceptos. `primaryKey` no lo es: es una declaración **estructural** sobre
qué propiedades identifican un registro, y no dice qué significa ninguna de ellas. Admitir
las dos clases de exigencia habría hecho que un solo documento dijera dos cosas con la misma
palabra — el error contra el que va toda la versión, cometido donde menos se ve.

| Plano | Pregunta | Quién la gobierna |
|---|---|---|
| **estructural** | ¿esta entidad tiene con qué identificarse? | `nature` · `OOS2010`, **sin cambios** |
| **de significado** | ¿esta entidad tiene lo que `Party` exige? | `implements` · `OOS9001` |

> **Un `Interface` nombra una forma en significado, no en estructura.**

Que las dos se parezcan desde lejos —un nombre, una forma, miembros obligatorios— es lo que
hacía atractiva la absorción, y por eso conviene tener la frase escrita.

---

## 6. El tercer eje de un objetivo

Un `Ruleset` gana `implements` junto a `atLeast` y `named`:

```yaml
spec:
  targets:
    - implements: [acme.Party]
```

| Objetivo | Nombra un conjunto por |
|---|---|
| `atLeast` | **clasificación** |
| `named` | **identidad** |
| `implements` | **forma** |

No son tres maneras de decir lo mismo: son tres criterios distintos, y solo el tercero
permite gobernar quince casi-duplicados de quince sistemas con una regla sin renombrar
ninguno. La monotonía se comporta igual que en los otros dos — si `Customer implements
Party`, una regla sobre `Party` lo alcanza.

### 6.1 · Y lo que **no** alcanza

> Selecciona **las propiedades que mapean a los conceptos que la interfaz exige**, en toda
> entidad que declare implementarla **o implementar cualquier forma que la subsuma** (§4.2).
> **No toda propiedad de esas entidades.**

Es la parte fácil de hacer mal, y hacerla mal es inseguro. Una regla sobre `Party` habla de
nombres legales y correos personales; si `crm.Customer` tiene además una `internalNote`
clasificada `high`, **esta regla no la cubre** y `OOS8001` tiene que seguir exigiendo que
alguien lo haga.

Acreditar cobertura sobre lo que la interfaz no nombra sería acreditar lo que nadie exigió —
el mismo error, en el mismo sentido, que la cobertura por orden de retículo que ya hubo que
corregir una vez.

### 6.2 · Vacío frente a inexistente

Dos fallos distintos, y solo uno es una errata:

| | Código |
|---|---|
| el objetivo nombra una interfaz **que no existe** | `OOS2001` |
| la nombra bien y **ninguna entidad la implementa** | `OOS8002` |

Por eso toda interfaz declarada figura en el índice de formas aunque nadie la implemente: sin
esa distinción, un `Ruleset` que apunta a `acme.Patry` diría lo mismo que uno que apunta a
una forma real que aún nadie adoptó.

---

## 7. Lo que este documento no puede ver

Una entidad que **declara** implementar y no cumple es un fallo visible: está escrito en el
documento y una revisión lo encuentra.

Lo que **no** es visible —y es el modo de fallo real de un patrimonio sucio— es una columna
que **es** un `personalEmail` y que nadie mapeó. Eso el compilador no puede detectarlo, y no
por falta de esfuerzo: exigiría adivinar significado desde un nombre, y `02-entity` ya decidió
que **un análisis sólido no depende de parsear cadenas**.

> **El compilador comprueba que las formas declaradas se cumplan. Que se declararan las
> formas correctas lo responde un dueño.**

Tercera vez que la frontera cae en el mismo sitio —con `OOS8001` y con `OOS4001`— y ya no es
casualidad: **lo declarado es decidible, lo omitido no lo es nunca.**

---

## 8. Errores

| Código | Condición | De dónde sale |
|---|---|---|
| `OOS1004` | `requires` ausente o vacío | el esquema lo expresa entero |
| `OOS2001` | `requires` o `implements` apuntan a algo inexistente | reservado en v1alpha1 |
| `OOS8002` | un objetivo `implements` que no casa con ninguna entidad | v1alpha3, sin cambios |
| `OOS9001` | una entidad declara una forma y no la satisface | **nuevo** |

**Un código nuevo de cuatro**, y `OOS2010` no se retira: §5.

Y la subsunción de §4.2 **no aparece en esta tabla**, que es el resultado que la hace buena:
computar `I ⊑ J` no puede fallar —es una inclusión de conjuntos entre dos documentos que ya
validaron— así que no hay nada que diagnosticar. Un `extends` declarado sí habría traído un
código, para el caso de declarar una extensión que no se cumple.

**Lo derivable no se declara, y por eso no se puede escribir mal.**

---

## 9. Una `Function` **no** puede apuntar a una interfaz

Es el titular de Foundry —*los flujos apuntan a la interfaz, no a los tipos concretos*— y
sería lo que convertiría una `Function` escrita una vez en reutilizable sobre quince
entidades sucias. La respuesta es **no**, y no por prudencia: por **dónde cae el cuantificador
respecto de la frontera del paquete**.

### 9.1 · El cuantificador está del lado equivocado

Las dos construcciones parecen simétricas y no lo son:

| | Qué garantiza | Dónde se comprueba |
|---|---|---|
| `Ruleset` → interfaz | *toda propiedad clasificada de esta selección tiene regla* | **donde vive el dato** |
| `Function` → interfaz | *escribo con integridad suficiente para mi destino* | **donde se define la función** |

Una regla se comprueba en la unidad de compilación que contiene las entidades, y ahí el
conjunto de implementadores **está completo por construcción**: son los del paquete. Que otro
paquete añada uno no puede falsear nada aquí, porque ese paquete computa su propia cobertura
sobre sus propias entidades.

Una función **se exporta**. Su garantía —`I(f) ⊒ I(destino)`— tendría que sostenerse frente al
join de la integridad de *todos* los implementadores, y los que importan son los del paquete
que la **invoca**, que la definición nunca vio. Un paquete C que añade una entidad
implementando `Party` con más integridad exigida **falsea una garantía compilada en el paquete
A**, y A no se recompila.

> Una propiedad universal sobre un conjunto **abierto** no es estable bajo extensión. La de la
> regla lo es porque su conjunto se cierra dentro de cada unidad; la de la función no, porque
> el suyo se abre justo al cruzar la frontera.

**Y tiene precedente exacto.** Rust prohíbe implementar un rasgo ajeno para un tipo ajeno —la
*orphan rule*— con un objetivo declarado: que se puedan tomar dos crates cualesquiera y
combinarlos sin que aparezcan implementaciones incompatibles. Es una restricción sobre **dónde
pueden vivir los implementadores**, aceptada a cambio de conservar el razonamiento global.

La restricción equivalente aquí sería exigir que todos los implementadores de una interfaz
fueran visibles desde la función: **un mundo cerrado**. Y OOS no lo asume — importar un
vocabulario ajeno e implementarlo en casa es el caso de uso central de esta versión entera.

De los dos precios se paga el que no rompe nada: **la función se queda apuntando a destinos
concretos.**

### 9.2 · Y por qué la regla sí puede

Conviene comprobarlo en vez de suponerlo, porque si el argumento de arriba valiera también
para `Ruleset`, §6 sobraría.

No vale, y la diferencia es que **una regla no se invoca**. Es una restricción que se evalúa
donde está el dato: si un paquete importa un `Ruleset` que apunta a `Party` y tiene entidades
que la implementan, su propia compilación las selecciona y comprueba su cobertura. Si no las
tiene, el objetivo no casa con nada **en ese paquete** y sale `OOS8002` — allí, donde alguien
puede arreglarlo.

Añadir un implementador solo puede **agrandar** el conjunto gobernado, y agrandar es la
dirección segura. Añadir un implementador a una interfaz que una función escribe puede
**subir el suelo de integridad exigido**, y eso invalida hacia atrás.

### 9.3 · Qué la reabriría

Que aparezca una forma de escribir el efecto que se compruebe **en el punto de invocación** y
no en el de definición: la función queda genérica y el chequeo de integridad se instancia por
destino, como una monomorfización. Es construible, y **es una pregunta de v1alpha2**, cuyo
alcance está cerrado. Dejar escrito el mecanismo evita volver a discutirlo desde cero.

---

## 10. Aplazado

**Interfaces incorporadas.** No las hay, y §5 dice por qué la vía obvia no sirve. Si alguna
vez hicieran falta exigencias estructurales compartidas, **no serían un `Interface`**: serían
otro documento, y lo primero que habría que justificar es por qué no basta con `nature`.

**Interfaces con cardinalidad.** *«`Party` exige al menos un `contactPoint`»* no es
expresable: `requires` es un conjunto de conceptos y no cuenta. Sería representable —un mapa
`concepto → mínimo`— y no hay caso medido. **P7**.
