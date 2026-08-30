# El régimen de significado

**Estado:** borrador. Gobierna los documentos que declaran su `apiVersion`, y es **alpha**:
sin garantías de compatibilidad.

El núcleo de v1alpha4. Todo lo demás de esta versión se deriva de lo que aquí se decide.

---

## 1. La tercera altura de una pregunta que ya contestamos

v1alpha2 escribió `Resolution` para decidir que **dos registros son la misma cosa**, y lo
llamó *el efecto sobre la identidad*. Era una de tres, y nadie lo vio:

| Declara que son la misma cosa | Nivel | |
|---|---|---|
| `Resolution` | dos **registros** | ✅ v1alpha2 |
| `Property` | dos **propiedades** | **falta** |
| `Interface` | dos **entidades** | **falta** |

> **v1alpha1 gobierna lo que se puede saber. v1alpha2, lo que se puede causar. v1alpha3, qué
> debe sostenerse. v1alpha4 gobierna qué es la misma cosa.**

Y no es una simetría bonita: es la fila que faltaba debajo de todo lo demás. La regla de
flujo compara etiquetas, la de gobierno exige que estén cubiertas — y **ninguna de las dos
comprueba que la clasificación sea consistente**, porque hasta ahora no había forma de decir
que dos propiedades son la misma.

> v1alpha3 gobierna **lo que alguien acertó a etiquetar**.

Esa frase es el motivo de esta versión.

---

## 2. Esto es un molde, no un procedimiento

Conviene decirlo antes de las piezas, porque es lo que decide qué entra y qué no.

Una ontología de un patrimonio real **se induce**, y una parte de lo que aquí se define
existe para que algo la induzca. Pero esta especificación **no describe cómo se induce**:

| | |
|---|---|
| **el molde define** | qué se puede decir, qué obliga decirlo, y qué tiene que cumplir lo dicho |
| **el molde no define** | qué se introspecciona, si hay un modelo de por medio, cómo se pregunta |

Es la frontera de `docs/DESIGN.md` §3 —*«OOS define el artefacto; ORE define la ergonomía y
la ejecución»*— y aquí importa más que en ninguna versión anterior, porque es la primera vez
que una parte del vocabulario existe **para que otro la escriba**.

De ahí sale la forma que tienen todas las reglas de este documento, y §4.2.1 es su mejor
ilustración:

> **El molde no dice lo que una herramienta debe hacer. Dice lo que tiene que ser cierto — y
> entonces la herramienta no tiene elección.**

Eso es lo que permite que un inductor ajeno —otro motor, una importación desde una
herramienta de terceros— produzca algo conforme sin haber leído una línea sobre nuestra
ergonomía.

---

## 3. El movimiento es el de `Binding`, en la otra dirección

Aquí está lo que hace que la pieza que falta sea casi gratis, y es el mismo hallazgo que en
las dos versiones anteriores: **ya existe, aplicada a otro nivel.**

```yaml
kind: Binding
spec:
  properties:
    employeeId: "Worker_Reference.ID"     # el nombre es mío, la columna es suya
```

Un `Binding` **declara una identidad a través de una frontera**: esta propiedad del modelo
*es* esa columna física. Nadie lo llama una segunda superficie de autoría, y nadie lo
confunde con la entidad — porque no duplica nada: **relaciona**.

| | Mapea una propiedad | Del modelo | A |
|---|---|---|---|
| `Binding` | ✓ | ✓ | **la fuente física** |
| `Property` | ✓ | ✓ | **el concepto** |

Es el mismo movimiento en la otra dirección: hacia abajo, dónde vive el dato; hacia arriba,
qué significa. Y la herencia también existe ya, con su dirección decidida: `02-entity` §4.1
dice que una propiedad **PUEDE** elevar la etiqueta que hereda y **NO DEBE** rebajarla
(`OOS4012`). Esa regla sube un nivel **sin cambiar una letra**.

**Lo único nuevo de esta versión es el nivel al que se aplica lo que ya está.**

---

## 4. Las tres piezas

### 4.1 · El concepto

