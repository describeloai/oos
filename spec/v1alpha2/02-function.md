# `Function` — la superficie de efecto

**Estado:** alcance cerrado, primera versión. `spec/v1alpha1/` sigue siendo la versión normativa.
Aplica el régimen de [`01-efectos`](01-efectos.md).

---

## 1. Naturaleza

Una `Function` es **el único canal por el que la ontología puede causar algo**, y por tanto
el único punto donde termina la pureza del compilador.

No es un endpoint, ni un procedimiento almacenado, ni un paso de un flujo de trabajo. Es
**una autoridad enumerada**: lo que un actor puede causar es exactamente la unión de las
funciones que puede invocar, y esa unión se lee en un pull request.

De ahí sale la propiedad que interesa: **un agente no recibe credenciales, recibe una
superficie.** Fuera de las funciones declaradas no hay forma de escribir nada — no porque
se prohíba, sino porque no hay canal.

---

## 2. Lo que **no** es un campo

Escribir este documento a partir del borrador de `docs/vision/` consistió sobre todo en
**quitar**, y las tres cosas que se quitan comparten una razón:

> Un valor constante no es un campo. Y un campo que solo tiene un valor seguro es, en la
> práctica, la forma de apagarlo.

| El borrador declaraba | Por qué desaparece |
|---|---|
| `network: DENY` | El sandbox **no tiene red**. Declararlo invita a `network: ALLOW`, y entonces el aislamiento pasa a ser una opción de despliegue en lugar de una propiedad del régimen |
| `transaction.scope: single-datasource` | Es el único valor admitido, así que no es una declaración: es **una regla comprobable** (§5.2). Mejor un error que un campo |
| `audit.logInvocations: ALL` | Si es declarable, es desactivable. **Toda invocación se registra**, y eso no se negocia en el documento. A dónde va el registro es configuración de despliegue, no significado de la ontología |

La misma disciplina que ya aplicó **P2** a los campos derivables, aplicada a los campos
constantes.

---

## 3. Anatomía

```yaml
apiVersion: oos.dev/v1alpha2
kind: Function
metadata:
  name: approvePurchaseOrder
  namespace: supply_chain
spec:
  runtime: wasm
  entrypoint: dist/approve_purchase_order.wasm
  source: src/approve_purchase_order.ts     # procedencia, no verificada por sí sola
  limits: { timeout: 5s, memory: 64Mi }

  input:
    purchaseOrderId: { type: String, required: true }
    approvalNote:    { type: String }
  output:
    approved: { type: Boolean }

  preconditions:
    - id: order-is-pending
      expr: 'target.status == "PENDING_APPROVAL"'
      message: "Solo se aprueban pedidos en PENDING_APPROVAL"

  effects:
    - writes: supply_chain.PurchaseOrder.status
      datasourceRef: postgres_erp
      to: "APPROVED"

  endorsements:
    - endorser: attested
      attestation: attestations/approve_purchase_order.intoto.jsonl

  authorization: supply_chain.ProcurementApproval    # política Cedar
  idempotency: { key: "{purchaseOrderId}:{subject.id}", window: 24h }
```

`source` **NO DEBE** tomarse como garantía de nada por sí solo: nada ata ese fichero a ese
binario. Lo que sí lo ata es una atestación de procedencia, y por eso `attested` es a la
vez el endosante de integridad y la única razón por la que `source` significa algo.

---

## 4. El contrato con quien invoca

### 4.1 · Entradas y salidas

Tipadas con el sistema de tipos de `02-entity` §3. Sin tipos nuevos y sin excepciones: una
función que quisiera recibir un `Money<EUR, 2>` lo recibe con su unidad y su precisión.

### 4.2 · Las precondiciones son del contrato, no del código

Es la decisión de producto del documento, y la diferencia con validar dentro de la función
no es de estilo:

| | Quién sabe qué |
|---|---|
| validación **dentro** del código | el agente tiene que **intentarlo para saber** |
| precondición **en el contrato** | el agente **sabe qué puede intentar antes de intentarlo** |

Un agente que descubre las reglas fallando es un paseo aleatorio con efectos secundarios.
Uno que las lee es un consumidor de una superficie.

**Normativo.**

- `expr` **DEBE** ser una expresión CEL: total, terminante y sin efectos (**P3**).
- El motor **DEBE** evaluar todas las precondiciones **antes** de ejecutar el código, y
  **NO DEBE** ejecutarlo si alguna falla.
- Una precondición **lee**. Su `expr` está sujeta a la regla de flujo de `04-flow` **sin
  ninguna extensión**: una precondición que consulta `salary` hace fluir `salary` hacia la
  decisión, y el sandbox es el conducto. No hace falta ningún código nuevo para esto — es
  `OOS4001` y `OOS4002` haciendo su trabajo.

---

## 5. Los efectos

### 5.1 · Se declaran, no se descubren

Y hay un mecanismo detrás de la frase, no una convención:

> **La función no escribe. El motor escribe en su nombre lo que ella declaró.**

La función recibe entradas y devuelve salidas. Si pudiera escribir por su cuenta, `effects`
sería documentación; así es lo único que puede ocurrir.

Un efecto **DEBE** nombrar la propiedad (`writes`) y la fuente (`datasourceRef`). **PUEDE**
acotar la transición con `from` y `to`, y si lo hace, el motor **DEBE** hacerla cumplir.

