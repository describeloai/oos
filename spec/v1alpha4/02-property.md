# `Property` — el concepto

**Estado:** borrador. Gobierna los documentos que declaran su `apiVersion`, y es **alpha**:
sin garantías de compatibilidad.

El régimen está en [`01-significado`](01-significado.md). Este documento fija **la superficie
normativa del documento**: qué se escribe, qué no cabe, y qué comprueba el compilador.

---

## 1. Naturaleza

Un `Property` dice **qué es** un dato. No dónde vive, no cómo se llama, no cómo se calcula.

```yaml
apiVersion: oos.dev/v1alpha4
kind: Property
metadata: { name: personalEmail, namespace: gdpr }
spec:
  type: String
  labels: { gdpr.sensitivity: high }
  description: >
    La dirección de correo de una persona física.
  aiContext:
    synonyms: [email, correo, e_mail, mail, correo_electronico]
```

Es un documento y no un campo, y hay dos razones — una de reutilización y otra estructural.
La segunda es la que decide:

> Cuando una ontología se **induce** en vez de escribirse, la propiedad es **la unidad que
> aparece primero.**

Una columna descubierta es una propiedad *buscando una clase*. `kunde_nr` se encuentra antes
de saber si pertenece a `Customer` o a `Party`, y esa decisión es justamente la que hay que
diferir a un humano. Si el único sitio donde puede vivir una propiedad fuese dentro de una
entidad, **no habría dónde poner lo hallado hasta haber decidido la entidad** — y la decisión
se tomaría por falta de sitio, que es la peor forma de tomarla.

### 1.1 · La línea que decide qué cabe

Todo el apartado 2 se deriva de una sola frase, y conviene tenerla antes que la lista:

> **El concepto declara lo que es cierto de él en todas partes. La propiedad declara lo que
> es cierto de esa columna.**

Un correo personal es sensible en los quince sistemas donde aparece, y sus sinónimos son los
mismos en los quince. Que sea obligatorio, único o historizado **depende de la tabla**.

---

## 2. Lo que **no** es un campo

| | Por qué no |
|---|---|
| `required` | depende de la tabla. `personalEmail` es obligatorio en `Customer` y opcional en `Lead`, y sigue siendo el mismo concepto |
| `unique` | igual, y peor: la unicidad es una propiedad del **conjunto**, no del significado |
| `temporal` | si una columna se historiza lo decide cómo la escribe su sistema, no qué significa |
| `derivedFrom` · `expression` | **un correo personal significa lo mismo se calcule como se calcule.** La procedencia es de la propiedad concreta |
| `examples` | valores de dato reales, que pertenecen a una columna y no a una idea |
| `owner` | lo tiene el paquete que lo publica. Un `Ruleset` necesita el suyo porque **restringe lo ajeno**; un concepto no restringe: se importa o no se importa |
| `implements` | un concepto no tiene forma. La forma es de la entidad — [`03-interface`](03-interface.md) |

Y **`enum` y `aiContext` sí caben**, que es donde la línea de §1.1 hace trabajo de verdad en
vez de solo excluir:

| | Por qué sí |
|---|---|
| `enum` | un código de moneda es ISO 4217 en los quince sistemas. Un estado de pedido no lo es, y por eso ese no es un buen concepto |
| `aiContext` | **los sinónimos de un concepto son los mismos en todos los sistemas donde aparece** |

`aiContext` merece un párrafo, porque es el campo que más gana al subir de nivel. Declarar
una vez que a `personalEmail` el negocio lo llama *correo*, *email* o *e_mail* evita que cada
una de cuatro mil columnas lo vuelva a adivinar — y **es exactamente el ancla contra la que
un inductor propone**. Es la misma forma que en `Entity` y se referencia en vez de repetirse:
redeclararla con otro nombre para el mismo subcampo sería el error de las dos superficies
cometido dentro del documento que existe para evitarlo.