Un `Property` no dice dónde vive un dato ni cómo se llama. Dice **qué es**.

```yaml
apiVersion: oos.dev/v1alpha4
kind: Property
metadata: { name: personalEmail, namespace: gdpr }
spec:
  type: String
  labels: { gdpr.sensitivity: high }
  description: >
    La dirección de correo de una persona física.
```

Tiene `namespace` y por tanto **dueño**, versión y digest: se publica, se importa y se fija
en el lock como cualquier otro documento. Un paquete regulatorio puede traer sesenta
conceptos con su clasificación ya decidida, y eso convierte *«GDPR como dependencia»* en algo
que además **clasifica**, no solo exige.

**Y hay una razón estructural, más allá de la reutilización, para que el concepto sea un
documento y no un campo:** cuando una ontología se **induce** en vez de escribirse, la
propiedad es **la unidad que aparece primero**. Una columna descubierta es una propiedad
*buscando una clase* — `kunde_nr` se encuentra antes de saber si pertenece a `Customer` o a
`Party`, y esa decisión es justamente la que hay que diferir a un humano. Si el único sitio
donde puede vivir una propiedad es dentro de una entidad, **no hay dónde poner lo hallado
hasta haber decidido la entidad**.

Es la misma forma que emiten las herramientas que inducen ontologías: el acelerador de AWS
almacena clases y propiedades por separado, y llama a lo segundo *ontologías inducidas*.

**Normativo.**

- `type` y `labels` son lo que el concepto **declara**.
- Un `Property` **NO DEBE** declarar `derivedFrom`, `expression` ni `examples`: eso es de la
  propiedad concreta, no del concepto. Un correo personal significa lo mismo se calcule como
  se calcule.
- Un `Property` **PUEDE** llevar `confidence`, con las mismas dos reglas que un mapeo
  (§4.2.1): **acuñar un concepto es una inferencia**, y una de las caras.
- Un `Property` declarado **localmente** al que ninguna propiedad del paquete referencia es
  una palabra que nadie habla: `OOS9004`. La regla no se aplica a un paquete **sin
  entidades**, que es el caso degenerado de publicar vocabulario para que otros lo importen.

### 4.2 · El mapeo

La entidad conserva su nombre y declara qué concepto es:

```yaml
kind: Entity
metadata: { name: Customer, namespace: crm }
spec:
  properties:
    email:
      is: gdpr.personalEmail        # el nombre es mío, el significado es suyo
```

**Y aquí está el guardarraíl que esta especificación ya pagó caro por no tener.**

> Una propiedad **declara localmente o referencia un concepto, nunca las dos cosas.**

Una propiedad con `is` **NO DEBE** declarar `type`: lo hereda. Es la lección de `quality`
inline aplicada antes de cometer el error en vez de después — **dos sitios donde decir lo
mismo acaban con dos semánticas.**

**Y el guardarraíl alcanza a `type` y no a `labels`.** La primera redacción de esta sección
prohibió las dos y **se contradecía con el párrafo siguiente**, que permite elevar la
clasificación heredada: elevarla exige escribirla. Lo destapó escribir los casos, y la
asimetría que resuelve la contradicción no es un parche, porque los dos campos no son la
misma clase de cosa:

| | Qué es | Qué pasa al redeclararlo |
|---|---|---|
| `type` | una **igualdad** | coincide o contradice, y **no hay nada a lo que apelar** para decidir quién gana |
| `labels` | un **orden** | tiene un significado definido —*elevar*— y un error definido —*rebajar*— |

Así que lo que sí **PUEDE** hacer es **elevar** la clasificación —el correo de un menor puede
ser `critical` donde el concepto dice `high`— y **NO DEBE** rebajarla. `OOS4012`, sin
cambios, y ahora la frase de §3 es literal: *sube un nivel sin cambiar una letra* — porque
aquí no hizo falta ninguna.

Y el nombre no importa: `Customer.email`, `Supplier.contactEmail` y `Employee.workEmail`
pueden ser el mismo concepto sin renombrarse. **Eso es lo que hace modelable un patrimonio
sucio**: no se limpia para gobernar, se mapea.

