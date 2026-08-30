# OOS v1alpha4 — alcance

**Estado:** borrador de alcance. Gobierna los documentos que declaran su `apiVersion`, y es
**alpha**: sin garantías de compatibilidad.

| | |
|---|---|
| `00-scope` | **este documento** — qué entra, qué no, y **qué falta para estar listo** (§8) |
| [`01-significado`](01-significado.md) | el núcleo — el régimen de significado, del que se deriva todo lo demás |
| [`02-property`](02-property.md) | el concepto — su superficie normativa |
| [`03-interface`](03-interface.md) | la forma — su superficie normativa |

**Estado: doce de doce.** El vocabulario está completo, no queda ninguna decisión abierta y
la suite da 19/19 — y aun así la versión **no está lista**, porque `Property` e `Interface`
atraviesan siete de las doce estaciones de la cadena. y desde la fase 4 **atraviesan las doce**, con
28 casos que las certifican. Lo que las cuatro fases encontraron —y una de esas cosas no es
de esta versión ni de ninguna— está en §8.5 y §8.6. La definición de listo, la medición y las
cuatro fases están en **§8**.

Los esquemas, la suite y el motor se escribieron **antes** que `02` y `03`, y a propósito: §7
exige enfrentar el vocabulario a algo que lo use *«antes de escribir los esquemas»*, y
construirlo fue esa prueba — encontró **tres defectos que no se ven leyendo** (§7.1). Los dos
documentos se redactaron después, con la implementación delante.

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

---

## 8. Listo para v1

La prueba de fuego dice si el **vocabulario** sirve. No dice si la versión está terminada, y
esas son dos preguntas distintas: v1alpha4 pasó la primera hace tres rondas y **no ha pasado
la segunda**, porque hasta ahora nadie había escrito en qué consiste.

Este apartado la escribe. Y lo primero que hay que decir es que **la pregunta no era de
v1alpha4**:

> **El criterio de «listo» nunca estuvo escrito, y por eso cada versión terminó en una
> estación distinta — sin que ninguna lo dijera.**

### 8.1 · La cadena tiene estaciones, y son doce

Un `kind` no está terminado cuando su documento valida. Está terminado cuando **atraviesa la
cadena entera**, y la cadena no es una metáfora: cada estación es un comando y una garantía.

| | Estación | Comando | Qué tiene que ser cierto |
|---|---|---|---|
| **1** | despacho | — | el `kind` se reconoce y elige su esquema por `apiVersion` |
| **2** | forma | `validate` | claves, obligatoriedad y exclusiones — `OOS1004` |
| **3** | referencias | `validate` | lo que nombra existe — `OOS2001` · `OOS2005` |
| **4** | tipos | `validate` | lo que declara es un tipo de OOS — `OOS3xxx` |
| **5** | flujo | `validate` | su clasificación **se propaga** — `OOS4xxx` |
| **6** | gobierno | `validate` | la cobertura lo tiene en cuenta — `OOS8xxx` |
| **7** | significado | `validate` | la regla de su versión — `OOS9xxx` |
| **8** | forma canónica | `compile` | sus **conjuntos se ordenan** — **G1** |
| **9** | sellado | `compile` | entra en el bundle con digest propio |
| **10** | compatibilidad | `diff` | sus cambios se clasifican por eje — **G2 en el tiempo** |
| **11** | emisión | `export` | lo emitido **refleja lo que el documento dice** |
| **12** | dependencia | `validate` | funciona igual cuando viene de otro paquete |

Las siete primeras son *«¿es correcto?»*. Las cinco últimas son *«¿sirve para algo?»*, y son
justo las que se olvidan, porque un `kind` que llega a la séptima **ya se siente terminado**:
compila, falla cuando debe y tiene casos en verde.

### 8.2 · Dónde está v1alpha4, medido

