# `Ruleset` — la regla que apunta

**Estado:** borrador. `spec/v1alpha1/` sigue mandando.
Aplica el régimen de [`01-gobierno`](01-gobierno.md).

---

## 1. Naturaleza

El único documento nuevo de v1alpha3, y reúne las reglas **sin sujeto** —aserciones,
máscaras de materialización y deberes— sobre un objetivo común, con un dueño.

Lo que lo hace un documento y no un bloque dentro de `Entity` no es su sintaxis:

> **Un paquete de reglas es un sujeto de autoridad.** Sus reglas se agrupan porque responde
> la misma persona por todas y entran y salen juntas.

Y de ahí sale todo lo demás. Un `Ruleset` tiene `owner` propio, versión propia y digest
propio porque **tiene que poder vivir en otro repositorio, con otros revisores y otra
cadencia** que la ontología a la que apunta. En un banco o en un ministerio, el responsable
de cumplimiento tiene que poder restringir el modelo sin poder editarlo; con reglas locales
eso es estructuralmente imposible, porque son el mismo fichero.

```yaml
apiVersion: oos.dev/v1alpha3
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
```

---

## 2. La forma exacta de un objetivo

Es lo que esta versión aporta, y por tanto donde hay que ser exacto.

### 2.1 · Es estructura, no una cadena

La primera redacción de [`01-gobierno`](01-gobierno.md) escribía el objetivo como texto —
`labelled: "gdpr.sensitivity >= high"`—. **Es incorrecto**, y por tres razones que se apilan:

| | |
|---|---|
| **P3** | una cadena es un mini-lenguaje, y un mini-lenguaje exige un analizador. **P3** prohíbe el cómputo arbitrario en un documento que gobierna, y esta es la clase de documento a la que P3 apunta |
| **la forma canónica** | `"gdpr.sensitivity >= high"` y `"gdpr.sensitivity>=high"` son bytes distintos con el mismo significado. **Dos digests para una ontología**, que es exactamente el fallo silencioso que N1–N8 existen para impedir |
| **el diff** | `OOS5xxx` clasifica un cambio por ejes —`CONSUMER`, `POLICY`…—. Sobre una cadena opaca, subir el objetivo de `high` a `critical` y reformatear el espacio en blanco son **el mismo cambio**. La familia de versionado deja de funcionar |

La tercera es la decisiva y no es una preferencia estética: **un objetivo en texto rompe una
familia de códigos que ya existe.**

### 2.2 · La gramática

```yaml
targets:
  - atLeast: { gdpr.sensitivity: high }
  - atLeast: { acme.residency: eu_only, gdpr.sensitivity: medium }
```

| | Semántica |
|---|---|
| dentro del mapa | **Y** — la propiedad debe satisfacer todas las entradas |
| entre elementos de la lista | **O** — la unión de las selecciones |

Es deliberadamente la semántica de `matchLabels` de Kubernetes, cuyo comportamiento está
documentado y es conocido: *«todos los requisitos se combinan con Y — deben satisfacerse
todos para casar»*. Se toma la semántica y **no** el resto del selector: `matchExpressions`
existe para etiquetas sin orden, y las nuestras lo tienen.

**Normativo.**

- `targets` es una **lista no vacía**. Cada elemento **DEBE** tener `atLeast` con al menos
  una entrada.
- Cada clave de `atLeast` **DEBE** ser el nombre cualificado de un `Lattice` declarado; si
  no, `OOS4003`, que ya cubre este caso.
- Cada valor **DEBE** ser uno de los niveles de ese retículo; si no, `OOS4003`.
- `targets` es un **conjunto**: N4 lo ordena. El orden no significa nada porque la unión es
  conmutativa — y eso lo separa de `Resolution.strategies`, que **sí** es una secuencia
  porque reordenarla cambia qué se fusiona.

### 2.3 · Un solo operador, y por qué

`atLeast` es el único, y no es una limitación de la primera versión: es una consecuencia.

> **El gobierno es monótono.** Si una regla se aplica a `high`, tiene que aplicarse a
> `critical`. Una regla que **deja** de aplicarse cuando el dato es más sensible es un
> defecto, no una funcionalidad.

