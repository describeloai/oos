# 02 · Entity

**Estado:** normativo. Parte de OOS v1alpha1.
**Gramática propia.** No es un perfil: ver §1.2.

---

## 1. Naturaleza

### 1.1 · El principio

> **Una propiedad declara exactamente lo que alguien necesita saber para usarla con
> seguridad, y nada sobre dónde vive.**

De ahí sale todo lo que sigue, y también todo lo que se excluye. El tipo, la etiqueta, la
procedencia y la temporalidad dicen *cómo usar esto sin equivocarse*. La columna física, la
expresión SQL y la tabla de origen dicen *dónde está*, y pertenecen al binding.

Es el mismo corte que sostiene la tesis entera: **la semántica es estable, la
infraestructura es sustituible.** Una entidad que supiera de columnas dejaría de serlo en
cuanto la empresa migrase de PostgreSQL a Databricks.

### 1.2 · Por qué no es un perfil

`Package` y `Binding` son perfiles de ODCS. `Entity` no perfila nada, y la razón es
comprobable con un test:

> **¿Puede este documento expresarse como documento válido del anfitrión sin inventar
> valores?**

Contra Apache Ossie, la respuesta es **no**: su `Dataset` exige `source` y cada `Field`
exige `expression`. Ninguno de los dos está en una entidad — **están en el binding**. Una
`Entity` sola no puede ser un modelo semántico Ossie válido, y conformar inventando campos
o relajando los obligatorios del anfitrión no es perfilar: es fingir.

La causa de fondo es que Ossie es una **capa semántica de BI** —su centro de gravedad son
las métricas sobre un almacén, por eso cada campo es una expresión SQL en siete dialectos—
mientras que `Entity` es un **modelo de dominio**. Un perfil funciona cuando el anfitrión
es un superconjunto con el mismo centro de gravedad; aquí está en otro sitio.

> **`Entity` no perfila Ossie. `Entity` + `Binding` compilan a Ossie** (§9).

Ossie se une así a Cedar, SHACL y OWL: **objetivos de emisión del bundle, no padres
estructurales de un documento.**

### 1.3 · Las seis partes

Cada una existe porque una pieza concreta de la maquinaria la necesita. No hay una séptima.

| Parte | Qué declara | Quién la consume |
|---|---|---|
| **Identidad** | cómo se referencia una instancia | índice de topología · recurso en Cedar · solicitud de acceso de un interesado |
| **Significado** | qué es, para un humano y para un agente | superficie de contexto · revisión en PR |
| **Sensibilidad** | etiquetas de retículo | análisis de flujo · políticas |
| **Procedencia** | de qué propiedades deriva cada una | propagación de etiquetas · linaje |
| **Conexión** | relaciones con otras entidades | travesía del grafo · ReBAC en Cedar |
| **Historia** | temporalidad del dato y evolución del nombre | auditoría retroactiva · `ore diff` |

### 1.4 · Lo que deliberadamente no contiene

| Fuera | Dónde vive | Por qué |
|---|---|---|
| Columna física, tabla, expresión SQL | `Binding` | §1.1 |
| Reglas de acceso | Cedar | la política decide; la entidad solo declara qué hay |
| Métricas y agregados | `expr`, v1alpha2 | son cómputo, no estructura |
| Restricciones de calidad | `quality` de ODCS, v1alpha2 | ídem |
| Estructuras anidadas | aplanadas en el binding | §4.4 |
| Consultas y vistas | — | una entidad sin identidad estable es una vista, y OOS no las modela en v1alpha1 |

---

## 2. Identidad

Todo `Entity` **DEBE** declarar `nature`:

| `nature` | Qué es | Requisito |
|---|---|---|
| `entity` | identidad estable, estado actual | **DEBE** declarar `primaryKey` |
| `event` | append-only, ordenado en el tiempo, sin identidad estable por registro | **DEBE** declarar `timeKey`; `primaryKey` opcional |

Un tema de Kafka, una tabla de auditoría o un log de clics no tienen clave primaria
estable, y exigírsela los excluiría del modelo. Toda la maquinaria de gobernanza es
idéntica para ambos: **solo cambia el requisito de identidad**, y eso no justifica un tipo
de documento aparte.

