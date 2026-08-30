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
| **acciones** | en Foundry una interfaz lleva propiedades, enlaces y *actions*. Aquí una acción es una `Function`, y que una `Function` pueda apuntar a una interfaz es una pregunta de **v1alpha2** — §7 |
| **herencia** | que `Employee implements Person implements Party` sea transitivo es plausible y no está escrito. Sin caso de uso medido, **P7** — §7 |
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

- Es una lista de **nombres cualificados de `Property`**. Nunca de otra `Interface` —la
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
> entidad que declare implementarla. **No toda propiedad de esas entidades.**

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

---

## 9. Aplazado

**¿Puede una `Function` apuntar a una interfaz?** Es el titular de Foundry —*los flujos
apuntan a la interfaz, no a los tipos concretos*— y sería lo que convertiría una `Function`
escrita una vez en reutilizable sobre quince entidades sucias. **Toca v1alpha2, cuyo alcance
está cerrado**, y por eso no se resuelve metiéndolo aquí. La pregunta que hay que contestar
antes: los efectos de una función se declaran sobre destinos concretos y `OOS7008` exige una
sola fuente física — una interfaz implementada por entidades de tres fuentes rompería eso, o
lo obligaría a significar otra cosa.

**Herencia entre interfaces.** Si aparece la presión. Hoy, declarar `implements: [Person,
Party]` expresa lo mismo con una línea más y sin inventar un cierre transitivo.

**Interfaces incorporadas.** No las hay, y §5 dice por qué la vía obvia no sirve. Si alguna
vez hicieran falta exigencias estructurales compartidas, **no serían un `Interface`**: serían
otro documento, y lo primero que habría que justificar es por qué no basta con `nature`.
