# OOS v1alpha4 — alcance

**Estado:** borrador de alcance. Gobierna los documentos que declaran su `apiVersion`, y es
**alpha**: sin garantías de compatibilidad.

| | |
|---|---|
| `00-scope` | **este documento** — qué entra en v1alpha4, qué no, y qué queda abierto |
| [`01-significado`](01-significado.md) | el núcleo — el régimen de significado, del que se deriva todo lo demás |
| `02-property` · `03-interface` | los documentos — **pendientes** |

---

## 1. La tesis

Cada versión gobierna un verbo, y aporta **una** regla:

| | Gobierna | Regla |
|---|---|---|
| **v1alpha1** | lo que se puede **saber** | `L ⊑ C` |
| **v1alpha2** | lo que se puede **causar** | `I(f) ⊒ I(destino)` |
| **v1alpha3** | qué debe **sostenerse** | `L(x) ⊒ n ⟹ ∃r` |
| **v1alpha4** | **qué es la misma cosa** | `E implements I ⟹ ∀c ∈ I . ∃p ∈ E . is(p) = c` |

Y la cuarta no es la última capa: es **la que faltaba debajo**. Toda la maquinaria de
v1alpha1 y v1alpha3 opera sobre etiquetas, y nada comprobaba que la clasificación fuera
consistente — porque hasta ahora **no había forma de decir que dos propiedades son la misma
cosa**.

> **v1alpha3 gobierna lo que alguien acertó a etiquetar.**

Ese es el hueco, y esta versión existe para cerrarlo.

---

## 2. Por qué ahora, y no antes

Porque una ontología de un patrimonio real **no se escribe: se induce**, y sin vocabulario
controlado la inducción produce ruido.

Un inductor —una herramienta que introspecciona esquemas, o una que lee documentos, con IA o
sin ella— recorre miles de columnas. La pregunta que decide si eso sirve para algo es **qué
escribe**:

| | Sin vocabulario | Con vocabulario |
|---|---|---|
| lo que produce | una etiqueta **adivinada** por columna | una **referencia** a un concepto decidido |
| a escala | cuatro mil conjeturas independientes | cuatro mil mapeos sobre sesenta conceptos |
| lo que se le pregunta a un humano | *«¿qué etiqueta merece esta columna?»* | *«¿esta columna es un `personalEmail`?»* |
| revisable | **no** | **sí** |

Cinco preguntas sobre conceptos se contestan; cinco preguntas sobre etiquetas son cinco
ensayos. Y la diferencia no es de comodidad — es si el resultado se puede **revisar**.

**Esto no es una conjetura nuestra.** El *Context Ontology Accelerator* de AWS —que induce
ontologías con IA y las somete a revisión humana— crea ontologías *«desde cero **o ancladas a
estándares de industria o definidos por el cliente**»*, y llama a lo segundo **grounding**.
Llegaron al mismo sitio por otro camino: una IA que redacta sin vocabulario produce texto
libre; anclada a uno, produce mapeos.

Un paquete de `Property` publicado **es ese anclaje**.

> Un concepto compartido no es una comodidad de modelado: es el sustrato sin el cual inducir
> una ontología produce ruido en lugar de ontología.

---

## 3. Lo que hay que añadir son dos documentos, y casi nada más

Casi todo está ya, y en el sitio equivocado solo por el nivel:

| | Estado |
|---|---|
| el patrón del **mapeo** | **existe** — `Binding` lo hace hacia la fuente física ([`01-significado`](01-significado.md) §2) |
| la dirección de la **herencia** | **existe** — `OOS4012`: se puede elevar, no rebajar |
| la **clasificación** que un concepto declara | **existe** — el retículo, sin cambios |
| el **consumidor** de una forma | **existe** — un `Ruleset` gana un tercer eje de objetivo |
| **el concepto** y **la forma** | **faltan**, y son lo único |

---

## 4. Los documentos

### 4.1 · `Property` — el concepto

Qué **es** un dato: `type`, `labels`, `description`. No dónde vive ni cómo se llama. Con
`namespace`, y por tanto con dueño, versión y digest — un paquete regulatorio puede publicar
sesenta conceptos con su clasificación ya decidida.

```yaml
kind: Property
metadata: { name: personalEmail, namespace: gdpr }
spec:
  type: String
  labels: { gdpr.sensitivity: high }
```

Y en la entidad, **el nombre es suyo y el significado del concepto**:

```yaml
properties:
  email: { is: gdpr.personalEmail }
```

Con el guardarraíl escrito antes de cometer el error, no después: **una propiedad declara
localmente o referencia un concepto, nunca las dos.** Una con `is` **NO DEBE** redeclarar
`type` ni `labels` — es `OOS4008` un nivel más arriba.

### 4.2 · `Interface` — la forma

Un conjunto de entidades nombrado por su forma, expresada **en conceptos y no en nombres**:

```yaml
kind: Interface
metadata: { name: Party, namespace: acme }
spec:
  requires: [gdpr.personalEmail, acme.legalName]
```

Que exija el concepto es lo que permite que quince casi-duplicados de quince sistemas
implementen `Party` **conservando cada uno su vocabulario**. Sin eso hay que limpiar antes de
gobernar, que es el orden imposible.

### 4.3 · Y `nature` se disuelve

`entity` y `event` pasan a ser **dos interfaces incorporadas**, y `OOS2010` deja de ser una
regla propia para convertirse en el caso general. **El registro encoge**:
[`01-significado`](01-significado.md) §4.

---

## 5. Lo que NO entra

**Acciones en una interfaz.** En Foundry una interfaz lleva propiedades, enlaces y *actions*.
Aquí una acción es una `Function`, y que una `Function` pueda apuntar a una interfaz es una
pregunta de **v1alpha2** — va como decisión abierta, no se resuelve metiéndola aquí.

**Inferir el concepto de una propiedad.** Adivinar significado desde un nombre basaría la
solidez en parsear cadenas, y `02-entity` ya decidió que no. Un inductor **propone** —y para
eso `basic.schema.json` ya tiene `confidence`, presente solo en `DRAFT`—; el mapeo lo
confirma un humano en un commit.

**Y esta especificación no dice cómo se induce.** Qué introspecciona una herramienta, si usa
un modelo y cómo pregunta son **ergonomía del motor**, no del artefacto — la frontera que
`docs/DESIGN.md` §3 fija: *«OOS define el artefacto; ORE define la ergonomía y la
ejecución»*. Aquí solo se define **el molde**: qué es un concepto, qué es una forma y qué
tiene que cumplir lo que se escriba.

**Herencia entre interfaces.** Que `Employee implements Person implements Party` sea
transitivo es plausible y no está escrito. Sin caso de uso medido, no entra — **P7**.

**Fusionar, normalizar o limpiar datos.** Un mapeo dice que dos cosas significan lo mismo. No
las hace iguales. Fusionar registros es `Resolution`, y es otra fila de la misma tabla.

---

## 6. Decisiones abiertas

1. **¿Puede una `Function` apuntar a una interfaz?** Es el titular de Foundry —*los flujos
   apuntan a la interfaz, no a los tipos concretos*— y es lo que convertiría una `Function`
   escrita una vez en reutilizable sobre quince entidades sucias. Toca v1alpha2, cuyo alcance
   está cerrado.
2. **¿Puede un concepto exigir gobierno?** Un `Property` declara `labels`; ¿puede declarar
   también `requiresGovernance`, o eso es solo del retículo? Si pudiera, un paquete
   regulatorio traería concepto **y** exigencia en un solo documento.
3. **Herencia entre interfaces**, si aparece la presión (§5).
4. **Qué pasa con `expression` y `derivedFrom`** cuando la propiedad mapea a un concepto:
   siguen siendo de la propiedad concreta, pero `OOS4015` compara lecturas contra
   `derivedFrom` y habrá que comprobar que el mapeo no lo enturbie.

---

## 7. La prueba de fuego

Antes de dar por buena esta versión hay una comprobación que no es una suite y que decide si
el diseño sirve:

> **Un inductor tiene que poder escribir contra este vocabulario.**

Si al enfrentarlo a un esquema real resulta que un concepto no basta para expresar lo que la
introspección encuentra —o que el mapeo pide información que nadie tiene en ese momento— el
vocabulario está mal, y es mejor saberlo antes de escribir los esquemas que después.

La instancia que la ejecutará es `ore discover`, y eso es un detalle de **quién** hace la
prueba: la propiedad que se comprueba es del molde y la tendría que satisfacer cualquier
inductor, incluida una importación desde una herramienta ajena.

Es el mismo método que destapó los tres defectos de la ronda anterior: **el diseño se decide
con contacto, no con analogía.**
