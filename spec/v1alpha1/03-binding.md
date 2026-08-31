# 03 · Binding — perfil de ODCS

**Estado:** normativo. Parte de OOS v1alpha1.
**Anfitrión:** Open Data Contract Standard v3.1 — Infrastructures & Servers, y los tipos
físicos a nivel de propiedad.

---

## 1. Naturaleza

`Binding` une el **plano de significado** con el **plano físico**: dice dónde vive
realmente una entidad y —esto es lo propio de OOS— **qué se copia de ella, a dónde y bajo
qué restricción.**

Es también el punto donde el sistema de flujo toca el mundo real. Un binding no es una
descripción pasiva: **instancia un conducto**, y por eso es donde la mayoría de las
violaciones `OOS4xxx` se detectan.

---

## 2. Restricción

| Sección ODCS | En el perfil |
|---|---|
| Infrastructures & Servers | **obligatoria** → `datasourceRef` |
| `physicalType` / `physicalName` de propiedad | **obligatoria** → el mapeo |
| Data Quality | **excluida** → `quality` de ODCS `type: sql`, readmitida en v1alpha2 |

### 2.1 · Restricciones adicionales

- Un `Binding` **DEBE** referenciar exactamente **una** entidad destino y **un** datasource.
  Una entidad **PUEDE** tener varios bindings; cada uno cubre un subconjunto de sus
  propiedades.
- Y al revés también: **un objeto físico PUEDE sostener varias entidades**, que es como
  funciona el diseño de tabla única. Cuando eso ocurre, cada binding **DEBE** declarar un
  `selector` y los selectores **DEBEN** ser disjuntos (`OOS2014`) — §3.5.
- El mapeo **DEBE** cubrir **todo lo que necesita una columna física**: la `primaryKey` de
  la entidad destino, las propiedades `via` de sus relaciones y lo que `payload` replica
  (`OOS2011`). Sin clave no hay resolución de instancia, ni índice de topología, ni
  identificación de recurso para una política; sin la columna de un enlace, la relación se
  declara y no se puede recorrer; y **una réplica sin columna no tiene de dónde copiar**.
- El `datasourceRef` **DEBE** estar declarado en el manifiesto raíz (`OOS2004`).
- El secreto de conexión **NO DEBE** aparecer nunca. El manifiesto declara únicamente el
  nombre de la variable de entorno de la que se lee. Es lo que hace publicable a un
  repositorio ontológico.

---

## 3. Extensiones

### 3.1 · `materialization` — dos ejes, no tres modos

```yaml
materialization:
  topology:                          # las ARISTAS
    refresh: { every: 15m, strategy: table_version }
  payload:                           # la CARGA ÚTIL
    properties: [legalName, segment]
    refresh: { every: 1h, strategy: cdc }
    watermark: updated_at
    freshnessSLA: 2h
```

Omitir los dos es no copiar nada, que es el valor por defecto (P4). No hay un `passthrough`
que escribir: **la ausencia es el valor**, y por eso este campo no necesita que la forma
canónica repare una ambigüedad que ya no existe.

| Eje | Qué se copia | ¿Hay que decir qué? | Qué acelera |
|---|---|---|---|
| `topology` | **claves de join y aristas** | no: es derivable | la **travesía** |
| `payload` | las propiedades declaradas | **sí, obligatorio** | la **búsqueda** |

**Justificación (P7).** La sección Servers de ODCS declara **dónde vive** el dato. Ningún
estándar declara **qué se copia, a dónde y bajo qué restricción**, ni convierte una violación
de esa restricción en un error de compilación. Y no es casualidad que no lo hagan: ODCS es
deliberadamente agnóstico de plataforma —esa es su virtud— así que la materialización queda
fuera de su alcance por diseño, no por olvido.

#### 3.1.1 · Por qué dos ejes y no un modo

Fueron un enum de tres valores —`passthrough | index | cache`— y era un error de modelado.
**`index` y `cache` no son dos valores de un eje: copian cosas distintas, cuestan cosas
distintas y aceleran cosas distintas.** El enum prohibía la combinación obvia: un objeto lento
cuyas **aristas** quieres locales *y* cuyos **valores** quieres cerca no se podía declarar, y
no había ninguna razón para impedirlo.