Las tres condiciones con que se adoptó siguen valiendo, y la tercera con más razón aquí:
**descriptivo, nunca directivo.** Un concepto se importa desde fuera, así que su `aiContext`
es texto de un tercero dentro de un artefacto gobernado.

---

## 3. Anatomía

### 3.1 · `metadata`

| Clave | |
|---|---|
| `name` · `namespace` | **obligatorios**. El `namespace` es lo que le da dueño, y de ahí sale todo lo de §5 |
| `labels` | la clasificación **de este documento** |
| `description` | prosa |

**`labels` aparece en los dos sitios, y no son dos superficies para lo mismo.** Es el único
documento donde pasa, así que hay que decirlo despacio:

| Dónde | Qué clasifica | Se hereda al escribir `is` |
|---|---|---|
| `metadata.labels` | **este documento** — en la práctica, su madurez | **no** |
| `spec.labels` | **el dato** que lleve este concepto | **sí** |

Es la misma distinción que en `Entity`, que lleva `labels` en `metadata` y otras dentro de
cada propiedad sin que nadie las confunda. Y no es una comodidad: **sin `metadata.labels` el
campo `confidence` sería inusable**, porque un concepto acuñado por inferencia tiene que
poder declararse `DRAFT` y la madurez se declara donde se declara siempre.

La primera versión del motor se lo negó por miedo a la duplicación, y lo destapó `confidence`
en el primer caso que lo usó.

### 3.2 · `spec`

| Clave | |
|---|---|
| `type` | **obligatorio**. Del conjunto de tipos de OOS; fuera de él, `OOS3001` |
| `labels` | lo que el concepto declara del dato |
| `description` | prosa |
| `enum` | **secuencia**: retirar un valor o reordenarlos es un cambio observable |
| `aiContext` | §2 |
| `requiresGovernance` | §3.3 — qué clase de regla exige, **categóricamente** |
| `confidence` | §4 |

Un `Property` sin `type` es un fallo de forma —`OOS1004`—, y no por rigor: `type` es la mitad
de lo que hereda todo el que lo referencie. Un concepto sin tipo no clasifica nada, solo
nombra.

Y ese `type` **se comprueba**. Si estuviera mal escrito se propagaría en silencio a las
quince propiedades que lo mapean, que es el modo de fallo que el nivel compartido amplifica:
un error en un concepto no vale por uno.

### 3.3 · `requiresGovernance` — y por qué el concepto también puede exigir

Un `Property` **PUEDE** declarar qué naturalezas de regla exige quien lo lleve:

```yaml
kind: Property
metadata: { name: healthCondition, namespace: gdpr }
spec:
  type: String
  labels: { gdpr.sensitivity: high }
  requiresGovernance: [authorization]
```

Hasta v1alpha3 esa exigencia solo vivía en el **retículo**, por nivel: *«todo lo que esté en
`high` o por encima necesita una política»*. Que ahora viva también en el concepto no es una
comodidad — es lo que hace coherente a esta versión entera, y hay una razón teórica y una
arquitectónica.

**La regulación no clasifica por nivel: clasifica por categoría.** El artículo 9 del RGPD
enumera categorías especiales —salud, biometría, convicciones, orientación sexual— y sus
obligaciones se activan **en cuanto el dato cae en una de ellas**, con independencia de lo
sensible que sea en ese contexto concreto. No hay un umbral que evaluar: la obligación va
pegada a *qué es* el dato, no a *cuánto* pesa.

Un `requiresGovernance` que solo cuelgue del retículo **no puede expresar eso**. Obliga a
traducir *«esto es un dato de salud»* a *«esto es `high`»*, y esa traducción es de alguien.

**Y ese alguien es exactamente el problema que v1alpha4 existe para resolver:**

> v1alpha3 gobierna **lo que alguien acertó a etiquetar**.

