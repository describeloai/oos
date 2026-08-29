# El régimen de gobierno

**Estado:** borrador. `spec/v1alpha1/` sigue mandando.

El núcleo de v1alpha3. Todo lo demás de esta versión se deriva de lo que aquí se decide.

---

## 1. Esto ya estaba escrito

v1alpha3 no introduce el gobierno. v1alpha1 lo declaró y lo dejó **inerte**, en tres frases
que llevan dos versiones sin sitio donde aplicarse:

| Dónde | Qué dice | Qué falta |
|---|---|---|
| [`04-flow`](../v1alpha1/04-flow.md) §5 | *«Es el vocabulario cerrado de obligaciones, visto desde la teoría de flujo de información»* — `mask`, `tokenize`, `redact`, `aggregate` | **dónde se enganchan.** Hoy solo mediante una anotación de Cedar que nadie comprueba |
| [`00-overview`](../v1alpha1/00-overview.md) §7.1 | *«Obligaciones como vocabulario cerrado»*, reclamado como algo que ningún estándar tiene | la afirmación es cierta y **el mecanismo no existe** |
| [`99-errors`](../v1alpha1/99-errors.md) | *«No existe forma de desclasificar en tiempo de materialización […] Queda anotado, no improvisado»* | anotado **para v1alpha2**, que no lo tocó |

Las tres necesitan lo mismo, y por eso son un solo problema: **una forma de nombrar un
conjunto de propiedades por su clasificación, fuera de una política de Cedar.**

Y la tercera fila dice por qué no se pudo antes. Desclasificar al materializar no es una
decisión sobre nadie: el índice se construye **sin sujeto**. Cedar exige un `principal`. No
había ningún otro sitio donde poner la obligación, así que no se puso.

---

## 2. El gobierno deja de ser local

En v1alpha1 y v1alpha2 **toda regla se escribe sobre el documento que gobierna**. La
etiqueta está en la propiedad. La autorización del conducto, en la `ConduitPolicy`. El
efecto, dentro de la `Function`. El gobierno es local, y ser local tiene un precio que no se
ve hasta que el modelo crece:

> Una regla local **enumera**. Cubrir cuatrocientas propiedades clasificadas exige
> escribirla cuatrocientas veces, y la que se clasifique mañana queda fuera en silencio.

Ese modo de fallo —**el silencioso**— es el mismo que justifica que exista un compilador.
`OOS4001` existe porque nadie ve una etiqueta a dos saltos; esto existe porque nadie ve una
propiedad que *ninguna* regla menciona.

Y hay media solución ya en el árbol, que es lo que delata que falta la otra media. La
proyección a esquema Cedar existe precisamente para que una política diga

```cedar
permit(principal, action, resource in Label::"gdpr.sensitivity:high");
```

**en lugar de enumerar propiedades**. Por eso una entidad nueva queda gobernada el día que
se etiqueta — *si lo que la gobierna es una política*. Si lo que la gobierna es una
restricción de calidad, una máscara de materialización o un deber, no hay nada equivalente.

**La autorización apunta por clasificación y todo lo demás enumera.** Esa asimetría es el
defecto que esta versión corrige.

---

## 3. Una etiqueta ya es un conjunto

Aquí está lo que hace que la pieza que falta sea gratis.

v1alpha1 declara un retículo para poder **comparar dos elementos**: la regla de flujo es
`L ⊑ C`, y todo el aparato existe para decidir esa relación. Pero un orden no solo compara:
**selecciona**.

> `gdpr.sensitivity: high` sobre cuatrocientas propiedades **ya define un conjunto de
> cuatrocientas propiedades.** v1alpha1 nunca lo miró así.

El mismo orden, leído en la otra dirección, nombra el conjunto:

| Leído | Es | Se usa en |
|---|---|---|
| `L(x) ⊑ C` | una **comparación** | la regla de flujo · v1alpha1 |
| `{ x : L(x) ⊒ n }` | una **selección** | el objetivo · v1alpha3 |

De ahí sale lo que importa: **el objetivo no es un lenguaje nuevo.** Es el retículo que ya
está declarado, y es decidible al compilar exactamente por la misma razón que `⊑` lo es.
No hay motor de consultas, no hay expresiones, no hay dependencia añadida.

**Normativo.**

- Un objetivo **DEBE** escribirse como una relación de orden sobre un retículo declarado:
  `>=`, `>`, `==` sobre uno de sus niveles. Nada más — un objetivo no es una expresión.