| Estación | | |
|---|---|---|
| 1 – 7 | ✅ | la herencia llega a la propagación y a la cobertura |
| 8 · forma canónica | ✅ | **fase 1, hecha.** Los tres campos entran en `CONJUNTOS`, y el retículo de v1alpha3 con ellos — §8.5 |
| 9 · sellado | ✅ | `Property:…` e `Interface:…` aparecen en el bundle con digest propio, y ya **estable** |
| 10 · compatibilidad | ✅ | **fase 2, hecha.** `Shape` gana conceptos y formas, con **un solo código nuevo** — §8.5 |
| 11 · emisión | ✅ | **fase 3, hecha.** El emisor resuelve `is` contra los conceptos **del propio bundle** — §8.5 |
| 12 · dependencia | ✅ | **fase 4, hecha.** El concepto cruza la frontera del paquete con su tipo, su clasificación **y su exigencia** — §8.5 |

Las tres que fallan se miden, no se opinan:

Y el estado de partida, que ya no es el actual, merece quedar escrito porque era el más
elocuente de los tres:

```
export a ODCS de una propiedad mapeada
  {"name": "email"}                        ← ni tipo ni clasificación
  {"name": "id", "x-oos-type": "String"}   ← declarada localmente
```

**El contrato que producía una propiedad mapeada era peor que el de una escrita a mano.**
Usar `is` empeoraba lo que el consumidor recibía, que es lo contrario exacto de lo que la
versión promete.

### 8.3 · Y no es un problema de esta versión

Al medir las estaciones 8 y 10 sobre todo lo que existe, sale esto:

| Versión | `kind` | 8 · canónica | 10 · diff | 11 · emisión |
|---|---|---|---|---|
| **v1alpha1** | `Entity` · `Binding` · `Lattice` · `ConduitPolicy` | ✅ | ✅ | ✅ |
| **v1alpha2** | `Function` · `Resolution` | ✅ | ✅ | — no hay destino |
| **v1alpha3** | `Ruleset` | ✅ | ✅ | ✅ `quality` de ODCS |
| **v1alpha4** | `Property` · `Interface` | ✅ | ✅ | ✅ |

**Las cuatro filas están en verde, y ninguna lo estaba cuando este apartado se escribió.**
La tabla original —v1alpha1 completo, v1alpha4 vacío— resultó ser falsa por los dos extremos.

**La primera fila costó una segunda medición.** Al preguntarse si todo estaba realmente en
verde, resultó que la forma canónica de **v1alpha1** también estaba rota: `derivedFrom`,
`reserved`, `uniqueKeys` y `support` daban dos digests para el mismo contenido. La versión
cerrada no había llegado al final tampoco — solo había llegado más lejos. Está arreglado, con
su caso, y la exigencia de `90-canonical-form` §N4 —que era normativa desde el primer día—
la comprueba ahora un test. La tabla de arriba es el estado **después** de eso.

`Shape` tiene diez campos y ninguno es una `Function`, una `Resolution` ni un `Ruleset`. El
`Ruleset` llega a la estación 10 **de rebote**, porque lo que cubre entra en `gobernadas`; el
documento en sí no se compara.

> **v1alpha1 llegó al final. Cada borrador posterior se quedó antes, y ninguno lo escribió.**

Eso es lo que hacía que `73/73` significase más que `19/19`: aquellos certificaban una
versión que había atravesado casi toda la cadena. **Los dos números estaban bien y no medían
lo mismo** — y ninguno de los dos decía cuánto de la cadena cubría, que es justo lo que este
apartado existe para que se pueda decir.

Esta tabla no es una acusación a las versiones anteriores: es la razón de escribir el
criterio. Sin él, «terminado» quiere decir *«dejé de encontrar cosas que arreglar»*, que es
una propiedad del que mira y no del artefacto.

### 8.4 · La definición

> **Un `kind` está listo cuando atraviesa las doce estaciones y cada tránsito tiene un caso
> que lo certifica.**

Y una versión está lista cuando lo están todos los `kind` que introduce, **más** las tres
condiciones que ya se cumplen y conviene dejar contadas:

| | Condición | Estado |
|---|---|---|
| **a** | ninguna decisión abierta | ✅ §6 |
| **b** | la prueba de fuego ejecutada, con lo que encontró escrito | ✅ §7.1 |
| **c** | las doce estaciones, con caso cada una | ✅ **doce de doce**, 28 casos |