La asimetría de la tercera columna sí es deliberada y se conserva. En `topology` lo
materializado se **deriva** —la clave primaria y las propiedades `via` de las relaciones—, así
que declararlo violaría P2. `payload` **es una copia de datos**, y quien la declara tiene que
decir exactamente de qué.

Y una consecuencia que conviene ver: **`topology` es derivable y aun así es dato.** Una clave
primaria es un valor, y [`00-overview`](00-overview.md) recuerda que saber que dos instancias
están enlazadas puede ser el hecho sensible. Que no haya que declarar *qué* se copia no
significa que copiarlo sea gratis.

#### 3.1.2 · Cada eje instancia su conducto

`topology` usa `materialization.topology` y `payload` usa `materialization.payload`, cada uno
con su autorización en `ConduitPolicy`. La comprobación es la regla de flujo de
[`04-flow`](04-flow.md) §2, sin excepciones:

```
error[OOS4002]: etiqueta por encima de la autorización del conducto
  hr.Employee.nationalId  ──binding──▶  materialization.topology
  origen  : gdpr.sensitivity = critical
  conducto: gdpr.sensitivity = medium
```

Que sean **dos** conductos y no uno es lo que permite la postura habitual: *«las aristas
pueden salir a disco, los valores no»*. Con un solo conducto había que elegir la más
restrictiva de las dos y renunciar al índice.

#### 3.1.3 · Una caché no es otra fuente

> **Una caché es la misma fuente, más cerca.**

Por eso `payload` cuelga **del** binding y no es un binding nuevo: un binding es una
**afirmación de modelado** —*esta entidad vive aquí*— y una caché es una **decisión de
enrutamiento**. Dos bindings pueden discrepar sobre el valor de una propiedad, y eso es
legítimo: cubren subconjuntos distintos, o fuentes distintas de la misma entidad.

**Normativo.** Una caché **NO DEBE** poder discrepar de su origen. Si puede, no es una caché:
es otra fuente, y entonces es un binding con su `datasourceRef` y su `selector`. La
transparencia no es una cualidad deseable de la implementación — **es lo que distingue las dos
figuras**, y confundirlas hace que la respuesta dependa de por dónde se enrutó.

#### 3.1.4 · Por qué es útil, y la respuesta buena no es «latencia»

Conviene decirlo porque se malinterpreta en las dos direcciones. La respuesta obvia —*el
origen es lento*— es **la más débil aquí**: la fase de carga útil de
[`05-ejecutor`](05-ejecutor.md) §3 es una búsqueda por clave, y eso es rápido en casi
cualquier fuente. Contra un PostgreSQL en la misma red, cachear **solo añade obsolescencia**.

La respuesta buena sale de la ley del ejecutor:

> **Una caché no acelera una consulta: habilita consultas que estaban prohibidas.**

El motor **no compensa** (§2 de `05-ejecutor`). Contra un objeto que no declara
`predicatePushdown`, una consulta con filtro **se rechaza**. Contra su caché se empuja sin
problema, porque las capacidades de lo materializado son las del formato en que se
materializa. Bajo la ley, eso es la diferencia entre *rechazado* y *respondido*.

De donde sale el criterio para decidir si merece la pena, y **no es una propiedad de la
ontología sino de la fuente**:

| Fuente | Búsqueda por clave | ¿Gana algo una caché? |
|---|---|---|
| base de datos en la misma red | ~1 ms | **no** — solo obsolescencia |
| almacén analítico | ~1 s y coste por consulta | sí |
| API de SaaS con cuota | cientos de ms, y un límite diario | sí, y además desbloquea predicados |
| ficheros en un almacén de objetos | escaneo completo | sí: es la diferencia entre servible y no |

Y una consecuencia que hay que ver venir: **si la caché habilita respuestas, quitarla las
retira.** Por eso cambiar los ejes de materialización es `OOS5020` en el eje `INDEX` de
[`91-versioning`](91-versioning.md) y no un cambio menor.