- El retículo referenciado **DEBE** existir; si no, `OOS4003`, que ya cubre este caso.
- La selección se evalúa **sobre el paquete y sus dependientes**, no sobre el paquete que
  la declara (§6.1).
- Un objetivo que no casa con nada es un defecto, no un conjunto vacío: `OOS8002`.

Esa última regla merece su motivo escrito. Un objetivo vacío casi nunca significa *«no hay
nada así»*; significa que alguien escribió mal una etiqueta, o que el retículo cambió de
niveles y la regla se quedó apuntando a un nombre que ya no existe. **Una regla que no
gobierna nada tiene exactamente el mismo aspecto que una regla que funciona**, y es la única
clase de fallo de este documento que no produce ningún síntoma.

---

## 4. La partición: ¿hay sujeto?

Con el objetivo en la mano, dónde vive cada regla deja de ser una cuestión de gusto. Las
cinco naturalezas ([`00-scope`](00-scope.md) §2) se reparten con **una sola pregunta**:

> **Si hay sujeto, es Cedar. Si no lo hay, es un `Ruleset`.**

| Naturaleza | ¿Sujeto? | Dónde vive | Estado |
|---|---|---|---|
| **1** · restricción | no | `Ruleset` — o la propiedad, si es una sola | §5.1 |
| **2** · derivación | no | `Entity.expr` | ya colocada · v1alpha2 |
| **3** · autorización | **sí** | Cedar | ya colocada · v1alpha1 |
| **4** · obligación | depende | `Ruleset` sin sujeto · anotación de Cedar con él | §5.3 |
| **5** · transformación | depende | igual que la 4 | §5.2 |

No es una taxonomía impuesta: es la que ya seguía el árbol sin decirlo. Y explica el hueco
de §1 sin añadir nada — desclasificar al materializar **no tiene sujeto**, el único
mecanismo disponible exigía uno, y por eso el hueco se registró en lugar de cerrarse.

Un corolario que evita la duplicación más probable de esta versión:

> Una regla sobre **una** propiedad se escribe donde está la propiedad. Una regla sobre
> **una clase** de propiedades se escribe donde está la clase.

El caso enumerado ya tiene sitio —`quality` de ODCS colgando de la propiedad, decidido en
v1alpha2— y por eso `Ruleset` **NO DEBE** admitir objetivos por enumeración. Dos formas de
escribir lo mismo acaban con dos semánticas, que es la lección que este proyecto ya aprendió
tres veces.

---

## 5. Las tres piezas

### 5.1 · La aserción

El cuerpo es `quality` de ODCS, decidido en v1alpha2 y sin cambios. Lo único que v1alpha3
añade es que **puede apuntar**:

```yaml
kind: Ruleset
metadata: { name: gdpr-minimization, namespace: eu }
spec:
  owner: team:compliance
  targets:
    - labelled: "gdpr.sensitivity >= high"
  assertions:
    - metric: nullValues
      mustBe: 0
      dimension: completeness
```

**Normativo.**

- Una aserción de tipo `library` —`nullValues`, `duplicateValues`, `rowCount`…— es
  **independiente del dialecto** y puede apuntar a cualquier conjunto.
- Una aserción de tipo `sql` está atada a un dialecto, y el dialecto solo se conoce donde se
  declara la fuente. Por tanto su objetivo **NO DEBE** abarcar más de una fuente física:
  `OOS8005`.

`OOS8005` es `OOS7008` con el signo cambiado, y que aparezca sin buscarlo es la señal de que
la partición de §4 no era una analogía. Allí **una transacción no cruza dos fuentes**; aquí
**una regla atada a un dialecto tampoco**. La limitación se hereda de ODCS y conviene
escribirla en vez de fingir que no está.

### 5.2 · La máscara

Aquí es donde la afirmación de `00-overview` §7.1 se vuelve verdad.

Cedar resuelve `permit` y `forbid`, y eso es la mitad del campo. La otra mitad —*permite,
pero transformado*— es el requisito primero de cualquier comprador regulado, y **v1alpha1 ya
tiene su vocabulario**: los desclasificadores de `04-flow` §5 son exactamente eso. Lo que
faltaba no era el concepto sino el enganche.

Y hay dos enganches, porque §4 dice que los hay:

| | Quién decide | Cuándo | Dónde se escribe |
|---|---|---|---|
| **máscara de política** | Cedar, con `principal` | por consulta y por sujeto | anotación de política — el sitio que `00-overview` §5 ya nombraba |
| **máscara de materialización** | el objetivo, **sin sujeto** | al construir el índice | `Ruleset` |

La segunda es el hueco de §1, y se cierra sin vocabulario nuevo. El caso que lo registró
—*«cachear correos tokenizados para unir por ellos»*— se escribe así:

```yaml
  targets:
    - labelled: "gdpr.sensitivity >= high"
  masks:
    - declassifier: tokenize
```

**Normativo.**

- El desclasificador **DEBE** pertenecer al conjunto cerrado de
  [`04-flow`](../v1alpha1/04-flow.md) §5. v1alpha1 ya prohíbe los definidos por el usuario y
  esa prohibición no se reabre.
- La propiedad enmascarada **DEBE** estar clasificada en el retículo del objetivo. Sin
  etiqueta no hay nada que bajar, y una máscara sobre un dato sin clasificar es una máscara
  que no protege de nada: `OOS8003`.
- La etiqueta resultante **DEBE** ser **estrictamente menor** que la original. Un
  desclasificador que no baja no es una salvaguarda: es teatro con coste de cómputo, y el
  compilador puede demostrarlo porque el desclasificador declara qué produce (`OOS8003`).

Esa última regla es lo que ningún catálogo puede comprobar. Una máscara de Unity Catalog o
de Snowflake es una función opaca que se evalúa en tiempo de consulta: nadie sabe qué
clasificación sale por el otro lado, y por tanto nadie puede decir si lo que sale puede ir a
donde va. **Aquí sí, y el efecto de la máscara sobre el flujo se computa al compilar.**

### 5.3 · El deber

Un deber es la única de las cinco naturalezas que no encaja en la forma común: no dice qué
debe *ser cierto*, dice qué debe *llegar a ocurrir*. Introduce un operador modal, y con él
el tiempo.

Aquí está la lección más cara del campo, y hay que obedecerla:

> XACML murió de sus obligaciones. La crítica documentada es que *«contiene funcionalidades,
> como las obligaciones, que no se corresponden limpiamente con ningún sistema de control de
> acceso conocido»*: **nombraban deberes que ningún runtime sabía ejecutar.**

De ahí sale la única restricción que hace falta, y por qué esto no se podía escribir antes:

> **Un deber DEBE nombrar una `Function`.**

Un deber en prosa —*«notifíquese al delegado de protección de datos»*— es exactamente lo que
mató a XACML. Una referencia a una función declarada, no: trae su integridad computada, sus
precondiciones, su endoso y su destino comprobado. **La capa de política estaba esperando a
que existieran los verbos**, y esa es la razón de que v1alpha3 venga después de v1alpha2 y no
al revés.

```yaml
  duties:
    - when: "gdpr.sensitivity >= critical"
      call: compliance.NotifyDPO
```

**Normativo.**

- `call` **DEBE** resolver a una `Function` existente; si no, `OOS8004`.
- La función **DEBE** alcanzar la integridad que exija su propio destino. No hace falta regla
  nueva: es `OOS7001`, aplicada donde ya estaba.
- Lo que **no** es decidible al compilar es que el deber llegue a cumplirse. Un deber es
  **declarable y comprobable en su forma**, y **no exigible** hasta que exista temporalidad
  (§8).

---

## 6. La regla de cobertura

Lo que esta versión aporta al régimen, y el equivalente de `L ⊑ C` y de `I(f) ⊒ I(destino)`.

> **∀x . L(x) ⊒ n ⟹ ∃r . x ∈ objetivo(r)**
>
> Nada clasificado por encima del nivel que exige gobierno puede quedar sin ninguna regla
> que lo cubra.

Con lo que la trilogía se cierra, y cada versión aporta una regla y solo una:

| | Regla | Dice |
|---|---|---|
| **v1alpha1** | `L ⊑ C` | nada **fluye** por encima de su autorización |
| **v1alpha2** | `I(f) ⊒ I(destino)` | nada **escribe** por encima de su integridad |
| **v1alpha3** | `L(x) ⊒ n ⟹ ∃r` | nada clasificado queda **sin gobernar** |

### 6.1 · La exigencia viaja con la clasificación

La cobertura no se exige siempre: se **declara**, y se declara en el sitio que ya existe.

