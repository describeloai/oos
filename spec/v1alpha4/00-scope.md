# OOS v1alpha4 — alcance

**Estado:** borrador de alcance. Gobierna los documentos que declaran su `apiVersion`, y es
**alpha**: sin garantías de compatibilidad.

| | |
|---|---|
| `00-scope` | **este documento** — qué entra en v1alpha4, qué no, y qué queda abierto |
| [`01-significado`](01-significado.md) | el núcleo — el régimen de significado, del que se deriva todo lo demás |
| `02-property` · `03-interface` | los documentos — **pendientes** |

**Estado de la implementación.** Los esquemas, la suite y el motor van por delante de esos
dos documentos, y a propósito: §7 de este alcance exige enfrentar el vocabulario a algo que
lo use *«antes de escribir los esquemas»*, y escribirlos fue esa prueba. Doce casos en verde
y **tres correcciones que solo aparecen al usarlo** — §4.2, §5 y §7 — están medidas abajo.

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

Y es la primera en la que **una parte del vocabulario existe para que otro la escriba**, así
que conviene fijar qué clase de documento es esto antes de las piezas:

> **El molde no dice lo que una herramienta debe hacer. Dice lo que tiene que ser cierto — y
> entonces la herramienta no tiene elección.**

Define **qué se puede decir, qué obliga decirlo y qué tiene que cumplir lo dicho**. No define
qué se introspecciona, si hay un modelo de por medio ni cómo se pregunta
([`01-significado`](01-significado.md) §2).

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

Con el guardarraíl escrito antes de cometer el error, no después: una con `is` **NO DEBE**
redeclarar `type`. Sí **PUEDE** escribir `labels`, y solo para **elevar** — `type` es una
igualdad y `labels` un orden, y esa asimetría es lo que hace que `OOS4012` valga aquí sin
cambiar una letra.

Y el mapeo es donde **`confidence` encuentra por fin su usuario**. Está en
`basic.schema.json` desde v1alpha1 —*«confianza de una inferencia automática, presente solo
en `DRAFT`»*— y llevaba cuatro versiones sin que ningún documento lo referenciara:

```yaml
properties:
  email: { is: gdpr.personalEmail, confidence: 0.87 }
```

De ahí sale la regla que convierte la revisión humana en una condición de compilación:
**un documento que no está en `DRAFT` no puede contener una sola conjetura** (`OOS9003`).
Promover exige haber resuelto cada propuesta, y eso vale igual para un inductor ajeno que
para el nuestro — que es exactamente lo que el molde tiene que conseguir
([`01-significado`](01-significado.md) §4.2.1).

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

### 4.3 · Y `nature` **no** se disuelve

Este alcance decía que `entity` y `event` pasarían a ser dos interfaces incorporadas y que
`OOS2010` se absorbería. **La implementación lo refutó**: `requires` nombra conceptos y
`primaryKey` no lo es. Una interfaz nombra una forma **en significado**, no en estructura, y
mezclar las dos habría hecho que un solo documento dijera dos cosas con la misma palabra —
el error contra el que va toda la versión.

`OOS2010` se queda: [`01-significado`](01-significado.md) §5.

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

### Cerradas

**Acuñar frente a mapear** — y se cierra **sacándola de aquí**. Son la misma clase de acto:
las dos son inferencias, las dos llevan `confidence` y las dos caen bajo `OOS9003`. Lo que
las separa es la consecuencia, no el mecanismo.

Y la intuición de que acuñar deba «costar más» **no es expresable en el molde**: distinguir
cuatro mil conceptos legítimos de sesenta mal unificados exigiría reconocer *sameness* no
declarada, que es indetectable por decisión de v1alpha1. Lo que el molde sí hace es exigir que
nada acuñado sobreviva a la promoción sin un humano, y que un concepto que nadie usa no
compile (`OOS9004`).

El resto —sesgar a quien propone hacia mapear, mostrar juntas las columnas candidatas para que
la unificación se decida una vez— es **ergonomía del inductor**
([`01-significado`](01-significado.md) §4.2.2), y ponerlo aquí habría sido el error que §2
existe para evitar.

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

### 7.1 · Ejecutada, y qué encontró

Se ejecutó en la forma que no necesita base de datos: **escribir a mano el paquete que un
inductor emitiría** y exigir que compile —`valid/draft-carries-confidence`—, junto con los
once casos que rodean esa forma. El vocabulario sobrevive: un concepto basta para expresar lo
que la introspección encuentra, y el mapeo no pide nada que en ese momento no se tenga.

Y encontró tres defectos, ninguno visible leyendo:

| | Qué | Consecuencia |
|---|---|---|
| **1** | §4.2 prohibía `labels` junto a `is` **y** permitía elevar la clasificación. Elevar exige escribirla | la spec se contradecía; se resolvió con la asimetría `type`/`labels` |
| **2** | §5 disolvía `nature` en interfaces incorporadas. `requires` nombra conceptos y `primaryKey` no lo es | `OOS2010` se queda; el registro crece en tres y no en cuatro |
| **3** | `confidence` era un `number` en `basic.schema.json` **desde v1alpha1** — y un decimal sin comillas no tiene forma canónica | `OOS6003` contra el primer caso que lo usó |

El tercero merece leerse dos veces: **llevaba cuatro versiones contradiciendo una regla del
propio proyecto**, y era invisible porque ningún documento referenciaba el campo. La misma
decisión, con las mismas palabras, ya estaba escrita en `Resolution.threshold` de v1alpha2 —
que llegó antes al problema por el camino contrario: tenía usuario desde el primer día.

> Un `$def` sin usuario no está esperando: **está sin comprobar.**