La (c) es la única que falta, y **no admite grados**: una estación sin caso es una estación
que no sabemos si funciona. Es la misma lección de `confidence`, que llevaba cuatro versiones
en el árbol contradiciendo una regla del proyecto porque nada lo usaba.

### 8.5 · Las fases

Cuatro, en este orden y no en otro. Cada una **termina en verde** y aporta una garantía
completa, no un trozo.

---

**Fase 1 · Determinismo** — estación 8, y **G1**.

`requires`, `implements` y el `requiresGovernance` de un concepto entran en `CONJUNTOS`. Es
una lista de nombres de campo, y lo caro no es escribirla: es no haberlo hecho.

*Se da por terminada cuando:* un caso de `digest/` toma dos paquetes idénticos con esos tres
campos en distinto orden y exige **el mismo digest**.

*Va primera porque* es la única cuyo fallo es **silencioso y contagioso**: todo lo que viene
después —el sellado, el diff, el lock— se computa encima del digest. Un digest inestable no
rompe nada hoy y lo rompe todo mañana.

**Hecha**, y encontró una cuarta rotura que la lista no preveía. `CONJUNTOS` mira **la clave
bajo la que cuelga una secuencia**, y en `Lattice.requiresGovernance` las listas cuelgan del
nombre de un nivel —`high`, `critical`—, que es arbitrario y no puede estar en ninguna lista
fija. Añadir el campo habría arreglado el concepto de v1alpha4 y **no el retículo de
v1alpha3**, dejando el mismo nombre con dos comportamientos en dos documentos.

De ahí sale `MAPAS_DE_CONJUNTOS`: **el que sabe que sus valores son conjuntos no es la
secuencia, es el mapa que la contiene.** Casos
`v1alpha4/digest/order-of-sets-is-irrelevant` y
`v1alpha3/digest/order-of-natures-is-irrelevant`.

Y deja una observación que vale para la estación entera: *«esta lista no creció con v1alpha2,
no creció con v1alpha3 y no creció con v1alpha4»*. **Una lista que hay que acordarse de
actualizar es una lista de la que nadie se acuerda** — y las tres veces se descubrió
comparando dos digests a mano, nunca leyendo.

---

**Fase 2 · Compatibilidad** — estación 10, y **G2 en el tiempo**.

`Shape` gana conceptos e interfaces, y sus cambios se clasifican. Lo que hay que cubrir sale
de lo que un concepto y una forma **son**, no de una lluvia de ideas:

| Cambio | Por qué rompe |
|---|---|
| un concepto **desaparece** | todo `is` que lo nombre queda colgando, en paquetes que no se tocaron |
| su `type` **cambia** | quince propiedades heredan otro tipo sin haberse editado |
| su clasificación **baja** | es `OOS4012` entre versiones: lo que impide rebajar dentro de un paquete no puede ser libre entre dos |
| su `requiresGovernance` **encoge** | ya cubierto — `OOS5024` |
| el `requires` de una interfaz **crece** | los implementadores dejan de satisfacerla, y eso no es un aviso: **es que no compilan** (`OOS9001`) |
| el `requires` de una interfaz **encoge** | **no rompe**: más formas la subsumen, luego la regla alcanza más. Es la dirección segura |

La última fila es la que demuestra que la lista está derivada y no inventada: sale de §4.2 de
[`03-interface`](03-interface.md), y **la asimetría es el contenido**.

*Se da por terminada cuando:* el paquete de prueba de §8.2 —tipo cambiado, clasificación
rebajada, concepto desaparecido— deja de decir `patch`.

**Hecha, y con un solo código nuevo de cinco.** Retirar un concepto es `OOS5007`, cambiarle
el tipo es `OOS5002`, estrechar su `enum` también, y mover su clasificación es `OOS5009` /
`OOS5011` — todos de v1alpha1, sin tocar. La razón es que **un concepto declara `type`,
`labels` y `enum`, que es exactamente lo que declara una propiedad**, así que sus cambios
pasan por las mismas dos funciones. Es la tesis de [`01-significado`](01-significado.md) §3
comprobándose sola.

El único nuevo es `OOS5025` —*una forma exige más conceptos que antes*—, y hace falta porque
no hay nada en v1alpha1 que signifique *«un contrato existente pasa a exigir más»*.