```yaml
kind: Lattice
metadata: { name: sensitivity, namespace: gdpr }
spec:
  levels: [none, low, medium, high, critical]
  requiresGovernance: high      # ← desde aquí arriba, nada sin cubrir
```

Un campo, en el documento que ya declara los niveles. Y la consecuencia es la que convierte
una frase de marketing en un mecanismo:

> **«GDPR como dependencia» deja de ser una metáfora.**

Importar el paquete de clasificación importa **su exigencia**. A partir de ese momento el
paquete no compila si alguien clasifica una propiedad como `high` y no la cubre nadie — y no
hace falta que quien la clasificó se entere de nada.

Eso invierte la relación que tiene una dependencia normal, y conviene decirlo en voz alta:

| | Una dependencia de código | Un paquete de clasificación |
|---|---|---|
| Se importa para | **usarla** | **quedar sujeto a ella** |
| Quien manda es | quien importa | **lo importado** |

**Una dependencia que gobierna a quien la importa.** Es exactamente lo que un paquete
regulatorio tiene que ser, y es la razón de que §3 evalúe el objetivo sobre los
*dependientes* y no sobre el paquete que lo declara.

### 6.2 · Qué es decidible al compilar

Todo lo de esta regla, y es lo que la hace útil:

| | |
|---|---|
| qué propiedades casan con un objetivo | **L0** — es `⊒` sobre etiquetas declaradas |
| qué propiedades exigen gobierno | **L0** — es `requiresGovernance` sobre las mismas |
| si alguna queda sin cubrir | **L0** — es la diferencia de dos conjuntos |
| si la regla que la cubre es **la correcta** | **no es decidible** — §9 |

Que la comprobación completa sea una diferencia de conjuntos calculada sin datos, sin reloj y
sin red es lo que permite que la evidencia sea un **artefacto**: *estas reglas cubrían estas
propiedades en este commit*. Un auditor no tiene que creerse un informe; puede recomputarlo.

---

## 7. El paquete es un sujeto de autoridad

Por qué esto es un documento con dueño y versión, y no un bloque más dentro de `Entity`.

Las reglas de un `Ruleset` no se agrupan porque se parezcan —una comprobación de nulos y un
deber de notificación no se parecen en nada—, sino porque **responde la misma persona por
todas y entran y salen juntas**.

> **Un paquete de reglas es un sujeto de autoridad.**

Y de ahí sale el argumento que decide el diseño para el comprador que importa. En un banco o
en un ministerio, el responsable de cumplimiento **tiene que poder restringir la ontología
sin poder editarla**. Eso es separación de funciones, es exigencia dura —SOX, DORA, NIS2— y
con reglas locales es **estructuralmente imposible**: mismo fichero, mismo `CODEOWNERS`,
mismo permiso de escritura.

**Normativo.**

- Un `Ruleset` **DEBE** declarar `owner`, y ese dueño es independiente del de los paquetes a
  los que apunta.
- Un `Ruleset` es un documento con identidad, digest y versión como cualquier otro: puede
  publicarse, firmarse y depender de él. La firma es in-toto/Sigstore, ya adoptado.

No hay código para *«paquete sin dueño»*: es una clave obligatoria y por tanto un fallo
estructural, `OOS1005`. Un código semántico para algo que el esquema resuelve es peso muerto
—lección de `OOS7010`, y esta vez antes de escribirlo.

---

## 8. La familia `OOS8xxx`

| Código | Condición |
|---|---|
| `OOS8001` | propiedad que exige gobierno y **no la cubre ninguna regla** (§6) |
| `OOS8002` | objetivo que no casa con nada (§3) |
| `OOS8003` | máscara sobre una propiedad sin clasificar, o cuyo desclasificador no baja la etiqueta (§5.2) |
| `OOS8004` | deber que no resuelve a una `Function` existente (§5.3) |
| `OOS8005` | aserción `sql` cuyo objetivo abarca más de una fuente física (§5.1) |

`OOS8001` es el `OOS4001` de este plano: el error que ningún revisor encuentra, porque el
defecto **no está escrito en ninguna parte** — es la ausencia de una línea que nadie
escribió. Los otros cuatro son comprobaciones locales.

Y los que **no** hacen falta, que es igual de informativo: un objetivo que referencia un
retículo inexistente es `OOS4003`; una función que no alcanza su destino es `OOS7001`; un
`Ruleset` sin dueño es `OOS1005`. **Este plano añade cinco códigos y reutiliza tres
familias**, que es lo que se espera cuando la partición de §4 es la correcta.