### 4.2.1 · `confidence` encuentra su usuario, cuatro versiones después

`basic.schema.json` declara este tipo **desde v1alpha1**:

> *«Confianza de una inferencia automática. Presente solo en documentos en `DRAFT`;
> `ore promote` la elimina.»*

Y hasta hoy **ningún documento lo referenciaba**: un `$def` sin usuario, esperando a que
existiera algo que infiriera. Esta versión trae dos cosas que infieren.

```yaml
properties:
  email:
    is: gdpr.personalEmail
    confidence: 0.87          # esto lo propuso una máquina
```

`confidence` significa algo **allí donde hubo una inferencia**, y un documento escrito a mano
no la tuvo: es una decisión, y nadie declara cuánta confianza tiene en algo que acaba de
decidir.

Y hay **dos** inferencias distintas, no una:

| | La inferencia | Su radio |
|---|---|---|
| **mapear** | *«esta columna es `personalEmail`»* | una propiedad |
| **acuñar** | *«estas catorce columnas comparten un concepto; llámalo así»* | **el vocabulario, para siempre** |

Las dos llevan `confidence` y las dos caen bajo la misma regla, así que el mecanismo no las
distingue — y **no debe**, porque son la misma clase de acto. Lo que las separa es la
consecuencia: un mapeo equivocado está mal en un sitio; **un concepto equivocado es una
palabra que otros van a hablar.**

**Normativo.**

- `confidence` **NO DEBE** aparecer sin `is`. Sin inferencia no hay nada de lo que dudar, y
  el esquema lo expresa entero: es `OOS1004`.
- Una propiedad con `confidence` **DEBE** estar en un documento cuya madurez **efectiva** sea
  `DRAFT`. Si no, `OOS9003`.

Y la segunda es la que hace trabajo de verdad, porque **es la misma frase leída al revés**:

> Un documento que no está en `DRAFT` **no puede contener una sola conjetura**.

`ore promote` es un desclasificador del vocabulario cerrado de `04-flow` §5: baja por el
retículo `oos.maturity`, de `DRAFT` a `REVIEWED` a `STABLE`. Con esta regla, promover un
documento que aún lleva `confidence` **no compila** — así que promover exige haber resuelto
cada propuesta, una a una.

**Y aquí es donde se ve qué clase de documento es este.** No dice lo que `promote` tiene que
hacer; dice lo que tiene que ser cierto. La herramienta no tiene elección, y **una
herramienta ajena tampoco**: una importación desde un inductor de terceros que traiga
mapeos sin revisar entra como `DRAFT` o no entra.

> La revisión humana deja de ser una buena práctica y pasa a ser **una condición de
> compilación.**

Es la diferencia con el modelo de un acelerador que aprueba elemento a elemento en una
interfaz: allí la aprobación es un acto que ocurrió y hay que creerse; aquí es **un commit,
con autor y diff, y un digest que cambia**.

Y la madurez es **efectiva**, no declarada: se hereda como cualquier otra etiqueta —de la
entidad, del `datasource`— y por eso la comprobación es del compilador y no del esquema.
Nadie promueve una entidad dejando una propiedad atrás.

### 4.2.2 · Lo que el molde **no** puede hacer con acuñar

La intuición de que *«acuñar tiene que costar más que mapear»* es correcta y **no es
expresable aquí**. Conviene decir por qué, porque el motivo es el mismo que ya limita §6.1.

El modo de fallo que preocupa es la **inflación**: cuatro mil columnas producen cuatro mil
conceptos, uno por columna, que es lo mismo que no tener vocabulario. Pero un compilador **no
puede distinguir** cuatro mil conceptos legítimamente distintos de sesenta mal unificados:
para verlo tendría que reconocer que quince columnas son la misma cosa, y eso es exactamente
la *sameness* no declarada que §9 declara indetectable.

> El molde no puede hacer que acuñar sea caro. Solo puede hacer que **nada acuñado sobreviva
> sin que alguien responda**, y que **un concepto que nadie usa no compile**.