Y la fila de arriba estaba **mal redactada**, lo que se vio al medirla: al crecer `requires`,
una regla que apunta a esa forma no deja de alcanzar a los implementadores —los sigue
seleccionando— sino que **el paquete de quien la implementa deja de compilar**. El efecto es
más duro que lo que decía esta tabla, no más suave.

---

**Fase 3 · Emisión** — estación 11.

`is` se resuelve **antes** de emitir. ODCS recibe el tipo y la clasificación heredados; el
esquema de Cedar recibe las etiquetas del concepto.

*Se da por terminada cuando:* se cumple esta invariante, que es la misma que gobierna la
herencia un piso más abajo —

> **Emitir una propiedad mapeada y emitir la misma propiedad con lo heredado escrito a mano
> dan exactamente lo mismo.**

Si difieren, `is` no es un mapeo: es una pérdida de información con buena prensa.

**Hecha, y la invariante se cumple al carácter con una excepción que resultó ser lo
importante:** la mapeada lleva además `x-oos-is`. Esa clave no está para documentar — está
porque **es lo que permite deshacer la fusión al importar**. Sin ella, la vuelta ODCS → OOS
traería el tipo heredado escrito a mano, y eso es una copia que miente el día que el concepto
cambie: el fallo que el guardarraíl de `is` existe para impedir, entrando por la puerta de
atrás de un formato ajeno.

> **Una traducción que no se puede invertir no es una traducción: es una pérdida.**

Dos decisiones más que la fase obligó a tomar:

- **Se resuelve en el emisor, no en la forma canónica.** La forma canónica conserva *lo
  escrito* —la identidad de un documento es lo que dice—; la emisión traduce *lo que
  significa*. Meterlo en `normalize` habría hecho que cambiar un concepto cambiara el digest
  de quince entidades que nadie tocó.
- **Se resuelve contra los conceptos del propio bundle**, no del paquete fuente. Eso es lo
  que hace que **un bundle se baste a sí mismo para emitir**: quien recibe el artefacto
  firmado produce el contrato sin tener delante un solo fichero YAML.

Y destapó un defecto que no era de esta estación: el importador sellaba **siempre**
`v1alpha1`, así que la vuelta producía un documento que declara una versión **en la que `is`
no existe** y que no valida contra su propio esquema. Un importador que emite algo que el
validador rechazaría es peor que uno que no importa.

---

**Fase 4 · Dependencia** — estación 12.

Un caso de conformidad con **dos paquetes**: el concepto en uno, la entidad en otro, fijado
en el lock. No hace falta nada nuevo —un `Property` se importa como cualquier documento— y
justamente por eso hay que probarlo: *«GDPR como dependencia»* es el argumento central de
[`02-property`](02-property.md) §7 y hoy **es una afirmación sin caso**.

*Se da por terminada cuando:* el caso existe y pasa, y su gemelo negativo también.

**Hecha, y el gemelo negativo no es el que esta línea decía.** El previsto —un `is` a un
concepto de un paquete no declarado como dependencia— **no falla**, y no por un descuido de
la fase: **ORE no puede saber que la referencia cruza una frontera**. Un paquete cargado es
una bolsa plana de documentos, sin noción de a qué `package.yaml` pertenece cada fichero.

Y no es de v1alpha4. Se midió también con vocabulario de v1alpha1 —una etiqueta de un
retículo ajeno, sin declarar la dependencia— y pasa igual. §8.6.

El gemelo que sí certifica algo, y que es el que está escrito, dice lo contrario y es más
útil: **declarar una dependencia no conjura lo que publica.** Con la dependencia en el
`ontology.config.yaml` y fijada en el lock, si el concepto no está en el árbol, `OOS2001`. La
resolución es **por presencia, no por declaración**, y esa es la dirección reversible: heredar
un tipo y una clasificación imaginarios porque alguien escribió una línea de configuración
haría correr toda la maquinaria de flujo encima de ellos.

Lo que el caso positivo sí demuestra es lo que §8.6 pedía: **las tres cosas cruzan la
frontera** —`type`, `labels` y `requiresGovernance`—, y la tercera obliga al paquete que
importa a poner una política de Cedar para compilar. Eso es *«GDPR como dependencia»* dejando
de ser una metáfora.