Este registro se moverá al escribir el documento de `Ruleset`. Ya pasó dos veces —`OOS7008`
apareció al escribir `Function`, `OOS7010` se retiró al escribir el esquema de
`Resolution`— y es el mecanismo funcionando, no un fallo de planificación.

---

## 9. El ecosistema

Acotado a propósito, y con una particularidad: **la mayoría de las piezas ya estaban
adoptadas.** Esta versión es sobre todo cableado.

| | Qué aporta | Por qué no se inventa |
|---|---|---|
| **el retículo de v1alpha1** | **el lenguaje del objetivo** | no es una dependencia nueva: es la que ya está, leída al revés (§3) |
| **los desclasificadores de v1alpha1** | qué le ocurre al dato | vocabulario cerrado desde `04-flow` §5 |
| **`quality` de ODCS** | el cuerpo de una aserción | decidido en v1alpha2 |
| **Cedar** | la decisión con sujeto, ahora con una salida que no es booleana | ya adoptado; las anotaciones son donde la obligación se nombra |
| **`Function` de v1alpha2** | el cuerpo de un deber | es lo que hace exigible una obligación en vez de retórica |
| **Soda · Great Expectations · dbt-tests** | **quién ejecuta la aserción** en L2 | no ejecutamos: emitimos, y ODCS ya declara compatibilidad |
| **in-toto · Sigstore** | la firma del dueño del paquete | ya adoptado |
| **ODRL 2.2** | **objetivo de emisión, no anfitrión** | ver abajo |

**ODRL merece su párrafo**, porque es el candidato obvio y la respuesta es la de Ossie.

Es Recomendación del W3C desde 2018 y **el único estándar que modela deberes** junto a
permisos y prohibiciones — que es justo lo que a Cedar le falta. No se adopta como modelo
interno por tres razones: es **RDF**, con el mismo coste que descartó a SHACL; modela
**licencias entre partes** sobre activos, no gobierno sobre una superficie propia; y sus
deberes **no tienen semántica de ejecución**, que es el fallo de XACML otra vez. Nuestros
deberes nombran una `Function`, y eso es estrictamente más fuerte.

Pero es **la lengua franca de los espacios de datos europeos** —Gaia-X e IDSA expresan en
ODRL sus políticas de uso—, y ese es exactamente el comprador gubernamental. Así que es
**objetivo de emisión**: la misma posición que Ossie ocupa para la entidad
([`00-overview`](../v1alpha1/00-overview.md) §7.2-bis). Se emite hacia él; no se aloja en él.

Lo que **no** entra, y conviene que se vea la ausencia: **ningún motor de reglas**. No
evaluamos aserciones, no planificamos deberes, no hay cola ni programador. Un `Ruleset` es
una declaración gobernada, no una tubería. En el momento en que este documento tuviera que
hablar de reintentos, el alcance se habría roto — es la misma frontera que `01-efectos` §6
puso para las funciones.

---

## 10. Lo que este régimen no promete

Escrito aquí para que no haya que descubrirlo:

- **Que el dato cumpla la aserción.** Se comprueba que la aserción sea legal, que apunte a
  algo y que la cobertura esté completa. Evaluarla contra filas es L2, y lo hacen Soda,
  Great Expectations o dbt.
- **Que la máscara redacte de verdad.** El compilador comprueba que el desclasificador
  declare que baja, y qué implica eso para el flujo. Que la función devuelva realmente los
  últimos cuatro dígitos es responsabilidad de sus pruebas — la misma honestidad que
  `02-function` §5.1.
- **Que el deber se cumpla.** Declararlo es L0; que llegue a ocurrir necesita tiempo, y el
  tiempo sigue aplazado.
- **Que dos motores enmascaren igual.** El vocabulario de desclasificadores es cerrado; su
  implementación byte a byte no está especificada. `mask(LAST4)` significa lo mismo en todas
  partes en el retículo, no necesariamente en la salida.
- **Cobertura no es corrección.** Y esta es la que más importa, porque es la que un vendedor
  exageraría: `OOS8001` demuestra que **existe** una regla, no que sea **la adecuada**. Una
  política que permite todo cubre igual que una que no permite nada. El compilador elimina el
  fallo por olvido, que es el mayoritario; no elimina el fallo por criterio, que es el caro.
