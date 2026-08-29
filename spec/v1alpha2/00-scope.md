# OOS v1alpha2 — alcance

**Estado:** **alcance cerrado — primera versión.** Los tres documentos están escritos y su
borrador de conformidad va 14/14. Lo que aquí se cierra es el **diseño**, no la ratificación:
`spec/v1alpha1/` sigue siendo la versión normativa.

| | |
|---|---|
| `00-scope` | **este documento** — qué entra en v1alpha2, qué no, y qué queda abierto |
| [`01-efectos`](01-efectos.md) | el núcleo — el régimen de efectos, del que se deriva todo lo demás |
| [`02-function`](02-function.md) | la superficie de efecto — el primer documento que aplica el régimen |
| [`03-resolution`](03-resolution.md) | el efecto sobre la identidad — el más peligroso de los tres |

---

## 1. La tesis

v1alpha1 tiene un vocabulario de gobernanza completo y **habla de una sola cosa**:

| | |
|---|---|
| `Etiqueta` | qué es esto |
| `Conducto` | a dónde puede ir |
| `Desclasificador` | cómo puede bajarse |

Los tres describen **observación**. La regla de flujo —`L ⊑ C`, o un desclasificador
autorizado— dice a dónde puede *llegar* la información. Todo lo que v1alpha1 gobierna es
lo que alguien puede llegar a **saber**.

Los tres documentos de v1alpha2 son, los tres, sobre lo contrario:

| | Efecto sobre |
|---|---|
| `Function` | el **mundo** — escribe en una fuente física |
| `Resolution` | la **identidad** — decide que dos registros son uno |
| `Entity.expr` | el **contenido** — deriva hechos que no están en ninguna tabla (§3.1) |

> **v1alpha1 gobierna lo que se puede saber. v1alpha2 gobierna lo que se puede causar.**

Esa frase no es retórica: es la razón de que los tres vayan juntos en una versión y de que
ninguno se pueda especificar bien por separado.

---

## 2. Lo que hay que añadir son dos cosas, no cuatro

El error caro sería escribir tres documentos con tres modelos de gobernanza. Casi todo lo
que hace falta **ya está en v1alpha1**: lo que falta es un eje —**integridad**, el dual
conocido de la confidencialidad, literatura de control de flujo desde los setenta— y una
decisión de composición para las expresiones.

Las dos se especifican en [`01-efectos.md`](01-efectos.md), que es el núcleo de esta
versión. Aquí solo consta el alcance y su estado:

| | Estado |
|---|---|
| **eje de integridad** — `Lattice` gana `axis`, y de ahí sale el combinador | decidido · `01-efectos` §1, §3.1, §4.2 |
| **endosante** — el dual del desclasificador | nombrado y acotado; el vocabulario sigue sin cerrar · §3.2 |
| **CEL** para expresiones — **P3** prohíbe el cómputo arbitrario en un documento que gobierna | adoptado; la superficie sigue sin decidir · §5 |
| **la regla de integridad**, y qué parte de ella cae en L0 | decidido · §4.1 |

Un hallazgo de alcance que sí pertenece aquí, porque es la razón de que los tres documentos
vayan juntos: **el endosante ya estaba inventado tres veces con tres nombres** en los
borradores de `docs/vision/` — `requireHumanApproval` en `Function`, `approvedBy` en
`Resolution`, y el `status: STABLE` revisado en un PR de `Rule`. Un concepto con tres
nombres acaba teniendo tres semánticas, y esa es exactamente la deriva que una versión
conjunta evita.

---

## 3. Los documentos

### 3.1 · `Rule` — retirado como documento, y por qué solo a medias

**La pregunta P7 tiene respuesta, y la respuesta es que este documento no debe existir.**

`Rule` mezclaba bajo un mismo `type:` dos cosas que no se parecen en nada, y separarlas fue
suficiente para que cada mitad se fuera a un sitio que ya existe.

#### `constraint` es `quality` de ODCS

Y no es SHACL, aunque SHACL fuera el candidato obvio. Tres razones, en orden de peso:

| | |
|---|---|
| **SHACL es RDF** | *«Rules cannot work directly over non-RDF data — they operate exclusively within RDF graphs.»* Nuestros datos viven en PostgreSQL, BigQuery y Databricks. Adoptar SHACL exigiría proyectar a RDF una ontología que no es RDF, para validar datos que tampoco lo son |
| **SHACL-AF no es una Recomendación** | es una **Nota** del W3C de 2017, y SHACL 1.2 sigue en Borrador de Trabajo. **P6** dice adoptar donde exista un estándar adecuado; una Nota no da la estabilidad que justifica arrastrar RDF entero |
| **ODCS ya está adoptado** | `quality` existe en v3.1, **cuelga de la propiedad**, y trae biblioteca de métricas (`nullValues`, `duplicateValues`, `rowCount`…), operadores (`mustBe`, `mustBeBetween`…), y compatibilidad declarada con Soda, Great Expectations y dbt-tests |

La tercera fila es la decisiva: **ya perfilamos ODCS** en `Package` y `Binding`. Elegir SHACL
sería adoptar un segundo estándar, de otra familia, para algo que el primero ya cubre.

Y hay una partición que cae sola de la separación de planos que ya tenemos:

| Tipo de regla | Dónde vive | Por qué |
|---|---|---|
| `library` — `nullValues mustBe 0` | **`Entity`** | es una afirmación sobre el **significado**: esta propiedad no es nula nunca. Sin dialecto |
| `sql` — una comparación entre registros | **`Binding`** | está atada a un dialecto, y el dialecto solo se conoce donde se declara la fuente |

Las dos restricciones del borrador —`salary-within-band` y `no-overlapping-comp-periods`—
son de la segunda clase: comparan entre registros, y en ODCS eso es `type: sql`. Lo que se
hereda con ello es la limitación de ODCS, no una nuestra: **una regla `sql` no es portable
entre fuentes**, y conviene decirlo en vez de fingir que sí.

> **P3 no aplica aquí, y conviene justificarlo.** P3 exige datos inertes en los documentos
> que **gobiernan** — `Policy`, la clasificación, el bloque `materialization`. Una regla de
> calidad no decide accesos: afirma una propiedad de los datos. Por eso puede llevar SQL
> donde una precondición de `Function` no puede.

#### `inference` es `derivedFrom` con el cómo

v1alpha1 ya declara la procedencia de una propiedad derivada, ya computa su etiqueta por
`join`, ya prohíbe declararla (`OOS4008`) y ya prohíbe escribirla (`OOS7006`). Lo único que
una regla de inferencia añade es **la expresión**, y una expresión es un campo, no un
documento.

Así que `Entity.properties.<nombre>` gana `expr` junto a `derivedFrom`, y no hace falta nada
más: las referencias de la expresión son `OOS2005`, sus lecturas están sujetas a la regla de
flujo, y su etiqueta ya se propaga.

#### Lo que esto cierra — y lo que no

**Tercera vez que la respuesta correcta es quitar** — tras los campos constantes de
`Function` y el `confidence` de `Resolution`. Y aquí es un documento entero, que es
exactamente el resultado que **P7** existe para producir:

> Un campo sin esa justificación es un defecto, no una funcionalidad.

Pero `Rule` planteaba **dos** preguntas independientes, y esta respuesta contesta una:

| | Pregunta | Respuesta |
|---|---|---|
| **vocabulario** | ¿cómo se escribe una restricción? | ODCS `quality`, no SHACL — **cerrado aquí** |
| **localidad** | ¿sobre qué se aplica, y quién responde por ella? | **no la contesta este documento** |

La segunda quedó contestada por omisión —*«inline, colgando de la propiedad»*— y esa
respuesta no se sostiene. **Una regla inline enumera**: para cubrir cuatrocientas propiedades
clasificadas hay que escribirla cuatrocientas veces, y una propiedad que se clasifique mañana
queda fuera sin que nadie se entere.

