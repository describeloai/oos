# El régimen de efectos

**Estado:** borrador. `spec/v1alpha1/` sigue mandando.

El núcleo de v1alpha2. Todo lo demás de esta versión —`Function`, `Resolution`, `Rule`—
se deriva de lo que aquí se decide.

---

## 1. La simetría

v1alpha1 no gobierna «datos». Gobierna **observación**, y lo hace con cuatro piezas que se
sostienen entre sí. v1alpha2 gobierna **efecto** con las cuatro duales, y la tabla es el
documento entero:

| | v1alpha1 · ¿qué puedo **saber**? | v1alpha2 · ¿qué puedo **causar**? |
|---|---|---|
| **retículo** | confidencialidad — *cuánto daño si se filtra* | integridad — *cuánto daño si es falso* |
| **regla** | `L(dato) ⊑ C(canal)` | `I(actor) ⊒ I(destino)` |
| **canal** | **conducto** — por dónde sale un dato | **función** — por dónde entra un efecto |
| **escape** | **desclasificador** — pérdida autorizada | **endosante** — confianza ganada |
| **combinador** | `join` = máximo | `meet` = mínimo |
| **prueba** | no compila | no compila |

Cinco filas y una consecuencia: **no hace falta un modelo de gobernanza nuevo.** Hace falta
leer el existente en la otra dirección. El documento `Lattice` sirve para ambos ejes sin un
solo campo nuevo; lo que cambia es hacia dónde apunta la comparación.

> Un conducto es por dónde **sale** un dato. Una función es por dónde **entra** un efecto.

La última fila es la que hay que defender: si causar no se comprueba al compilar, v1alpha2
no es la continuación de v1alpha1 — es otra cosa pegada al lado.

---

## 2. La autoridad deja de ser ambiental

Aquí está el producto, y conviene decirlo sin metáforas.

Hoy, para que un agente apruebe un pedido, hay dos caminos y los dos son malos. **Darle
credenciales** —y entonces puede hacer todo lo que la cuenta de servicio puede hacer, que
es siempre más de lo que necesita—. O **escribirle un endpoint a medida**, con las
comprobaciones a mano, que nadie revisa como se revisa una política y que deriva del
modelo en cuanto alguien toca una tabla.

Los dos comparten la misma raíz: **la autoridad es ambiental.** Se hereda del proceso, del
rol, de la conexión. Quien ejecuta obtiene todo lo que el ejecutor tiene, y la única
defensa es que el código se acuerde de comprobar.

El régimen de efectos invierte eso:

> **Un agente no recibe credenciales. Recibe una superficie.**

Una `Function` **es** la autoridad. No la acompaña, no la comprueba: la constituye. Fuera
de las funciones declaradas no hay forma de causar nada, porque el sandbox no tiene red, no
tiene credenciales y no tiene sistema de ficheros. Lo que un actor puede causar es
exactamente la unión de las funciones que puede invocar, y eso es **enumerable, revisable
en un pull request y comprobable al compilar**.

Es el mismo movimiento que hizo v1alpha1 con la lectura, y por eso encajan: uno acota lo
que se sabe, el otro acota lo que se hace, y ninguno depende de que nadie se acuerde de nada.

---

## 3. Las cuatro piezas

### 3.1 · El eje de integridad

Confidencialidad e integridad son **ortogonales**, y confundirlas es el error clásico.

| | Pregunta | Fallo |
|---|---|---|
| confidencialidad | ¿cuánto daño si esto se filtra? | un agente **lee** `Employee.salary` |
| integridad | ¿cuánto daño si esto es falso? | un agente **escribe** `PurchaseOrder.status` |

Un dato puede ser público y crítico a la vez: el estado de un pedido no es secreto, y
escribirlo mal cuesta dinero. Un retículo de confidencialidad no tiene nada que decir al
respecto, y por eso hace falta el otro eje.

Se declara con la maquinaria que ya existe: un `Lattice`, y una etiqueta en `labels:`. Lo
único que se añade al documento es **de qué eje es** —porque de ahí sale el combinador—:

```yaml
kind: Lattice
metadata: { name: assurance, namespace: acme }
spec:
  axis: integrity            # ← lo único nuevo
  levels: [untrusted, inferred, reviewed, attested]
```

### 3.2 · El endosante

Un desclasificador es una **pérdida autorizada**: se pierde precisión para ganar alcance.
`mask` devuelve menos de lo que había, y por eso el dato puede llegar más lejos.

Un endosante es lo contrario: una **confianza ganada**, y ganada tiene que significar
*pagada*. Y aquí aparece la restricción que le da forma al vocabulario entero:

> El precio tiene que ser **verificable al compilar**, sin reloj y sin red.

Eso descarta cualquier endosante que dependa de consultar algo vivo, y deja exactamente los
que **dejan rastro en el repositorio**: una revisión de `CODEOWNERS` registrada en un
commit, una suite de pruebas en verde, una firma verificable, una atestación. Es la misma
disciplina que ya usa `OOS5022`, donde el periodo de aviso se comprueba por lo que está
escrito y no por qué hora es.

El vocabulario será **cerrado**, como el de desclasificadores, y por el mismo motivo: un
endosante que el motor no sabe verificar es una promesa, y una promesa no es una garantía.

Los borradores de `docs/vision/` ya lo habían inventado tres veces con tres nombres —
`requireHumanApproval`, `approvedBy`, `status: STABLE`—. Un concepto con tres nombres
acaba teniendo tres semánticas.

### 3.3 · La función

Es el único punto donde la ontología toca el mundo, y por tanto **el único donde termina la
pureza del compilador**. Todo su diseño consiste en hacer esa frontera estrecha y declarada.

Cuatro decisiones, y las cuatro dicen lo mismo desde ángulos distintos:

**Los efectos se declaran, no se descubren.** Una función dice qué escribe. Es lo que
permite comprobar la regla de integridad **sin ejecutar nada**, igual que la regla de flujo
se comprueba sin leer un dato.

**Las precondiciones son parte del contrato, no validación dentro del código.** La
diferencia es de producto, no de estilo: si la comprobación vive dentro de la función, el
agente tiene que *intentarlo para saber*. Si vive en el contrato, el agente **sabe qué
puede intentar antes de intentarlo**. Eso es la diferencia entre una superficie usable y
un paseo aleatorio.

**La función no escribe.** Recibe entradas y devuelve salidas. **El motor escribe**, en su
nombre, exactamente lo que la función declaró. Si la función pudiera escribir por su
cuenta, `effects` sería documentación; así es el mecanismo.

**El alcance transaccional es una sola fuente.** Escribir atómicamente en PostgreSQL y en
Salesforce a la vez no es algo que este motor pueda prometer, así que **no lo promete**. La
negativa es una característica: un régimen que promete lo que no cumple no gobierna nada.

### 3.4 · El aislamiento

El sandbox es donde «la autoridad no es ambiental» deja de ser una frase. Sin red, sin
sistema de ficheros, sin credenciales, con límite de memoria y de tiempo. Una función que
quisiera exfiltrar no tiene por dónde, y no porque se le prohíba: porque no hay canal.

Y es lo que hace que el modelo componga con v1alpha1 en vez de escaparse por debajo: **todo
lo que la función lee entra por sus argumentos**, y todo argumento viene de una propiedad
etiquetada. La regla de flujo se le aplica sin ninguna extensión — un sandbox es un
conducto más.

---

## 4. La regla de integridad

### 4.1 · Qué es decidible al compilar

La regla dual, escrita entera, es `I(actor) ⊒ I(destino)`. Pero **al compilar no hay
actor**: quién invoca se sabe en ejecución. Si la regla dependiera de eso, no sería L0 y no
habría nada que demostrar en CI.

La salida es la misma que ya funcionó para la confidencialidad. Allí la regla es decidible
porque **ambos lados están declarados**: la etiqueta del dato y la autorización del
conducto. Aquí pasa igual si se cambia el sujeto:

> **`I(función) ⊒ I(destino)`** — una función no puede declarar un efecto sobre una
> propiedad cuya integridad exigida supere la suya, salvo que atraviese un endosante
> autorizado.

Y `I(función)` no es la identidad de nadie: es **el nivel de garantía que la propia función
ha ganado** — sus pruebas, su revisión, su firma, su exigencia de aprobación humana. Todo
declarado, todo en el repositorio, todo verificable sin ejecutar.

Con eso, el régimen se parte en dos capas limpias, exactamente como v1alpha1:

| | Qué comprueba | Cuándo | Con qué |
|---|---|---|---|
| **L0** | los efectos declarados contra la integridad que exigen sus destinos | al compilar | esta regla |
| **L3** | si **este** principal puede invocar **esta** función | al invocar | Cedar |

La primera es la que se puede demostrar clonando el repositorio. La segunda es la que se
siente. Confundirlas —querer comprobar el actor al compilar— es lo que haría todo el
régimen incertificable.

### 4.2 · La propagación es `meet`, no `join`

En confidencialidad, una propiedad derivada toma el **máximo** de sus orígenes: mezclar
algo `critical` con algo público da `critical`, porque la sensibilidad no se diluye.

En integridad es al revés, y es el dual exacto: una propiedad derivada toma el **mínimo**.

> Un cómputo no es más fiable que su entrada menos fiable.

Un `riskScore` calculado a partir de un dato `attested` y otro `inferred` es `inferred`. No
hay forma de que un promedio limpie una entrada sucia, y una implementación que dejara que
lo hiciera estaría lavando procedencia — que es exactamente el fallo silencioso contra el
que existe todo esto.

La consecuencia práctica: **el mismo motor de propagación de `flow` sirve para los dos
ejes**, cambiando el combinador según `axis`. La maquinaria de `derivedFrom` ya recorre el
grafo; aquí lo recorre otra vez con `min`.

---

## 5. El ecosistema

Acotado a propósito. Cada pieza está por **P6** —componer antes que inventar— y cada una
trae escrito qué aporta y por qué no se reimplementa.

| | Qué aporta | Por qué no se inventa |
|---|---|---|
| **Cedar** | quién puede invocar una función | ya adoptado en v1alpha1; el esquema ya se proyecta |
| **CEL** | precondiciones y expresiones: total, terminante, sin efectos | Kubernetes resolvió este problema exacto para sus políticas de admisión. **P3** prohíbe cómputo arbitrario en un documento que gobierna |
| **WASM · componentes** | el aislamiento y la portabilidad del código | estándar, multi-lenguaje, y **sin red por defecto** — la propiedad que necesitamos es la que ya tiene |
| **Atestaciones firmadas** | el rastro que hace verificable un endosante | in-toto y Sigstore ya definen «X fue revisado por Y» de forma comprobable sin consultar nada vivo |
| **Las fuentes** | dónde ocurre el efecto | PostgreSQL, BigQuery, Databricks. Una transacción, una fuente |

Lo que **no** entra en el ecosistema, y conviene que se vea la ausencia: ningún orquestador,
ninguna cola, ningún motor de flujos de trabajo. Una función es una operación gobernada, no
un proceso de negocio. En el momento en que este documento tuviera que hablar de
compensaciones distribuidas, el alcance se habría roto.

---

## 6. Lo que este régimen no promete

Escrito aquí para que no haya que descubrirlo:

- **Atomicidad entre fuentes.** Una transacción, una fuente. §3.3.
- **Que la función haga lo que dice.** Se comprueba que sus efectos *declarados* sean
  legales y que el motor solo ejecute esos. Que el código dentro del sandbox sea correcto
  es responsabilidad de sus pruebas, no de este régimen.
- **Certificación de la ejecución.** Invocar una función es L3, y L2/L3 probablemente no
  sean certificables por una suite de ficheros. Lo que la suite puede crecer es la regla
  de §4.1, y solo eso.
- **Que la integridad de una fuente externa sea la que dice.** Etiquetar una tabla como
  `attested` es una afirmación de quien la etiqueta. El compilador comprueba que las
  etiquetas se respeten, no que sean verdad.