---

### 8.6 · Lo que **no** entra en v1

**El resolutor de dependencias.** ORE valida el `ontology.lock` y no descarga nada: los
documentos de un paquete importado funcionan si sus ficheros están en el árbol. Eso **no es
un hueco de v1alpha4** —afecta igual a todas las versiones y a todos los `kind`— y es del
motor, no del molde. Lo que v1alpha4 debía demostrar es que un concepto **se comporta igual
viniendo de otro paquete**, y eso lo hizo la fase 4.

**Cinco cambios de v1alpha2 y v1alpha3 que el `diff` sigue sin ver.** La estación 10 de esas
dos versiones se cerró **sin un solo código nuevo** —el símbolo de cada cambio ya tenía uno—
pero cinco no encajaron en ninguno, y conviene tenerlos escritos en vez de descubiertos:

| Cambio | Por qué no encaja |
|---|---|
| `mustBe` / `mustNotBe` de una aserción cambia | son **igualdades, no cotas**. `mustBe 0 → 999` no es *más flojo*: es **otra cosa**, y llamarlo relajación inventaría una dirección que el operador no tiene |
| `strategies` de una `Resolution` **se reordena** | el orden es el significado —la primera que casa gana— y **no hay código para «una secuencia se reordenó»** |
| el desclasificador de una máscara se debilita — `mask(FULL)` → `mask(LAST4)` | exigiría un **orden de fuerza** entre los argumentos de una máscara, y ese orden no está escrito en ninguna parte. `FULL`, `LAST4` y `HASH` no forman una cadena |
| `effects` de una `Function` crece | escribe donde no escribía. No rompe a quien la llama, así que ningún código de compatibilidad le corresponde — y sin embargo es un cambio de superficie de escritura |
| el `owner` de un `Ruleset` cambia | cambia **quién responde**. Ningún código lo cubre, y no está claro que sea una cuestión de compatibilidad |

Los tres primeros son decisiones de especificación, no de implementación: el primero pregunta
si **cualquier** cambio de una aserción es rompedor; el segundo, si reordenar una secuencia
merece un código; el tercero exige decidir un orden entre desclasificadores que hoy no existe.
Ninguno se puede resolver reutilizando, que es exactamente por lo que están aquí.

**Y el alcance de las referencias entre paquetes**, que la fase 4 midió y que **no es lo
mismo que el resolutor**. Comprobar que una referencia cruza una dependencia declarada es una
comprobación de compilación —L0, decidible, sin red— y hoy no existe: dos paquetes en el
mismo árbol con un `is` que los cruza, o con una etiqueta de un retículo ajeno, validan **sin
una sola línea de `dependencies`**.

No entra en v1alpha4 porque **no se puede decidir aquí**. Exige contestar antes una pregunta
del modelo de empaquetado, que es de v1alpha1:

> ¿Qué determina a qué paquete pertenece un documento — su ubicación bajo un `package.yaml`,
> o su `namespace`? Y ¿cómo se relaciona la identidad de un `Package` local con la coordenada
> de una dependencia (`oos.dev/regulatory/gdpr`)?

Hoy las dos cosas son independientes: `examples/acme-retail` tiene un paquete llamado `hr` con
documentos en el espacio de nombres `gdpr`. Hasta que eso esté decidido, cualquier
comprobación de alcance sería una convención inventada por el motor, que es exactamente lo que
la frontera OOS/ORE prohíbe.

**Que la versión sea normativa.** «Listo para v1» quiere decir *la primera versión completa
del borrador*, en el mismo sentido en que se cerró la de v1alpha2. Sigue siendo **alpha**:
sin garantías de compatibilidad, y la escalera hacia `v1beta1` tiene sus propias condiciones,
medidas y no cumplidas.

**Poner al día las estaciones 10 y 11 de v1alpha2 y v1alpha3.** §8.3 las mide y no las
arregla aquí. Sería un cambio de alcance de dos versiones cerradas, y este documento no puede
tomarlo — pero ahora está escrito, que es la diferencia entre una deuda y un descuido.