`primaryKey` es una **secuencia** de propiedades —el orden importa en claves compuestas— y
`uniqueKeys` **PUEDE** declarar claves alternativas, que son las que hacen posible la
resolución determinista de identidad entre fuentes.

---

## 3. Sistema de tipos

### 3.1 · Escalares

`String` · `Integer` · `Decimal` · `Float` · `Boolean` · `Date` · `Time` · `DateTime` ·
`DateTimeTz` · `Opaque`

Los nombres se alinean deliberadamente con el enum de Apache Ossie **aunque no lo
perfilemos**: no cuesta nada y convierte la emisión (§9) en un mapeo sin renombrados.

### 3.2 · Paramétricos

```yaml
baseSalary: { type: Money<EUR, 2> }
distance:   { type: Quantity<km, 1> }
```

Ni Ossie —cuyo `datatype` es un enum plano— ni ODCS —cuyo `logicalTypeOptions` tiene
`minimum`, `maximum` y `multipleOf` pero **ni `precision` ni `scale`**— pueden expresar
«euros con dos decimales». Es un error silencioso: no falla, solo produce cifras
incorrectas.

Su serialización canónica es **cadena**, no número JSON
([`90-canonical-form`](90-canonical-form.md) §4.1).

> **Trampa de YAML.** Un escalar plano no puede contener una coma **en estilo flow**, así
> que `{ type: Money<EUR, 2> }` se parte por la coma y el tipo llega truncado. En estilo
> block —el normal, y el que emite `ore discover`— no hay problema. Escrito en flow, el
> tipo **DEBE** entrecomillarse: `{ type: "Money<EUR, 2>" }`.
>
> Una implementación **DEBERÍA** reconocer un paramétrico truncado —`Money<EUR` sin cerrar—
> y señalar esta causa, que es la que el usuario no ve.

### 3.3 · Listas y referencias

`list<T>` de escalares, un solo nivel. `ref` a otra entidad (§6).

---

## 4. Propiedades

### 4.1 · Etiquetas

```yaml
metadata:
  labels: { acme.residency: eu_only }      # heredada por todas las propiedades

properties:
  email: { type: String, labels: { gdpr.sensitivity: high } }
```

Una etiqueta declarada en la entidad la heredan todas sus propiedades. Una propiedad
**PUEDE** elevarla y **NO DEBE** rebajarla (`OOS4012`). Semántica completa en
[`04-flow`](04-flow.md).

### 4.2 · `examples` y la trampa que nadie ve

ODCS admite valores de ejemplo por propiedad. Son útiles para un agente **y son datos
reales**: los ejemplos de una columna de salarios son salarios.

> Una propiedad con etiqueta por encima de `⊥` **NO DEBE** declarar `examples` salvo que
> estén marcados como sintéticos (`OOS4014`).

Es una demostración pequeña de que el sistema funciona: nadie piensa en esto, y el análisis
de flujo lo atrapa porque `examples` es texto que alcanza la superficie de contexto como
cualquier otra cosa.

### 4.3 · `aiContext`

```yaml
aiContext:
  synonyms: [facturación, top line, ingresos netos]
  guidance: "No incluye impuestos indirectos ni devoluciones posteriores al cierre."
  examples: ["¿cuánto facturamos en Q3?"]
```

Existe porque el problema es real: un agente al que preguntan *"¿cuánto facturamos?"*
necesita saber que eso es `netRevenue`. Ossie lo resuelve con un `ai_context` de forma
libre; aquí se adopta la idea con tres condiciones:

1. **Estructurado**, no texto libre. Lo libre no se valida ni se difunde bien.
2. **Etiquetable.** Un sinónimo puede ser confidencial —*«el score de riesgo interno que no
   divulgamos»* es información sensible— y fluye por el conducto `contextSurface` como
   cualquier otra cosa.
3. **Descriptivo, nunca directivo.** Un motor conforme **NO DEBE** tratar su contenido como
   instrucciones. Es la diferencia entre documentar un campo y abrir una superficie de
   inyección dentro de un artefacto gobernado.

### 4.4 · Sin anidamiento

Un documento con estructura —`jsonb`, un objeto de Mongo, un registro Avro— **DEBE**
aplanarse en el binding: `address.city` se mapea a la propiedad `addressCity`.