Lo demás —sesgar a quien propone hacia mapear antes que acuñar, mostrar juntas las quince
columnas para que la unificación se decida una vez y no quince— es **ergonomía del inductor**,
y por tanto de fuera de esta especificación. Ponerlo aquí sería el error que §2 existe para
evitar.

Lo que sí deja el molde escrito es de quién es cada cosa, y sale del `namespace` sin añadir
nada:

> **Mapear es hablar el vocabulario de otro. Acuñar es ampliar el tuyo.**

En un patrimonio gobernado, la mayoría de los conceptos que importan **se importan**. Una
organización que acuña cuatro mil ha decidido que nada de lo que tiene es estándar — puede
ser cierto, y es una decisión que alguien firma.

### 4.3 · La forma

Un `Interface` nombra un conjunto de entidades **por su forma**, y la forma se expresa en
conceptos, no en nombres:

```yaml
apiVersion: oos.dev/v1alpha4
kind: Interface
metadata: { name: Party, namespace: acme }
spec:
  requires:
    - gdpr.personalEmail
    - acme.legalName
```

```yaml
kind: Entity
metadata: { name: Customer, namespace: crm }
spec:
  implements: [acme.Party]
```

Que se exija **el concepto y no el nombre** es toda la diferencia. Quince casi-duplicados
salidos de quince sistemas distintos pueden implementar `Party` conservando cada uno su
vocabulario, y el gobierno apunta a `Party`. **Modelar sin esto obliga a limpiar antes de
gobernar, que es el orden imposible.**

Y da el tercer eje de objetivo que le faltaba a un `Ruleset`:

| Objetivo | Nombra un conjunto por |
|---|---|
| `atLeast` | **clasificación** |
| `named` | **identidad** |
| `implements` | **forma** |

No son tres formas de decir lo mismo: son tres criterios distintos. Y la monotonía se
comporta igual — si `Customer implements Party`, una regla sobre `Party` lo alcanza.

---

## 5. `nature` **no** se disuelve — y el intento es lo informativo

Este apartado decía lo contrario, y la implementación lo refutó. Se deja el error escrito
porque lo que enseña vale más que el ahorro que prometía.

**La tesis era buena a primera vista.** `Entity.nature` admite `entity` y `event`, y
`OOS2010` dice *«`nature: entity` sin `primaryKey`, o `event` sin `timeKey`»*: un nombre, una
forma y miembros obligatorios — **eso ya parece una interfaz**, con un vocabulario cerrado de
dos. Absorberlo habría hecho encoger el registro, que es el resultado que P7 premia.

No se sostiene, y basta intentar escribirlo:

```yaml
kind: Interface
metadata: { name: Entity, namespace: oos }
spec:
  requires: [???]        # `primaryKey` no es un concepto
```

`requires` nombra **conceptos**. `primaryKey` no lo es: es una declaración **estructural**
sobre qué propiedades identifican un registro, y no dice qué significa ninguna de ellas.
Para absorber `OOS2010` habría que admitir en `requires` dos clases de exigencia —una de
significado y otra de estructura—, y entonces un `Interface` diría dos cosas distintas con la
misma palabra. Es el error contra el que va todo este documento, cometido en el sitio donde
menos se ve.

| Plano | Pregunta | Quién la gobierna |
|---|---|---|
| **estructural** | ¿esta entidad tiene con qué identificarse? | `nature` · `OOS2010`, sin cambios |
| **de significado** | ¿esta entidad tiene lo que `Party` exige? | `implements` · `OOS9001` |

> **Un `Interface` nombra una forma en significado, no en estructura.** Que las dos se
> parezcan desde lejos es lo que hacía atractiva la absorción.

Así que `OOS2010` se queda donde estaba y v1alpha4 no le quita nada a `Entity`. El registro
encoge igualmente, pero por otro sitio y por un motivo mejor: §7.

---

## 6. La regla

Cada versión aporta una, y esta es la cuarta:

| | Regla | Dice |
|---|---|---|
| **v1alpha1** | `L ⊑ C` | nada **fluye** por encima de su autorización |
| **v1alpha2** | `I(f) ⊒ I(destino)` | nada **escribe** por encima de su integridad |
| **v1alpha3** | `L(x) ⊒ n ⟹ ∃r` | nada clasificado queda **sin gobernar** |
| **v1alpha4** | `E implements I ⟹ ∀c ∈ I . ∃p ∈ E . is(p) = c` | **una forma declarada se satisface** |

Y es decidible al compilar por lo de siempre: los dos lados se computan del paquete, sin
tocar un dato.

### 6.1 · Lo que hace útil a la regla, y lo que la limita

Una entidad que **declara** implementar y no cumple es un fallo visible: está escrito en el
documento y una revisión lo encuentra.

Lo que **no** es visible —y es el modo de fallo real de un patrimonio sucio— es una columna
que **es** un `personalEmail` y que nadie mapeó. Eso el compilador no puede detectarlo, y no
por falta de esfuerzo: detectarlo exigiría adivinar significado desde un nombre, y esta
especificación ya decidió que **un análisis sólido no depende de parsear cadenas**
(`02-entity`, sobre `derivedFrom`).

Así que la regla hace lo mismo que `OOS8001`: **convierte en error lo que alguien declaró que
importaba.** Si `Customer implements Party`, faltar un concepto de `Party` rompe la
compilación. Si nadie declaró nada, nadie exige nada.

> **El compilador comprueba que las formas declaradas se cumplan. Que se declararan las
> formas correctas lo responde un dueño.**

Tercera vez que la frontera cae en el mismo sitio, y ya no es casualidad: **lo declarado es
decidible, lo omitido no lo es nunca.**

---

## 7. La familia `OOS9xxx`

| Código | Condición |
|---|---|
| `OOS9001` | una entidad declara implementar una interfaz y no la satisface |
| `OOS9003` | `confidence` en un documento cuya madurez efectiva no es `DRAFT` |
| `OOS9004` | un concepto declarado localmente al que **nada referencia** |

`OOS9002` estaba aquí —*una propiedad con `is` redeclara lo que hereda*— y **se retiró al
escribir el esquema**. La exclusión se expresa entera con un `oneOf`, luego su incumplimiento
ya tiene código y es `OOS1004`: el mismo trato que la tabla de abajo le da a `confidence` sin
`is`, una fila más arriba. Inflar una familia por simetría con una tabla es lo contrario de
lo que P7 pide.

Y los que **no** hacen falta, que es lo informativo:

| Condición | Código | De dónde sale |
|---|---|---|
| una propiedad rebaja la clasificación de su concepto | `OOS4012` | v1alpha1, **sin cambios** |
| `is` o `requires` apuntan a algo inexistente | `OOS2001` | reservado en v1alpha1 |
| `confidence` sin `is` | `OOS1004` | el esquema lo expresa entero |
| tipo fuera del conjunto en un concepto | `OOS3001` | v1alpha1 |
| `nature` incoherente con su forma | `OOS2010` | v1alpha1, **sin cambios** — §5 |
| una propiedad con `is` redeclara `type` | `OOS1004` | el esquema lo expresa entero |

`OOS9004` es `OOS8002` un piso más arriba —*un objetivo que no casa con nada*— y por el mismo
motivo: **una regla que no gobierna nada y un concepto que nadie habla tienen exactamente el
mismo aspecto que los que funcionan.** No se aplica a un paquete sin entidades, que es como se
publica un vocabulario.

**Tres códigos nuevos y ninguno retirado**, medido con la implementación y los casos
delante. El borrador anunciaba cuatro y una absorción; se movió en las dos direcciones, y
las dos veces por el mismo método:

| Anunciado | Real | Qué lo decidió |
|---|---|---|
| `OOS9002`, código propio | **`OOS1004`** | escribir el esquema: la exclusión cabía en un `oneOf` |
| `OOS9001` absorbe `OOS2010` | **`OOS2010` se queda** | intentar escribir la interfaz incorporada — §5 |

Neto: el registro crece en tres en vez de en cuatro, y no encoge por ningún lado. Es menos
elegante de lo que prometía el borrador y es lo que hay.