Eso descarta `exactly` y `atMost` en un retículo de confidencialidad: los dos permiten
escribir una regla que exime a lo más grave, y ninguno tiene un caso de uso que no sea un
error. Un operador que solo sirve para equivocarse no se añade —**P7**.

Se nombra la relación en lugar de dejarla implícita, y eso sí es una decisión discutible que
conviene justificar. La forma `{ retículo: nivel }` **ya significa dos cosas opuestas** en el
árbol:

| Dónde | `{ gdpr.sensitivity: high }` significa |
|---|---|
| `metadata.labels` | *esto **es** high* — una asignación |
| `ConduitPolicy.conduits.<c>` | *hasta high* — un **techo** |
| `Ruleset.targets[].atLeast` | *high **o por encima*** — un **suelo** |

Un techo y un suelo con la misma forma, distinguidos solo por en qué documento estás, es una
trampa. Una palabra la elimina.

Y `atLeast` es además el que se emite: se corresponde con `odrl:gteq` del vocabulario de
operadores de ODRL, que es la lengua franca de los espacios de datos europeos
([`01-gobierno`](01-gobierno.md) §9).

### 2.4 · Qué selecciona

**Propiedades.** No entidades, y no hace falta ninguna regla nueva para que las etiquetas de
entidad funcionen: `02-entity` §4.1 ya dice que *«una etiqueta declarada en la entidad la
heredan todas sus propiedades»*, y que una propiedad **PUEDE** elevarla y **NO DEBE**
rebajarla (`OOS4012`).

Así que una entidad clasificada `eu_only` entera queda seleccionada por sus propiedades, sin
que este documento tenga que hablar de herencia. La decisión abierta 3 de
[`00-scope`](00-scope.md) queda cerrada así: **no era una decisión, era una comprobación.**

### 2.5 · Dónde se evalúa

> Un objetivo se evalúa **sobre el paquete que se compila**, no sobre el paquete que lo
> declara.

Esto es lo que invierte la relación de dependencia, y merece precisión porque
[`01-gobierno`](01-gobierno.md) §3 lo decía de forma más vaga —*«sobre el paquete y sus
dependientes»*—, que exigiría un índice inverso que no existe. No hace falta: en una
compilación el paquete objetivo es **el que se está compilando**, y sus dependencias
—incluido el `Ruleset`— entran con él.

De ahí sale la propiedad de producto:

| | Una dependencia de código | Un `Ruleset` |
|---|---|---|
| Se importa para | **usarla** | **quedar sujeto a ella** |
| Manda | quien importa | **lo importado** |

### 2.6 · Un objetivo vacío es un defecto

Un objetivo que no casa con ninguna propiedad es `OOS8002`, y conviene decir por qué no es
simplemente *«un conjunto vacío»*.

Casi nunca significa *«no hay nada así»*. Significa que alguien escribió mal un nivel, o que
el retículo cambió de niveles y la regla quedó apuntando a un nombre que ya no existe.
**Una regla que no gobierna nada tiene exactamente el mismo aspecto que una que funciona**, y
es el único fallo de este documento que no produce ningún síntoma.

Kubernetes tomó la decisión contraria —*«un selector de etiquetas vacío casa con todos los
objetos»*— y es una de sus trampas conocidas. Aquí no hay forma de escribir *«todo»*, y es
a propósito: una regla que gobierna todo el modelo no es gobierno, es una opinión.

---

## 3. Las aserciones — el perfil de ODCS

El cuerpo es `quality` de ODCS v3.1, decidido en v1alpha2 y sin cambios. Lo que este
documento fija es **qué parte se perfila**:

| Campo ODCS | En OOS |
|---|---|
| `type: library` | **admitido.** Sin dialecto: puede apuntar a cualquier conjunto |
| `type: sql` | **admitido**, con `OOS8005` — el objetivo no puede abarcar dos fuentes |
| `type: text` | **transportado sin interpretar.** Es prosa |
| `type: custom` | **transportado sin interpretar.** Nombra un motor externo |
| `metric` · `mustBe` · `mustBeGreaterThan` · `mustBeBetween` … | pasan. Vocabulario cerrado de ODCS |
| `dimension` | pasa — `accuracy`, `completeness`, `conformity`, `consistency`, `coverage`, `timeliness`, `uniqueness` |
| `severity` · `businessImpact` · `unit` · `description` | pasan |
| `schedule` · `scheduler` | **excluidos** |
| `customProperties` · `authoritativeDefinitions` | transportados sin interpretar, como en `Package` |