`from` y `to` viven aquí y **no** se repiten como precondición. No son una comprobación
más: **acotan lo que la función puede causar**, que es exactamente lo que la regla de
integridad razona. Declararlos en los dos sitios sería el mismo valor con dos dueños.

### 5.2 · Una función, una fuente

Todos los efectos de una función **DEBEN** apuntar al mismo `datasourceRef`. Si no,
`OOS7008`.

No es una limitación de implementación disfrazada de regla: escribir atómicamente en
PostgreSQL y en Salesforce a la vez **no es algo que este motor pueda prometer**, y un
régimen que promete lo que no cumple no gobierna nada. La regla convierte esa honestidad en
algo que falla al compilar en vez de fallar en producción a medias.

### 5.3 · Lo que no puede ser destino

Una propiedad con `derivedFrom` **NO DEBE** ser destino de un efecto (`OOS7006`). Se
computa; declarar que además se escribe es afirmar dos orígenes para el mismo valor, y el
compilador no puede saber cuál gana. Es el dual exacto de `OOS4008`.

---

## 6. La integridad de una función **se computa**

Aquí está la pieza que `01-efectos` §4.1 dejó nombrada y sin mecanismo.

> Una `Function` **NO DEBE** declarar su propia etiqueta de integridad.

Sería una afirmación sobre sí misma, y una afirmación no es una garantía: cualquier función
podría escribir `attested` en sus metadatos sin que exista atestación alguna. Es el mismo
defecto que `OOS4008` —lo derivable no se declara, **P2**— aplicado al otro eje.

`I(función)` se computa de sus endosos:

| Endosos | `I(función)` |
|---|---|
| ninguno | **⊥** — el mínimo del retículo |
| `attested` verificado | el nivel que la atestación afirma |
| `humanApproval` **incondicional** | el nivel que el endosante declare cubrir |

### 6.1 · Un endoso condicional no cierra una carencia

El borrador escribía la aprobación humana con condición:

```yaml
requireHumanApproval:
  when: target.totalAmount > 50000
```

Y eso, como endoso, **no vale**: si la condición es falsa no hay aprobación, luego no hay
elevación, luego la carencia sigue abierta en el caso que importa. Un endoso condicional es
un control de negocio adicional, no un endoso.

**Normativo.** Un endoso **PUEDE** llevar `when`, pero solo los **incondicionales** cuentan
para satisfacer la regla de integridad. Una función cuya carencia solo esté cubierta por un
endoso condicional es `OOS7002`.

### 6.2 · La consecuencia que hace usable el régimen

Una función sin atestación tiene integridad ⊥ y **no puede escribir nada que importe**. Eso
suena a que nada funciona hasta firmarlo todo, y es al revés:

> Una función sin firmar puede operar igual — con un humano firmando cada vez. **Atestar el
> bundle es lo que convierte la aprobación humana de requisito en opción.**

Es la rampa correcta: se empieza con humanos en el bucle, y la automatización se gana
demostrando procedencia, no pidiéndola.

---

## 7. Autorización

`authorization` referencia una política **Cedar**. OOS no define un lenguaje de
autorización y esta versión no reabre esa decisión.

La partición es la de `01-efectos` §4.1 y conviene tenerla presente al leer este documento:

| | Qué decide | Cuándo |
|---|---|---|
| **este documento** | si la función **puede existir** con los efectos que declara | al compilar · L0 |
| **Cedar** | si **este** principal puede invocarla **ahora** | al invocar · L3 |

Confundirlas —querer resolver el principal al compilar— dejaría el régimen entero fuera de
lo certificable.

---

## 8. Errores

| Código | Condición |
|---|---|
| `OOS7002` | la función no alcanza la integridad que exige su destino, y ningún endoso incondicional cubre la diferencia |
| `OOS7004` | endosante fuera del vocabulario cerrado |
| `OOS7005` | destino de un efecto sin integridad declarada |
| `OOS7006` | efecto sobre una propiedad `derivedFrom` |
| `OOS7008` | efectos sobre más de una fuente física |

`OOS7008` no estaba en el registro de `01-efectos` §5: **salió de escribir este documento**,
al convertir `transaction.scope` de campo en regla. Se añade al registro.

Y los que **no** hacen falta, que es igual de informativo: una función que lee un dato
clasificado en un sandbox sin autorización falla con `OOS4001`/`OOS4002`; una que referencia
una propiedad inexistente, con `OOS2005`. La confidencialidad de una función y sus
referencias no necesitaron una sola regla nueva.

---

## 9. Aplazado

- **`emits`** — emitir un evento. No es un hueco del modelo: un tema *es* un conducto, y la
  regla de flujo se le aplicaría sin cambios. Lo que falta es todo lo demás —esquema del
  evento, conjunto de suscriptores, entrega—, y meterlo aquí rompería el alcance que
  `01-efectos` §6 fija: **una función es una operación gobernada, no un proceso de negocio.**
- **`tests`** — va con `Test`, que es L2 y por tanto no certificable por una suite de
  ficheros.
- **Compensaciones y sagas.** Ver §5.2. La ausencia es la posición.
- **La obligación.** Un deber —*«si ocurre esto, tiene que ocurrir aquello»*— es una
  referencia a una función, y por tanto **ya es decible desde que este documento existe**.
  Lo que falta es el operador temporal —*debe llegar a ocurrir*— y el objetivo sobre el que
  se enuncia. Va con v1alpha3 ([`00-scope`](00-scope.md) §7.2).