Si la exigencia solo cuelga del nivel, un correo personal mal clasificado como `low` **se
escapa de su obligación regulatoria**, y el paquete compila. Con la exigencia en el concepto,
mapearlo basta: `is: gdpr.personalEmail` arrastra consigo lo que ese concepto exige, sin
pasar por el juicio de nadie sobre cuánto pesa. **Es la misma frase de arriba, resuelta.**

**Normativo.**

- `requiresGovernance` en un `Property` es una **lista de naturalezas**, no un mapa por nivel:
  un concepto no tiene niveles, y la exigencia es categórica.
- Se llama igual que en el retículo **a propósito**. Es la misma noción —qué clase de regla
  hace falta— sobre otro sujeto, y ponerle otro nombre sería el error de los dos nombres para
  un concepto, cometido en la especificación que más lo persigue.
- Las exigencias se componen con **unión**, igual que entre retículos: una propiedad debe
  cubrir la unión de lo que exigen sus etiquetas efectivas **y** lo que exige su concepto.
- Un concepto **no puede descargar** nada. Sin `requiresGovernance` no exige; con él, exige
  más. **No hay forma de exigir menos**, que es lo que impide que importar vocabulario laxo
  afloje una obligación local.

La composición no necesita teoría nueva: la unión de conjuntos de naturalezas es asociativa,
conmutativa e idempotente, así que **el orden en que se componen los tres orígenes —retículos,
concepto y lo que venga— no puede cambiar el resultado**. Es la misma propiedad que hizo
segura la conjunción entre retículos, un origen más allá.

Y hereda el límite de siempre: `OOS8001` demuestra que **existe** una regla de la clase
exigida, no que sea la adecuada. *El compilador decide la cobertura; el endoso registra la
adecuación.*

---

## 4. `confidence` — y por qué es una cadena

`basic.schema.json` declara este tipo **desde v1alpha1**, y hasta v1alpha4 **ningún documento
lo referenciaba**: un `$def` esperando a que existiera algo que infiriera.

Un `Property` **PUEDE** llevarlo, porque **acuñar un concepto es una inferencia**:

> *«Estas catorce columnas comparten un concepto; llámalo así.»*

Es exactamente la misma clase de acto que mapear una columna, y el mecanismo no los distingue
— [`01-significado`](01-significado.md) §4.2.1 explica por qué no debe. Lo que los separa es
la consecuencia: un mapeo equivocado está mal en un sitio; **un concepto equivocado es una
palabra que otros van a hablar.**

### 4.1 · Normativo

- Un documento cuya madurez **efectiva** no sea `DRAFT` **NO DEBE** llevar `confidence`:
  `OOS9003`. La regla leída al revés es la que hace trabajo — *un documento que no está en
  `DRAFT` no puede contener una sola conjetura*.
- **Ausente no es `DRAFT`.** Un concepto que no declara madurez y lleva `confidence` falla.
  De los dos errores posibles este es el reversible: rechazarlo cuesta una etiqueta;
  aceptarlo en silencio publica una suposición como si fuera una decisión.
- `confidence` es una **cadena**, no un número.

### 4.2 · La cadena, y lo que costó verlo

El tipo se declaró `number` en v1alpha1, y **un decimal sin comillas no tiene forma
canónica**: viaja en coma flotante binaria, y lo que sobreviva a la ida y vuelta depende del
parser. RFC 8785 fija cómo se serializa el resultado, pero no devuelve los dígitos que el
parseo ya perdió. Es `OOS6003`, y la regla es del propio proyecto.

**Esa contradicción vivió cuatro versiones en el árbol.** No la vio nadie porque ningún
documento referenciaba el campo, y saltó contra el primer caso que lo usó. La misma decisión,
con las mismas palabras, ya estaba escrita en `Resolution.threshold` de v1alpha2 — que llegó
antes al problema por el camino contrario: **tenía usuario desde el primer día**.

