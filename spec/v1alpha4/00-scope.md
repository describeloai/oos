# OOS v1alpha4 — alcance

**Estado:** borrador de alcance. Gobierna los documentos que declaran su `apiVersion`, y es
**alpha**: sin garantías de compatibilidad.

| | |
|---|---|
| `00-scope` | **este documento** — qué entra en v1alpha4, qué no, y qué queda abierto |
| [`01-significado`](01-significado.md) | el núcleo — el régimen de significado, del que se deriva todo lo demás |
| [`02-property`](02-property.md) | el concepto — su superficie normativa |
| [`03-interface`](03-interface.md) | la forma — su superficie normativa |

**Los esquemas, la suite y el motor se escribieron antes que `02` y `03`**, y a propósito:
§7 de este alcance exige enfrentar el vocabulario a algo que lo use *«antes de escribir los
esquemas»*, y construirlo fue esa prueba. Doce casos en verde y **tres correcciones que solo
aparecen al usarlo** — §7.1. Los dos documentos de abajo se redactaron después, con la
implementación delante, que es el orden que este proyecto lleva cuatro versiones defendiendo.

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
Aquí una acción es una `Function`, y **una `Function` no puede apuntar a una interfaz**: la
garantía de una función se compila donde se define y se invoca en otra parte, así que
dependería de un conjunto de implementadores que crece fuera de su vista. §6.1.

**Inferir el concepto de una propiedad.** Adivinar significado desde un nombre basaría la
solidez en parsear cadenas, y `02-entity` ya decidió que no. Un inductor **propone** —y para
eso `basic.schema.json` ya tiene `confidence`, presente solo en `DRAFT`—; el mapeo lo
confirma un humano en un commit.

**Y esta especificación no dice cómo se induce.** Qué introspecciona una herramienta, si usa
un modelo y cómo pregunta son **ergonomía del motor**, no del artefacto — la frontera que
`docs/DESIGN.md` §3 fija: *«OOS define el artefacto; ORE define la ergonomía y la
ejecución»*. Aquí solo se define **el molde**: qué es un concepto, qué es una forma y qué
tiene que cumplir lo que se escriba.

**Un campo de herencia entre interfaces.** No hace falta: `I ⊑ J` **se computa** de la
inclusión entre sus `requires`, así que un `extends` sería un segundo sitio donde decir lo que
`requires` ya dice — **P2**. La relación sí existe y se usa; lo que no entra es declararla.
§6.3.

**Fusionar, normalizar o limpiar datos.** Un mapeo dice que dos cosas significan lo mismo. No
las hace iguales. Fusionar registros es `Resolution`, y es otra fila de la misma tabla.

---

## 6. Decisiones

**No queda ninguna abierta.** Las tres que quedaban se cerraron con teoría delante, y las
tres se decidieron por el mismo criterio: **preguntar de qué clase de objeto se está
hablando**, en vez de sopesar comodidades.

| | Decisión | Lo que la decidió |
|---|---|---|
| **1** | una `Function` **NO** puede apuntar a una interfaz | el cuantificador cae del lado equivocado de la frontera del paquete |
| **2** | un concepto **SÍ** puede exigir gobierno | la regulación clasifica por **categoría**, no por nivel |
| **3** | la herencia entre interfaces **se computa**, no se declara | un `Interface` es una *clase definida*: su jerarquía es inferida por construcción |

### 6.1 · `Function` sobre interfaz — no, y por qué no es prudencia

Una regla y una función parecen simétricas sobre una interfaz, y no lo son: **una regla se
evalúa donde vive el dato; una función se compila donde se define y se invoca en otra parte.**
La garantía de la regla se cierra dentro de cada unidad de compilación; la de la función
—`I(f) ⊒ I(destino)`— tendría que sostenerse frente a un conjunto de implementadores que
**crece en paquetes que la definición nunca verá**.

> Una propiedad universal sobre un conjunto **abierto** no es estable bajo extensión.