#### 3.1.5 · Una copia sin cota declarada

**Normativo.** `payload` **DEBE** declarar `freshnessSLA`; `topology` **PUEDE** omitirlo.

La asimetría es la de siempre: `topology` es derivable, y `payload` **pone valores gobernados
en reposo en un segundo sitio**. Quien copia datos declara cuánto tolera que envejezcan,
porque una copia sin cota es una copia que nadie va a notar ponerse mala. Y tiene una
consecuencia de cumplimiento que conviene escribir: **un borrado en el origen tarda hasta
`freshnessSLA` en propagarse**, así que ese número es lo que acota la respuesta a una
solicitud de supresión. Sin él no hay nada que responder.

### 3.2 · `freshnessSLA`

Concepto tomado del SLA de ODCS y aplicado a la materialización. Se declara **por eje**: la
topología y la carga útil no tienen por qué envejecer al mismo ritmo, y de hecho casi nunca lo
hacen — una arista nueva importa antes que un nombre corregido.

Superado el umbral sin refresco, una implementación **DEBE** declarar el estado degradado
al consumidor. **NO DEBE** servir datos obsoletos como si fueran frescos.

*Por qué es normativo y no una recomendación:* para un agente, saber que el contexto está
degradado es la diferencia entre abstenerse y alucinar. Un motor que sirve datos viejos en
silencio convierte una garantía en una trampa.

### 3.3 · `capabilities` — qué sabe hacer el origen

```yaml
capabilities:
  predicatePushdown: [eq, in, range]     # nada de LIKE contra este origen
  joinPushdown: false
  aggregatePushdown: [count, sum]
  fullScan: expensive                    # cheap | expensive | forbidden
  requiredFilters: [accountId]           # esta API no admite consulta sin filtro
  maxRowsPerRequest: 2000
```

**Justificación (P7).** Ni Ossie ni ODCS describen qué puede ejecutar un origen. Y sin eso
no hay federación posible: el planificador generaría planes que la fuente no sabe
ejecutar, y `passthrough` sería inutilizable contra cualquier cosa que no sea SQL.

Una tabla de PostgreSQL admite predicados arbitrarios, joins y agregaciones. Un objeto de
Salesforce admite filtrado por campos indexados y poco más. Un CSV en S3 exige escaneo
completo. **Son tres contratos de ejecución distintos y el motor tiene que conocerlos
antes de planificar.**

Requisito derivado del invariante III: las capacidades **DEBEN** declararse, no sondearse.
Descubrirlas en tiempo de ejecución rompería la pureza del compilador y haría no
determinista la planificación.

En la práctica **casi nadie las escribe**: vienen del perfil de conector (§3.3). Un
binding **PUEDE** sobrescribirlas para reflejar una restricción local —una réplica de solo
lectura, una cuota de API— y lo que sobrescriba **DEBE** ser explícito.

### 3.4 · `profile` — perfil de conector

```yaml
profile: oos.dev/connectors/workday
```

Se declara **solo el nombre del paquete**. La versión se resuelve desde `dependencies` y
queda fijada en `ontology.lock`; declararla también aquí sería duplicarla e invitar a la
deriva.

**Justificación (P7).** ODCS no tiene noción de plantilla de binding reutilizable. Los
objetos estándar de un sistema conocido —Workday, Salesforce, SAP— son idénticos en todas
las organizaciones que lo usan: mapearlos una vez y consumirlos como dependencia elimina
la mayor parte del trabajo manual de vinculación, y convierte el descubrimiento de
*inferencia heurística* en **reconocimiento de un sistema conocido**.

Un `profile` aporta mapeos y capacidades por defecto. El binding **PUEDE** sobrescribir
cualquiera de ellos; lo que sobrescriba **DEBE** ser explícito en el documento.

#### Perfil no es driver

Bajo la palabra *conector* se esconden dos cosas que **DEBEN** mantenerse separadas:

| | Qué es | Dónde vive | ¿Portable? |
|---|---|---|---|
| **Driver** | código que habla el protocolo: SOQL, JDBC, la API REST de Workday | dentro de un motor | **no** — es detalle de implementación |
| **Perfil** | declaraciones sobre la forma y las capacidades de ese sistema | un **paquete OOS**, datos inertes | **sí** — versionado y firmado |

Un perfil **NO DEBE** contener código ejecutable. Es un documento OOS como cualquier otro.

Esta separación es lo que permite que exista una segunda implementación: **otro motor
puede tener drivers completamente distintos y consumir exactamente los mismos perfiles.**
Si el perfil llevara código, el formato quedaría atado al motor que lo ejecuta y OOS
dejaría de ser un estándar.

#### Quién los escribe, y por qué no son desechables

Tres orígenes, por orden de probabilidad real:

1. **La comunidad**, con `ore discover` como herramienta de producción: apuntar el
   descubrimiento a una instancia, curar el resultado y **retirar lo específico del
   inquilino** deja un perfil publicable. La misma herramienta que los consume los produce.
2. **El fabricante**, que es lo ideal y llegará tarde.
3. **Una organización para su propio uso**, publicado internamente.

Y no son desechables: **un perfil de conector es más duradero que la ontología de la
empresa que lo usa.** El modelo de objetos estándar de Salesforce cambia despacio y cambia
igual para todo el mundo. Es exactamente la clase de artefacto que merece mantenimiento
comunitario, versionado semántico y vida larga.

#### Vocabulario cerrado

Los nombres de `capabilities` (§3.3) los define **esta especificación** y forman conjunto
cerrado. Los **valores** los aporta cada perfil.

Es la misma razón que cierra el vocabulario de desclasificadores
([`04-flow`](04-flow.md) §5): **un conjunto abierto no es analizable.** Si un perfil pudiera
declarar capacidades con nombres arbitrarios, el planificador no podría razonar sobre
ellas y el compilador no podría verificar que un plan es ejecutable.

> Regla recurrente de OOS: **la especificación define la gramática; el ecosistema aporta
> las instancias.** Se aplica a retículos, a desclasificadores, a conductos y a
> capacidades por igual.

---

### 3.5 · `selector` — qué filas del objeto son esta entidad

`source` dice **qué objeto**. `selector` dice **qué filas de ese objeto**, y hace falta
porque un objeto físico puede sostener varias entidades: es lo normal en DynamoDB, donde el
diseño de tabla única mete usuarios, pedidos y eventos en la misma tabla y los distingue por
un prefijo de la clave. Sin esto, dos bindings sobre el mismo objeto **validaban limpio** y
nada decía qué filas eran de quién.

```yaml
spec:
  source: "app_single_table"
  selector:
    tipo: PEDIDO                  # igualdad
    estado: [nuevo, enviado]      # pertenencia
    borradoEn: null               # ausencia
```

La conjunción es implícita. Las claves son **columnas físicas**, opacas como `source`, y no
propiedades: el discriminante casi nunca es un dato de negocio —`_type`, un prefijo de la
clave— y exigir que fuera una propiedad metería un artefacto del almacén dentro de la
entidad, que es justo lo que [`02-entity`](02-entity.md) §1.1 prohíbe. El selector vive aquí
**porque** es plano físico.

#### 3.5.1 · Por qué la gramática es cerrada, y no es por elegancia

La respuesta fácil era admitir SQL. `source` ya es una cadena opaca, así que un `where`
opaco parecería del mismo tipo. No lo es, y la diferencia es toda la tesis del producto:

> **Un predicado no filtra: lee.** Qué filas aparecen es observable, así que un predicado
> sobre una columna clasificada es un canal lateral — de la presencia de una fila se deduce
> un hecho sobre esa columna. `WHERE salario > 100000` no emite el salario y lo revela.

Un binding **instancia un conducto** (§1). Si el compilador no puede saber qué lee ese
conducto, `G2` —*si compila, ningún dato clasificado alcanza un conducto no autorizado*—
deja de valer para ese binding, y una garantía con un agujero declarado no es una garantía.
Un predicado opaco es exactamente ese agujero.