> Un `$def` sin usuario no está esperando: **está sin comprobar.**

La corrección es segura por lo mismo que el defecto era invisible: no hay documento en el
mundo que lo use.

---

## 5. Lo que hereda quien lo referencia

Una propiedad que declara `is` hereda `type` y `labels`. La superficie del mapeo vive en
[`01-significado`](01-significado.md) §4.2; aquí solo lo que este documento **provee**:

| | Se hereda | Se puede redeclarar |
|---|---|---|
| `type` | ✓ | **no** — es una igualdad, y si la copia contradice no hay nada a lo que apelar |
| `labels` | ✓ | **sí, solo hacia arriba** — es un orden, y `OOS4012` ya lo gobierna |
| `enum` · `aiContext` · `description` | ✓ | — |

Y una precisión que importa al importar vocabulario ajeno:

> **Un concepto compartido fija un suelo de clasificación, no un valor.**

Si fijara un valor, importar un paquete regulatorio obligaría a aceptar también su laxitud, y
nadie con una obligación más estricta podría usarlo. El correo de un menor puede ser
`critical` donde `gdpr.personalEmail` dice `high`, y esa entidad no está incumpliendo el
concepto: lo está respetando.

### 5.1 · Y una propiedad **derivada** también lo hereda

Un `is` y un `derivedFrom` conviven: un correo compuesto de dos columnas sigue siendo un
correo. Cuando eso pasa, **el concepto entra en el `join` como un origen más**, con la misma
dirección que todos —solo sube—, y el resultado es el mayor entre lo computado y lo que el
concepto exige.

Que sea así no era obvio y lo decidió una medición. La propagación hereda en una pasada y
computa el `join` de las derivadas en otra, y la segunda **pisaba** lo heredado del concepto:
**añadir `derivedFrom` a una propiedad mapeada le borraba la clasificación en silencio**. Lo
que sin `derivedFrom` rompía con `OOS8001` compilaba sin una sola regla de gobierno.

Es el modo de fallo de `OOS4001` una vez más: no hay línea mal escrita que señalar, y la
propiedad se lee igual de bien. La corrección se sigue de esta misma sección — **un suelo no
se pisa, se eleva**.

---

## 6. Un concepto que nadie habla no compila

`OOS9004`. Es `OOS8002` un piso más arriba —*un objetivo que no casa con nada*— y por el
mismo motivo:

> Una regla que no gobierna nada y un concepto que nadie habla tienen **exactamente el mismo
> aspecto** que los que funcionan.

Habla el concepto quien lo **mapea** con `is` y también quien lo **exige** desde un
`Interface`: nombrarlo en una forma ya lo pone en circulación. Contarlo como silencio daría
dos códigos para una situación —este y `OOS9001` en la entidad que no satisface—, y este
registro emite **un código por síntoma, no por causa**.

### 6.1 · La excepción, que es la regla dicha entera

**No se aplica a un paquete sin entidades**, y eso no es una concesión: es la forma de
publicar vocabulario. Un paquete regulatorio publica sesenta conceptos y no implementa
ninguno; quien lo importa es quien los habla.

> La regla no es *«todo concepto se usa»*. Es **«en un paquete que modela, todo concepto
> declarado se usa»**.

### 6.2 · Y es lo único que el molde puede hacer contra la inflación

El modo de fallo que preocupa es que cuatro mil columnas produzcan cuatro mil conceptos, que
es igual que no tener vocabulario. **Un compilador no puede detectarlo**: distinguir cuatro
mil conceptos legítimos de sesenta mal unificados exigiría reconocer que quince columnas son
la misma cosa, y eso es la *sameness* no declarada que v1alpha1 declaró indetectable al
negarse a basar la solidez en parsear cadenas.

Lo que sí puede es **distinguir los conceptos vivos de los muertos**, y esa es la diferencia
entre un vocabulario y un vertedero. El resto —sesgar a quien propone hacia mapear antes que
acuñar— es ergonomía del inductor y queda fuera de esta especificación
([`01-significado`](01-significado.md) §4.2.2).