`schedule` y `scheduler` se excluyen por la frontera que `00-scope` §5 ya fija: **ningún
planificador.** Un `Ruleset` declara qué debe sostenerse; cuándo se comprueba es asunto del
motor que lo ejecute, y ODCS mismo dice que ese motor es Soda, Great Expectations o dbt.

```yaml
  assertions:
    - id: no-nulls
      metric: nullValues
      mustBe: 0
      dimension: completeness
      severity: error

    - id: sin-solapes
      type: sql
      query: |
        SELECT COUNT(*) FROM {object} a JOIN {object} b
        ON a.employeeId = b.employeeId AND a.periodEnd > b.periodStart
      mustBe: 0
```

**Normativo.**

- Una aserción `library` es independiente del dialecto y su objetivo puede abarcar cualquier
  número de fuentes.
- Una aserción `sql` está atada a un dialecto, y el dialecto solo se conoce donde se declara
  la fuente. Su objetivo **NO DEBE** seleccionar propiedades de más de una fuente física:
  `OOS8005`.
- `assertions` es un **conjunto**: N4 lo ordena. Todas deben sostenerse, así que el orden no
  significa nada. Es la otra mitad de N4 —*conjuntos ordenados, secuencias preservadas*— y
  la comparación con `Resolution.strategies` deja de ser arbitraria: **allí el orden decide
  qué gana; aquí no hay nada que ganar.**

> **P3 no aplica a una aserción, y ya estaba justificado** (v1alpha2 §3.1): P3 exige datos
> inertes en los documentos que **gobiernan** el acceso. Una aserción de calidad afirma una
> propiedad de los datos, no decide quién los ve. Por eso puede llevar SQL donde una
> precondición de `Function` no puede — y por eso el **objetivo**, que sí decide sobre qué se
> gobierna, no puede llevar ni una expresión (§2.1).

---

## 4. Las máscaras

Una máscara sin sujeto: el desclasificador que se aplica al construir el índice, que es el
hueco que [`99-errors`](../v1alpha1/99-errors.md) registró para v1alpha2 y v1alpha2 no cerró.

```yaml
  masks:
    - declassifier: tokenize
      to: { gdpr.sensitivity: low }
```

**Normativo.**

- `declassifier` **DEBE** pertenecer al conjunto cerrado de
  [`04-flow`](../v1alpha1/04-flow.md) §5. v1alpha1 prohíbe los definidos por el usuario y esa
  prohibición no se reabre.
- De ese conjunto, **`promote` no es admisible como máscara**, y excluirlo no es retirarlo:
  `promote` sube por un retículo de ciclo de vida y **una máscara tiene que bajar**. Sigue
  siendo un desclasificador para su propio uso. Quedan `mask`, `tokenize`, `redact` y
  `aggregate`.
- `to` **DEBE** declarar el nivel resultante, y ese nivel **DEBE** ser **estrictamente
  menor** que el `atLeast` de cada objetivo del documento. Si no, `OOS8003`.
- `to` **NO DEBE** declararse sobre `redact`: redactar hace desaparecer el valor, luego su
  salida es siempre el ínfimo del retículo. **Un campo derivable no es declarable** —P2, y
  la cuarta vez que este proyecto quita algo por la misma razón. **Y es estructural**: cabe
  entero en el esquema, así que es `OOS1005` y no `OOS8003`. Escribir el esquema dejó a
  `OOS8003` con una sola causa, igual que dejó a `OOS7010` sin ninguna.
- La comprobación es **local al documento**: compara dos niveles declarados. No hace falta
  recorrer las propiedades seleccionadas, porque ninguna puede estar por debajo del `atLeast`
  que las seleccionó.