Rust paga ese precio con la *orphan rule*, que restringe **dónde pueden vivir los
implementadores** para que dos crates cualesquiera se puedan combinar sin sorpresas. La
restricción equivalente aquí sería un mundo cerrado, y OOS no lo asume: importar vocabulario
ajeno e implementarlo en casa es el caso de uso central de esta versión.

Detalle y la vía que lo reabriría —una instanciación por destino, en el punto de invocación—
en [`03-interface`](03-interface.md) §9.

### 6.2 · Exigir gobierno desde el concepto — sí, y cierra el hueco de la versión

El artículo 9 del RGPD enumera **categorías** —salud, biometría, convicciones— y sus
obligaciones se activan en cuanto el dato cae en una de ellas, **con independencia de lo
sensible que sea en ese contexto**. La obligación va pegada a *qué es* el dato, no a *cuánto*
pesa, y un `requiresGovernance` que solo cuelgue del retículo no puede expresarlo.

Y es exactamente el hueco que esta versión existe para cerrar:

> v1alpha3 gobierna **lo que alguien acertó a etiquetar**.

Con la exigencia solo en el nivel, un dato de salud mal clasificado se escapa de su obligación
y el paquete compila. Con la exigencia en el concepto, **mapearlo basta**. Se compone por
unión —asociativa, conmutativa e idempotente, luego el orden de los orígenes no puede cambiar
el resultado— y **no trae código nuevo**: falla con el `OOS8001` que ya existía.

Detalle en [`02-property`](02-property.md) §3.3.

### 6.3 · Herencia entre interfaces — se computa

`I ⊑ J` si y solo si `J.requires ⊆ I.requires`. Es un teorema sobre dos documentos, no una
declaración, y un `extends` sería un segundo sitio donde decirlo con la posibilidad de
contradecirlo — **P2**.

**La disciplina ya lo había contestado.** En OWL, una clase con condiciones necesarias y
suficientes es una *clase definida* y el razonador **computa** su jerarquía; la asertada se
reserva para las clases primitivas, cuya pertenencia no se puede calcular. Un `Interface` es
una clase definida por construcción. Go llegó a lo mismo desde el otro extremo: sin palabra
clave, por inclusión de conjuntos.

Lo que obliga a contestar esa decisión es por qué `implements` **sí** se declara, y la
respuesta afina el régimen entero: **no es un hecho, es un compromiso**. Computado, dejar de
satisfacer una forma no produce nada; declarado, produce `OOS9001`. Tercera vez que aparece la
misma ley — *lo que deja de gobernar tiene el mismo aspecto que lo que gobierna*.

Detalle en [`03-interface`](03-interface.md) §4.2 y §4.3.

### 6.4 · Lo que cuesta construirlas

Ninguna de las tres exige un plano nuevo, y **ninguna añade un código**:

| | Qué toca |
|---|---|
| **1** | nada. Es una prohibición que ya se cumple por no existir el campo |
| **2** | un campo en el esquema de `Property`, y un origen más en el cálculo de cobertura |
| **3** | una clausura por inclusión de conjuntos al resolver un objetivo `implements` |

### Cerradas antes

**`expression` y `derivedFrom` junto a `is`** — y se cierra porque **medirlo destapó un
agujero**. Los dos campos conviven sin problema y `OOS4015` no se enturbia; lo que fallaba
era la clasificación.

La propagación tiene dos pasadas: la primera hereda —de la entidad, del `datasource` y, desde
v1alpha4, del concepto— y la segunda computa el `join` de una derivada empezando de cero. La
segunda **pisaba lo heredado del concepto**, así que **añadir `derivedFrom` a una propiedad
mapeada le borraba la clasificación en silencio**: lo que sin `derivedFrom` rompía con
`OOS8001` compilaba sin una sola regla.

Cerrado en la dirección que se sigue de lo que un concepto es: **entra en el `join` como un
origen más y solo puede subir**, porque un concepto compartido fija *un suelo de
clasificación, no un valor* ([`02-property`](02-property.md) §5). Caso
`valid/derived-mapping-keeps-its-floor`.

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