`OOS9003` es del compilador y no del esquema por una razón concreta: la madurez es
**efectiva**, y una etiqueta heredada de la entidad o del `datasource` no está escrita en el
documento donde vive el `confidence`.

---

## 8. El ecosistema

| | Qué aporta | Por qué no se inventa |
|---|---|---|
| **`Binding`** de v1alpha1 | **el patrón del mapeo** | ya está: el modelo conserva el nombre, el mapeo declara la identidad |
| **`OOS4012`** | la dirección de la herencia | se puede elevar, no rebajar. Sube un nivel sin cambiar |
| **`confidence`** | la marca de lo inferido | **está en `basic.schema.json` desde v1alpha1** y llevaba cuatro versiones sin usuario |
| **`oos.maturity`** y `promote` | la frontera entre propuesta y verdad | retículo estándar y desclasificador del vocabulario cerrado. Sin añadir nada |
| **el retículo** | la clasificación que el concepto declara | sin cambios |
| **`Ruleset`** de v1alpha3 | el consumidor: gana un tercer eje de objetivo | `implements` junto a `atLeast` y `named` |

Las filas tercera y cuarta merecen leerse juntas, porque **el mecanismo de la propuesta ya
estaba entero** —el campo, el retículo y el desclasificador— y llevaba desde v1alpha1
esperando a que existiera algo que infiriera. Esta versión no lo construye: **lo conecta.**

**Y `Ossie` no aporta nada aquí, que es lo que hay que decir en voz alta.** El estándar con el
que componemos modela *datasets, métricas, dimensiones, relaciones y contextos* — vocabulario
de capa semántica, de BI. **No tiene interfaces ni propiedades compartidas.** Así que esto no
es adoptar: es **inventar**, y **P7** exige pagarlo:

> Sin el concepto compartido, la clasificación sobre la que descansa todo v1alpha3 es
> arbitraria, y cualquier inductor escribe cuatro mil conjeturas independientes en vez de
> cuatro mil mapeos sobre un vocabulario decidido.

De **Foundry** se adopta una cosa y se rechaza otra, y conviene separarlas. Se adopta **el
mapeo** —el concepto posee el significado, la entidad el nombre—, que es la parte que resuelve
el problema de las dos superficies. **No** se adopta que una interfaz cargue con acciones:
allí una interfaz lleva propiedades, enlaces y *actions*, y aquí una acción es una `Function`.
Que una `Function` pueda apuntar a una interfaz es una pregunta de v1alpha2, y va en §6 del
alcance como decisión abierta — no se resuelve metiéndola aquí.

---

## 9. Lo que este régimen no promete

- **Que se hayan declarado las formas correctas.** §6.1. Es la misma frontera que
  cobertura/adecuación, por tercera vez.
- **Descubrir sameness no declarada.** Dos propiedades que son el mismo concepto y no lo
  dicen son indistinguibles de dos que no lo son. Adivinarlo desde el nombre sería basar la
  solidez en parsear cadenas, y eso está decidido que no.
- **Impedir la inflación del vocabulario.** §4.2.2. Cuatro mil conceptos correctos y sesenta
  mal unificados son indistinguibles para un compilador, y hacer que acuñar «cueste» es
  ergonomía de quien propone, no una propiedad del artefacto.
- **Que un `confidence` alto signifique que el mapeo es correcto.** El número es una
  afirmación de quien lo escribió, y el compilador no lo interpreta: **no hay umbral**.
  Lo único que hace con él es impedir que sobreviva a la promoción — que es la diferencia
  entre exigir revisión y aparentar rigor con un decimal.
- **Que el concepto esté bien clasificado.** Que `gdpr.personalEmail` sea `high` es una
  afirmación de quien publica el paquete. El compilador comprueba que se respete, no que sea
  verdad — la misma honestidad que `01-efectos` §7 sobre la integridad de una fuente externa.
- **Limpiar los datos.** Un mapeo dice que dos cosas significan lo mismo. No las hace iguales,
  no las fusiona y no las normaliza. Fusionar registros es `Resolution` y es otra fila de la
  tabla de §1.