Ya resolvimos ese problema una vez, en el otro lado del sistema. La proyección a esquema
Cedar existe precisamente para que una política diga
`resource in Label::"gdpr.sensitivity:high"` **en lugar de enumerar propiedades**, y por eso
una entidad nueva queda gobernada el día que se etiqueta. Que la autorización apunte por
clasificación y la restricción enumere es una asimetría, y las asimetrías de este proyecto
han resultado ser defectos.

Cerrarla exige una primitiva que hoy no existe —**un predicado de objetivo sobre el
retículo**— que toca el retículo, Cedar y la regla de flujo a la vez. No cabe aquí sin
reescribir la proyección Cedar antes de haber ejecutado nunca una `Function` contra una base
de datos real. **Es el núcleo de v1alpha3** (§7).

v1alpha2 queda en **dos documentos nuevos** —`Function` y `Resolution`—, dos campos añadidos
a documentos que ya existen —`expr` y `quality`—, y la resolución de dependencias.

### 3.2 · `Function`

La superficie de escritura gobernada, y el documento que convierte OOS de catálogo en
sustrato. El borrador es fuerte y ya trae la honestidad de diseño que hay que conservar:

- **`effects` declarados, no descubiertos.** Una función dice qué escribe. Es lo que
  permite comprobar la regla de integridad al compilar, sin ejecutar nada.
- **`transaction.scope: single-datasource`.** El borrador se niega a prometer atomicidad
  entre PostgreSQL y Salesforce. Esa negativa es una característica y se queda.
- **`network: DENY` en el sandbox.** El aislamiento es parte del contrato, no del despliegue.
- **`requireHumanApproval`** — que es un endosante, y se renombró
  ([`01-efectos`](01-efectos.md) §3.2, [`02-function`](02-function.md) §6.1).

Escrito en [`02-function`](02-function.md). Dos cosas que conviene no perder de vista al
leer el borrador original: la regla **no** se enuncia como sale de la intuición —«el actor
que invoca alcanza la integridad que el destino exige»—, porque al compilar no hay actor y
esa formulación deja el régimen fuera de L0; y la integridad de una función **se computa**
de sus endosos, nunca se declara.

### 3.3 · `Resolution`

El efecto sobre la identidad, que es el más peligroso de los tres: **fusionar dos entidades
fusiona sus etiquetas.** Y aquí la maquinaria de v1alpha1 responde sola —`join = max`— así
que la entidad resuelta hereda el máximo de ambas, y eso ya se computa.

El borrador acierta en la distinción que importa:

| Estrategia | Qué lee | Consecuencia |
|---|---|---|
| `deterministic` | solo la clave | encaja en el índice de topología; no toca valores de negocio |
| `probabilistic` | **valores reales, a escala** | es un conducto, y como tal exige autorización declarada |

Esa segunda fila cae directamente de v1alpha1: comparar nombres y direcciones es hacer
fluir datos etiquetados hacia un emparejador. `requires.materialization: cache` del borrador
no es una opción de rendimiento — es la declaración del conducto, y se renombró a `conduit`.

Escrito en [`03-resolution`](03-resolution.md), donde el eje de integridad aporta lo único
que no era gratis: **una coincidencia probable no produce un hecho.** Por bien calibrada que
esté, una estrategia probabilística infiere, y `threshold: "0.99"` sigue sin ser una
observación.

---

## 4. Resolución de dependencias

No es un documento: es **distribución**, y es lo que cierra «autosuficiente».

Hoy `ontology.lock` existe, `dependencies` existe, `OOS2013` comprueba que estén
sincronizados, y **nada puede traer un paquete**. El formato del lock ya apunta a un
registro (`resolved: https://registry.oos.dev/...`) que no está construido. Un mensaje de
error de ORE tuvo que dejar de recomendar `ore install` porque ese comando no existe.

Alcance mínimo: un protocolo de registro, el formato del paquete publicable (`.oob`), y el
resolutor. Sin esto, el paquete de clasificación importable —«GDPR como dependencia»— no
existe, y cada organización redeclara sus propios retículos.

---

## 5. Lo que NO entra