La regla del descenso estricto es lo que ningún catálogo puede comprobar, y conviene decir
exactamente por qué. Una máscara de Unity Catalog o de Snowflake es una **función opaca**
evaluada en tiempo de consulta: nadie sabe qué clasificación sale por el otro lado, y por
tanto nadie puede decir si lo que sale puede ir a donde va. Un desclasificador que no baja no
es una salvaguarda —es teatro con coste de cómputo—, y aquí el compilador lo demuestra.

---

## 5. Los deberes

```yaml
  duties:
    - call: compliance.NotifyDPO
```

**Normativo.**

- `call` **DEBE** resolver a una `Function` declarada; si no, **`OOS2001`**.
- La función **DEBE** alcanzar la integridad que exija su propio destino. No hace falta
  código nuevo: es `OOS7001`, aplicado donde ya estaba.
- Un deber **NO TIENE** condición propia. **El objetivo del documento es la condición.**

Esa última es la decisión de forma que más se va a echar de menos, y por eso lleva motivo. Un
`when:` dentro del deber sería un **segundo lenguaje de selección** dentro del mismo
documento, y un documento con dos alcances es más difícil de auditar que dos documentos con
uno cada uno. Si el deber aplica a un subconjunto más estrecho, ese subconjunto tiene su
propio `Ruleset` — probablemente con otro dueño, que es justo lo que el documento existe para
permitir.

**Y lo que hoy no es.** Un deber declara **qué función responde** por un conjunto. *Cuándo*
tiene que correr es temporalidad, que sigue aplazada. Es la pieza más delgada de las tres en
esta versión, y se escribe ahora por una razón concreta: fijar el vocabulario **antes** de
que llegue el operador temporal. La lección está escrita en v1alpha2 §2 — el endosante
apareció inventado tres veces con tres nombres, y un concepto con tres nombres acaba con tres
semánticas.

Lo que sí hace falta desde el primer día es la restricción que lo hace exigible:

> **Un deber DEBE nombrar una `Function`.**

XACML murió de lo contrario. La crítica documentada es que *«contiene funcionalidades, como
las obligaciones, que no se corresponden limpiamente con ningún sistema de control de acceso
conocido»*: nombraban deberes que ningún runtime sabía ejecutar. Una referencia a una función
declarada trae su integridad computada, sus precondiciones, su endoso y su destino
comprobado.

**Y el código no es propio, que es lo interesante.** El borrador le dio `OOS8004`; escribir
los casos dejó ver que `OOS2001` lleva reservado desde v1alpha1 para exactamente esto:

> *«Se reserva porque `Function`, `Resolution` y `Test` introducen tipos de referencia nuevos
> en v1alpha2.»*

Un deber es el primer tipo de referencia nuevo que llega. **Activar una reserva es mejor que
inflar una familia**, así que `OOS8004` queda retirado antes de implementarse.

---

## 6. Qué cuenta para la cobertura

`OOS8001` exige que toda propiedad que exija gobierno esté cubierta. Aquí se define
**cubierta**, y no es *«aparece en algún objetivo»*.

> **Solo cuenta lo que el compilador puede leer y lo que puede fallar.**

Una regla, tres consecuencias, y las tres cierran un agujero antes de que exista:

| | ¿Cuenta? | Por qué |
|---|---|---|
| aserción `library` o `sql` con `severity: error` | **sí** | legible y puede fallar |
| aserción con `severity: warning` | **no** | un aviso es, por definición, *«lo vimos y no paramos nada»*. No descarga la obligación de gobernar |
| aserción `type: text` o `type: custom` | **no** | se transporta sin interpretar. El compilador no sabe qué afirma |
| **máscara** | **sí** | el compilador la lee, `OOS8003` la puede rechazar, y una propiedad enmascarada está gobernada |
| **deber** | **no** | no puede fallar al compilar: su incumplimiento es un hecho temporal |

Sin esta regla, `OOS8001` se satisface con una aserción `severity: warning` que no para nada,
y **la cobertura pasa a medir que alguien escribió un fichero**. Es el modo de fallo más
probable de todo v1alpha3, porque es el que aparece cuando alguien tiene prisa por hacer
verde una compilación.