Así cada hoja recibe su propia etiqueta y el análisis de flujo no atraviesa estructuras. El
binding conserva la **ruta física completa**, de modo que la emisión pueda reconstruir el
anidamiento original (§9.3).

Coste declarado: los documentos de forma profunda o variable serán incómodos. Es un límite
conocido de v1alpha1.

---

## 5. Procedencia

```yaml
totalCompensation:
  type: Money<EUR, 2>
  derivedFrom: [baseSalary, bonus]
  expression: "baseSalary + bonus"     # documental, no se interpreta
```

**En v1alpha1, `derivedFrom` es una declaración de procedencia, no una computación.**

El compilador la usa para propagar etiquetas —`join(critical, critical) = critical`— y para
computar el linaje. **No calcula el valor**: una propiedad derivada **DEBE** tener binding
igual que cualquier otra, porque el cálculo ocurre aguas arriba o en el `expr` que añade
v1alpha2.

Decirlo así evita la tentación de interpretar `expression`, que exigiría un motor de
consultas dentro del compilador y rompería su pureza.

Y es la razón por la que este campo es obligatorio y no se infiere: **ODCS tiene
`transformSourceObjects`, pero su granularidad es de tablas, no de columnas.** Procedencia a
nivel de tabla es insuficiente para propagar a nivel de propiedad, y un análisis de
contaminación sólido no puede depender de parsear cadenas de expresión.

Una propiedad derivada **NO DEBE** declarar etiqueta: se computa (`OOS4008`).

---

## 6. Conexión

```yaml
spec:
  properties:
    managerId: { type: String }          # el DATO

  relations:                              # la ARISTA
    manager:
      target: hr.Employee
      cardinality: many_to_one
      via: managerId
      required: false
```

Cinco decisiones:

- **Las relaciones viven en su propio bloque, no dentro de `properties`.** `managerId` es un
  dato y `manager` es una arista: son cosas distintas y mezclarlas obliga además a una unión
  discriminada en el esquema, que produce mensajes de error peores.
- **Las relaciones unen propiedades, nunca columnas.** El binding traduce a físico. Es el
  principio §1.1 aplicado al grafo.
- **Cardinalidad explícita**, con **dos** valores: `one_to_one` y `many_to_one`. Ossie solo
  expresa many-to-one implícito por la semántica de `from`/`to`; aquí es un campo, porque
  `ore diff` necesita detectar que endurecerla es un cambio rompedor (`OOS5003`).
- **`one_to_many` no existe, y su ausencia es deliberada.** La clave de un uno-a-muchos vive
  en el otro lado, así que no hay `via` local con el que expresarla — y además es
  **derivable del inverso**: si `Order.customer` es `many_to_one`, `Customer` tiene un
  uno-a-muchos hacia `Order` sin que nadie lo escriba. Declararlo violaría P2.
- **Se declara en el lado que sostiene la clave.** Es el lado que la conoce, y el único que
  puede.
- **`one_to_one` exige que `via` esté en `primaryKey` o en `uniqueKeys`** (`OOS3005`): de lo
  contrario la cardinalidad afirma algo que las claves declaradas no sostienen.
- **Many-to-many se modela como entidad puente** en v1alpha1. Es honesto: una tabla puente
  casi siempre acaba teniendo atributos propios, y evita introducir un tipo de documento.

---

## 7. Historia del dato: temporalidad

```yaml
temporal:
  validTime:       { from: validFrom, to: validTo }
  transactionTime: recordedAt

properties:
  baseSalary: { type: Money<EUR,2>, temporal: true }
```

Dos ejes que **DEBEN** distinguirse: `validTime` es cuándo fue cierto **en el mundo**,
`transactionTime` cuándo lo supo **el sistema de origen**.

`validTime` es obligatorio si se declara `temporal` (`OOS3003`). `transactionTime` es
**opcional**: la pregunta *«¿qué sabía el agente el martes?»* la responden el commit del
bundle y la marca de agua del índice, no este eje. Exigir bitemporalidad completa encarecería
la adopción sin cubrir ninguna garantía que no esté cubierta ya.