**`Policy` sigue muerto, y conviene decir por qué.** El borrador de acme-global define un
lenguaje de autorización propio: `defaultEffect: DENY`, `rules` con `effect: ALLOW`, `when:`.
Eso es exactamente lo que v1alpha1 decidió no hacer — **las políticas son Cedar**, y esa
decisión no se reabre.

Pero el borrador destapa un hueco real que hay que registrar:

```yaml
graph.reachable(from: subject, to: resource, via: "people.reportsTo", maxDepth: 5)
```

La proyección a esquema Cedar ya convierte una autorreferencia en jerarquía de entidades,
así que `resource in principal` expresa «por debajo de mí en la cadena de mando». Lo que
**no** expresa es `maxDepth: 5`: el operador `in` de Cedar es el cierre transitivo completo
y no admite límite de profundidad.

Es un límite de expresividad de Cedar, no un motivo para volver a un lenguaje propio. Las
salidas posibles —materializar la profundidad como propiedad, o aceptar el cierre completo—
son una decisión abierta.

**`Test` tampoco entra.** Es real y hace falta, pero es una comprobación sobre datos, y por
tanto L2/L3: no es certificable por una suite de ficheros. Va después.

---

## 6. Decisiones abiertas

1. **El vocabulario cerrado de endosantes.** Hoy son dos —`attested` y `humanApproval`— y
   falta escribir cómo se verifica una atestación al compilar, sin reloj y sin red.
2. **La superficie de CEL.** Qué funciones de grafo y temporales se exponen, sabiendo que
   cada una es una lectura sujeta a la regla de flujo. Ahora incluye también las que
   `Entity.expr` necesite (§3.1).
3. **`maxDepth` en Cedar** — materializar la profundidad, o aceptar el cierre transitivo.
   Es una pregunta de la capa de política: se decide con v1alpha3 (§7).

### Cerradas

**`Rule` frente a SHACL** (§3.1). La respuesta fue **retirar el documento**: `constraint` es
`quality` de ODCS, que ya perfilamos, e `inference` es un campo de `Entity`. Cierra el
**vocabulario** y deja abierta la **localidad**, que pasa a v1alpha3 (§7).

**Qué es certificable** ([`01-efectos`](01-efectos.md) §4.1). La regla de integridad es L0
porque se escribe sobre la función y no sobre quien la invoca; la invocación es L3 y es de
Cedar. La suite solo puede crecer con lo primero.

---

## 7. Lo que esto abre — v1alpha3, la capa de gobierno

Escrito en [`spec/v1alpha3/`](../v1alpha3/00-scope.md). Aquí queda solo lo que salió de
**cerrar esta versión**, porque explica por qué la capa de gobierno viene después y no antes.

### 7.1 · Lo que ya teníamos sin saberlo

> **Un desclasificador es una máscara.**

v1alpha1 define el desclasificador como *la única forma legítima de bajar una etiqueta*, y
[`04-flow`](../v1alpha1/04-flow.md) §5 lo llama con todas las letras *«el vocabulario cerrado
de obligaciones»*. Enmascarar —`ssn → últimos 4`— es exactamente eso. **El requisito número
uno de todo comprador regulado ya estaba en el árbol**, sin ningún sitio donde engancharse
salvo una anotación de Cedar que nadie comprueba.

> **Una obligación es una `Function`.**

XACML murió de sus obligaciones: nombraban deberes que ningún runtime sabía ejecutar. En
v1alpha1 una obligación habría sido prosa. Ahora que **los verbos existen**, un deber es una
referencia a uno —con su integridad computada, sus precondiciones y su endoso—. La capa de
política estaba esperando a que existieran los verbos.

### 7.2 · El arco

| | |
|---|---|
| **v1alpha1** | qué se puede **saber** |
| **v1alpha2** | qué se puede **causar** |
| **v1alpha3** | **qué debe sostenerse — y quién responde** |

Y cada versión aporta una regla y solo una: `L ⊑ C`, `I(f) ⊒ I(destino)`, y la cobertura.