Y aun con la regla, el límite se mantiene y no se disimula: ver §9.

---

## 7. Lo que **no** es un campo

Cuarta vez que la ley aparece, y ya no sorprende:

| | Por qué no |
|---|---|
| `when` en un deber | el objetivo del documento es la condición (§5) |
| `to` en un `redact` | derivable: es el ínfimo del retículo (§4) |
| `enabled` | una regla desactivada es una regla que no está |
| `priority` / orden | `assertions` es un conjunto: todas se sostienen. No hay nada que desempatar (§3) |
| el operador del objetivo | el gobierno es monótono, luego solo hay uno (§2.3) |

La cuarta fila conviene leerla junto a `Resolution`. Allí `strategies` **es** una secuencia y
N4 preserva su orden, porque la primera que casa gana. Aquí no gana ninguna: se sostienen
todas. **La misma regla de forma canónica trata los dos casos distinto porque los dos casos
son distintos**, y ahora está escrito por qué.

---

## 8. Errores

| Código | Condición |
|---|---|
| `OOS8001` | propiedad que exige gobierno y ninguna regla **que cuente** la cubre (§6) |
| `OOS8002` | objetivo que no casa con ninguna propiedad (§2.6) |
| `OOS8003` | máscara cuyo `to` no es estrictamente menor que el `atLeast` del objetivo (§4) |
| `OOS8005` | aserción `sql` cuyo objetivo abarca más de una fuente física (§3) |
| `OOS8006` | **objetivo** sobre un retículo de eje `integrity` (§9) |

`OOS8006` salió de escribir este documento, igual que `OOS7008` salió de escribir `Function`.
No estaba en el registro de [`01-gobierno`](01-gobierno.md) §8 y se añade.

**Y escribir el esquema encogió tres de ellos**, que es el mismo mecanismo en la otra
dirección:

| | Antes | Ahora |
|---|---|---|
| `OOS8003` | dos causas | **una** — `to` sobre un `redact` cabe en el esquema |
| `OOS8006` | dos causas | **una** — `requiresGovernance` en un eje `integrity` también cabe |
| `OOS8004` | un código | **retirado** — es `OOS2001`, reservado desde v1alpha1 (§5) |

Y los que **no** hacen falta, que es igual de informativo: un retículo o un nivel inexistentes
en un objetivo son `OOS4003`; una función que no alcanza su destino es `OOS7001`; un
`Ruleset` sin `owner` es `OOS1005`. **Este documento añade cinco códigos y reutiliza cuatro
familias** —`OOS1005`, `OOS2001`, `OOS4003` y `OOS7001`—, y esa proporción es la señal de que
la partición de [`01-gobierno`](01-gobierno.md) §4 estaba bien hecha.

---

## 9. Aplazado

- **`atMost`, y con él el gobierno sobre el eje de integridad.** La monotonía de §2.3 corre
  en dirección contraria en ese eje: en confidencialidad se gobierna *hacia arriba* —más
  sensible, más gobierno—, y en integridad se gobernaría *hacia abajo* —menos fiable, más
  gobierno—. Hasta que eso esté escrito, un objetivo o un `requiresGovernance` sobre un
  retículo `integrity` es `OOS8006`, no un comportamiento sin definir. Y hay una sospecha
  que conviene dejar anotada: el remedio natural de la baja integridad es **un endoso**, que
  es asunto de `Function` y no de un `Ruleset`.
- **La exigibilidad de un deber.** Necesita el operador temporal. Va con `Test` y con lo
  temporal, después de L2.
- **La frontera entre cobertura y utilidad.** §6 elimina los tres huecos baratos —lo
  ilegible, lo que no falla, lo que no puede fallar al compilar— y no elimina el caro:
  **una política que permite todo cubre igual que una que no permite nada.** Lo que se sabe
  hoy es que el siguiente paso es **tipar la cobertura por naturaleza** —que una propiedad
  con PII exija una regla de *autorización* y no le valga una de calidad—, y eso exige
  decidir qué naturaleza satisface qué exigencia, que es una tabla que nadie ha escrito.
  Queda anotado, no improvisado.