Sin esto, un salario es un número en lugar de una función del tiempo, y la pregunta que
hace un auditor —*«¿qué era cierto en tal fecha, y desde cuándo lo sabíais?»*— no tiene
respuesta. El `dimension.is_time` de Ossie marca que un campo *es* una dimensión temporal;
no es bitemporalidad.

Es también el tercer eje temporal del sistema, junto al commit del bundle y la marca de agua
del índice. Los tres responden a preguntas distintas y ninguno sustituye a los otros.

---

## 8. Historia del nombre: evolución

```yaml
moved:
  - { from: salary, to: baseSalary, since: 0.3.0 }

reserved:
  - name: comp
    reason: "antes de 0.3.0 significaba compensación total"
```

- **`moved`** permite que los consumidores migren solos durante la ventana de deprecación
  en lugar de romperse. Es el bloque `moved` de Terraform.
- **`reserved`** impide que un nombre retirado se reutilice con otro significado. Es el
  campo reservado de Protobuf, y previene el fallo más silencioso y más caro de una
  ontología viva: **una consulta antigua que devuelve una cifra correcta para la pregunta
  equivocada.** Usarlo es error (`OOS2006`).

Es también la respuesta de OOS al problema que ODCS resuelve con un `id` estable. Enfoque
distinto con sus contrapartidas: `moved` dice además en qué se convirtió cada nombre y por
qué, pero exige que el consumidor lo lea.

---

## 9. Emisión a Apache Ossie

Ossie no es anfitrión de este documento, pero **sí es objetivo de emisión del bundle**, y
eso importa estratégicamente: todo su ecosistema —Snowflake, dbt, Cube, Sigma, Hex,
ThoughtSpot— puede consumir una ontología OOS sin saber que OOS existe.

### 9.1 · La emisión requiere el binding

Un bundle **DEBE** poder emitir un modelo semántico Ossie v1.0 válido combinando `Entity` y
`Binding`:

| Ossie | De dónde sale |
|---|---|
| `Dataset.name` | nombre cualificado de la entidad |
| `Dataset.source` | **del binding** |
| `Dataset.primary_key` · `unique_keys` | de la entidad |
| `Field.name` · `datatype` | de la entidad |
| `Field.expression.dialects` | **del binding**, según el dialecto del datasource |
| `Relationship.from_columns` / `to_columns` | de la relación, traducida a físico por el binding |
| `ai_context` | de `aiContext`, serializado |

Emitir una entidad **sin** binding **DEBE** fallar: produciría un documento Ossie inválido.

### 9.2 · Extensiones

Las partes que Ossie no modela —etiquetas, temporalidad, tipos paramétricos, `derivedFrom`,
`moved`, `reserved`— se emiten mediante su mecanismo de **Custom Extensions**
(`{vendor_name, data}`, con `data` como cadena JSON).

Un consumidor Ossie que no entienda OOS obtiene un modelo semántico correcto y utilizable,
sin las garantías de gobernanza. **Degradación limpia, no ruptura.**

### 9.3 · Importación

Un modelo Ossie **PUEDE** importarse: los datasets se convierten en entidades en `DRAFT`, el
`source` en un `Binding`, y las expresiones de campo en mapeos físicos.

Sin etiquetas de origen, las propiedades quedan sin etiquetar y el paquete **NO** compila
hasta que se decidan — denegación por defecto (P4). Si falta `primary_key`, **NO DEBE**
inventarse: se marca como decisión pendiente para `ore review`.

---

## 10. Errores

| Código | Condición |
|---|---|
| `OOS2005` | `ref` a entidad o propiedad inexistente |
| `OOS2006` | uso de un nombre declarado en `reserved` |
| `OOS2010` | `nature: entity` sin `primaryKey`, o `nature: event` sin `timeKey` |
| `OOS3001` | tipo fuera del conjunto |
| `OOS3002` | `Money` sin divisa o sin precisión |
| `OOS3003` | temporalidad con un solo eje declarado |
| `OOS3004` | incompatibilidad de unidades en una derivación |
| `OOS3005` | cardinalidad incoherente con las claves del binding |
| `OOS4008` | propiedad derivada que declara etiqueta en lugar de computarla |
| `OOS4012` | propiedad que rebaja la etiqueta heredada de su entidad |
| `OOS4014` | `examples` no sintéticos en propiedad etiquetada por encima de `⊥` |