---

## 7. Cómo se publica

Un `Property` tiene `namespace`, y con él todo lo que ya existe: **dueño, versión, digest,
resolución de dependencias y fijación en el lock.** No hace falta ningún mecanismo nuevo.

```yaml
# ontology.config.yaml
dependencies:
  - { name: gdpr, version: "^2.0.0" }
```

Eso es lo que convierte *«GDPR como dependencia»* en algo literal, y con §3.3 el paquete trae
las **tres** cosas en un solo documento por concepto:

| | Qué aporta |
|---|---|
| `type` | qué forma tiene el dato |
| `labels` | **cómo de sensible es** — el suelo de clasificación |
| `requiresGovernance` | **qué clase de regla exige**, categóricamente |

Quien lo importa hereda las tres, y de las tres solo puede exigir **más**. Un paquete
regulatorio deja de ser una lista de obligaciones abstractas y pasa a ser el vocabulario con
el que se escribe la ontología — que es la diferencia entre cumplir y **poder demostrar que se
cumple**.

> **Mapear es hablar el vocabulario de otro. Acuñar es ampliar el tuyo.**

En un patrimonio gobernado la mayoría de los conceptos que importan **se importan**. Una
organización que acuña cuatro mil ha decidido que nada de lo que tiene es estándar — puede
ser cierto, y es una decisión que alguien firma.

---

## 8. Errores

| Código | Condición | De dónde sale |
|---|---|---|
| `OOS1004` | sin `type`; o una propiedad con `is` que redeclara `type`; o `confidence` sin `is` | el esquema lo expresa entero |
| `OOS2001` | un `is` que apunta a un concepto inexistente | reservado en v1alpha1 |
| `OOS3001` | `type` fuera del conjunto | v1alpha1, sin cambios |
| `OOS4012` | una propiedad **rebaja** la clasificación del concepto | v1alpha1, **sin cambios** |
| `OOS6003` | `confidence` escrito como número | v1alpha1, sin cambios |
| `OOS8001` | una propiedad que no cubre lo que su **concepto** exige | v1alpha3, sin cambios |
| `OOS9003` | `confidence` fuera de una madurez efectiva `DRAFT` | **nuevo** |
| `OOS9004` | un concepto declarado al que nada referencia | **nuevo** |

**Dos códigos nuevos de ocho**, y las dos filas que no son nuevas son las que hay que mirar
dos veces.

`OOS4012` — la regla más antigua del proyecto gobierna el mecanismo más nuevo **exactamente
como estaba escrita**, porque la herencia desde un concepto se enchufó como tercera fuente en
la propagación que ya existía, al lado de la entidad y del `datasource`. Si hubiera hecho
falta un plano nuevo de análisis, la cobertura habría visto una etiqueta y el flujo otra.

`OOS8001` — la exigencia categórica de §3.3 **no trae código propio**. Entra como un origen
más en el cálculo de cobertura y falla con el mismo código, el mismo mensaje y el mismo
diagnóstico. Un origen nuevo de exigencia y **cero códigos nuevos** es la señal de que la
pieza encajó donde debía.

---

## 9. Aplazado

**Relaciones entre conceptos.** Que `gdpr.personalEmail` sea *un tipo de* `gdpr.contactPoint`
es representable y no está representado. Sin ello, un `Ruleset` no puede apuntar a una
familia de conceptos — y hoy tampoco hace falta, porque para eso está la forma.

**Deprecar un concepto.** `oos.maturity` tiene `DEPRECATED` y nada comprueba todavía qué pasa
cuando quince paquetes mapean a un concepto que su dueño retira. Es una pregunta de
compatibilidad —familia `OOS5xxx`— y se responde cuando exista el segundo paquete que
dependa de uno ajeno.