De ahí sale la restricción, que no es de sintaxis sino de **qué puede afirmar**:

> El selector hace **selección de pertenencia**, no filtrado. Dice qué filas *son* esta
> entidad. Es una **partición**, no un `WHERE`.

La igualdad, la pertenencia y la ausencia expresan exactamente una partición: parten el
objeto en clases y cada fila cae en una. Un rango o una comparación entre columnas no
particionan — ordenan—, y ahí es donde empieza la fuga. Por eso no están, y su ausencia es
deliberada: un binding por franja temporal se declara hoy con dos objetos, no con un rango.

Y la gramática cerrada **compra algo que el SQL haría imposible**: la disyunción de dos
selectores es decidible. Se puede demostrar que dos bindings del mismo objeto no reclaman la
misma fila. Con un `where` opaco eso no se puede ni plantear.

#### 3.5.2 · Qué NO fuga, y por qué

Con la gramática cerrada, lo único que el selector revela es **pertenencia**, y la
pertenencia es la afirmación que el binding ya hace en voz alta: quien lee `Pedido` sabe que
todas sus filas son pedidos. No escapa nada nuevo. Esa es la razón de que la restricción sea
estructural y no cosmética — quítala y el argumento se cae.

---

## 4. Propagación de etiquetas desde la fuente

Un binding no solo lee etiquetas: **las introduce.**

Una propiedad enlazada a un datasource **DEBE** heredar las etiquetas declaradas en ese
datasource, combinadas con `join` sobre las que ya tuviera:

```yaml
# ontology.config.yaml
datasources:
  - name: hr_workday
    type: workday
    connectionEnv: ACME_WORKDAY_URL
    labels:
      acme.residency:   eu_only
      gdpr.sensitivity: high      # suelo: todo lo que sale de aquí es al menos `high`
```

Todo lo enlazado a `hr_workday` queda etiquetado sin que nadie lo escriba en la entidad.
**La ubicación física es un hecho del mundo, no una decisión de modelado**, y por tanto se
computa (P2).

El campo es un mapa de etiquetas general, no solo residencia: permite declarar un **suelo
de sensibilidad por fuente**, que ahorra etiquetar propiedad por propiedad todo lo que sale
de un sistema entero.

---

## 5. Traducción

### 5.1 · Emisión — OOS → ODCS

Un `Binding` **DEBE** poder emitirse como sección Servers de ODCS más los `physicalName`
de las propiedades. `materialization`, `freshnessSLA` y `profile` se emiten bajo
`customProperties` con prefijo `x-oos-`.

### 5.2 · Importación — ODCS → OOS

Todo contrato ODCS con sección Servers **DEBE** poder importarse:

- Cada servidor produce un `Binding` en `DRAFT`.
- Sin `x-oos-materialization`, el modo es `passthrough` — denegación por defecto.
- Si el mapeo no cubre la clave primaria, se marca como decisión pendiente. **NO DEBE**
  inferirse una clave.

### 5.3 · Fidelidad

La ida y vuelta **DEBE** ser sin pérdida en ambas direcciones para las construcciones del
perfil.

---

## 6. Errores

| Código | Condición |
|---|---|
| `OOS2004` | `datasourceRef` no declarado en el manifiesto raíz |
| `OOS2005` | el mapeo referencia una propiedad inexistente en la entidad destino |
| `OOS2014` | dos bindings del mismo objeto pueden reclamar la misma fila |
| `OOS2015` | `requiredFilters` nombra una propiedad que el mapeo no cubre ([05 §5.3](05-ejecutor.md)) |
| `OOS2011` | el mapeo no cubre lo que necesita columna: la `primaryKey`, las propiedades `via` o lo que `payload` replica |
| `OOS2012` | secreto de conexión presente en el documento |
| `OOS4002` | etiqueta por encima de la autorización del conducto instanciado |
| `OOS4011` | modo de materialización cuyo conducto no tiene autorización declarada |
