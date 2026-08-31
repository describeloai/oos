# Open Ontology Specification — v1alpha1

**Estado:** normativo. Parte de OOS v1alpha1 — y v1alpha1 es **alpha**: puede romper
compatibilidad en cualquier publicación, sin garantías (§6). Las dos cosas a la vez: es lo
que gobierna, y no promete nada.
**Licencia:** Apache-2.0.

---

## 1. Alcance

Esta especificación define un **paquete ontológico**: una unidad autosuficiente, tipada y
ejecutable que declara, para un dominio de negocio, qué existe, dónde está físicamente,
qué es sensible, quién puede verlo bajo qué condiciones, qué se puede hacer con ello y
quién responde de ello.

### 1.1 · OOS define cuatro cosas, y solo la última son campos

| | Qué define | ¿Existe en otro estándar abierto? |
|---|---|---|
| **1 · Régimen de identidad** | forma canónica, normalización, digest. Qué significa que dos ontologías **sean la misma** | **no** |
| **2 · Modelo de compilación** | de fuente a artefacto: hermético, puro, determinista, con qué garantías y qué se puede probar sobre él | **no** |
| **3 · Contrato de conformidad** | qué es un paquete conforme, qué es un motor conforme, y qué suite lo decide | **no** |
| **4 · Vocabulario de gobernanza** | clasificación con propagación, sumideros, políticas con obligaciones, materialización, autonomía | **no** — ver §7.2 |

Los tres primeros son lo que convierte a OOS en una **especificación** y no en un
esquema. El cuarto es su superficie más visible, pero no es su fundamento.

> **Ossie y ODCS son vocabularios. OOS es un régimen.**
> Un vocabulario dice cómo nombrar las cosas. Un régimen dice qué debe ser cierto, quién
> lo comprueba y qué ocurre cuando no lo es.

Todo el modelo semántico y contractual —entidades, campos, relaciones, métricas, tipos,
servidores, SLA, calidad, etiquetas de clasificación— se **absorbe** de Apache Ossie y
ODCS. Ver §7.

OOS define estructura y semántica, no implementación. La conformidad se demuestra
pasando la suite, no usando una implementación concreta.

### Fuera de alcance

- El lenguaje de consulta.
- El protocolo de servicio (MCP, GraphQL, SDK).
- La estrategia de materialización física y su rendimiento.
- La interfaz de usuario de cualquier herramienta.

---

## 2. Terminología normativa

Las palabras clave **DEBE**, **NO DEBE**, **DEBERÍA**, **NO DEBERÍA** y **PUEDE** en
este documento se interpretan según [RFC 2119](https://www.rfc-editor.org/rfc/rfc2119) y
[RFC 8174](https://www.rfc-editor.org/rfc/rfc8174), y aparecen siempre en negrita.

---

## 3. Conformidad

Un artefacto o programa es **conforme a OOS v1alpha1** si cumple lo siguiente.

### 3.1 Paquete conforme

Un paquete **DEBE**:

1. Contener un documento `kind: Package` válido en su raíz.
2. Declarar `apiVersion: oos.dev/v1alpha1` en todos sus documentos.
3. Validar contra los esquemas JSON publicados en `/schemas/v1alpha1/`.
4. Satisfacer la integridad referencial: toda referencia a un nombre cualificado **DEBE**
   resolverse dentro del paquete o de sus dependencias declaradas.
5. No contener datos de negocio ni secretos.

**Qué documentos componen el paquete.** Un validador recorre la raíz del paquete y toma
todo fichero `.yaml`, `.yml`, `.cedar` y el `ontology.lock`. Un directorio cuyo nombre
empieza por `.` **NO DEBE** recorrerse: no forma parte del paquete. Cubre la caché
derivada (`.ore/`) y la maquinaria del repositorio (`.github/`, `.git/`, `.vscode/`), y es
una regla y no una lista para que la siguiente herramienta que invente un directorio
oculto no exija una versión nueva de esta especificación.

Sin ella, un repositorio no podría guardar junto a su ontología el CI que la valida: el
validador entraría en `.github/workflows/` y le exigiría `apiVersion` a un workflow. Que
un fichero YAML esté dentro de la raíz no lo convierte en un documento OOS.

### 3.2 Implementación conforme: niveles

"Ejecutar una ontología" abarca capacidades muy distintas. La conformidad se declara por
**niveles acumulativos**: una implementación de nivel N **DEBE** satisfacer todos los
niveles inferiores.

| Nivel | Nombre | Qué hace | ¿Necesita acceso a datos? |
|:---:|---|---|:---:|
| **L0** | **Validador** | analiza, normaliza, valida esquema e integridad referencial, **ejecuta la comprobación de flujo `OOS4xxx`**, emite el digest | **no** |
| **L1** | **Servidor de contexto** | sirve el plano de contexto: entidades, relaciones, tipos, políticas, linaje | **no** |
| **L2** | **Ejecutor** | resuelve bindings contra fuentes reales, aplica políticas y obligaciones en lectura, federa consultas | sí |
| **L3** | **Actor** | ejecuta funciones con capacidades y **verifica el acto que un endoso declara** | sí, con escritura |

**L0 es el nivel que hace que OOS sea un estándar.** Es completamente hermético: sin red,
sin credenciales, sin tocar un dato. Es implementable en cualquier lenguaje en un fin de
semana, como una acción de CI, un *linter* de editor o un `pre-commit`.

De ahí se sigue la propiedad más fuerte de toda la especificación:

> **La garantía de gobernanza es verificable en L0.**
> Un auditor o un regulador puede comprobar que un paquete no filtra información
> clasificada **ejecutando un validador sobre el repositorio, sin que nadie le conceda
> acceso a un solo dato de la empresa.**

Ninguna plataforma de gobernanza del mercado puede ofrecer eso, porque todas comprueban
en tiempo de ejecución sobre datos vivos.

### 3.3 Requisitos de conformidad

Toda implementación, en cualquier nivel, **DEBE**:

1. Aceptar todo caso de `/conformance/valid/` produciendo exactamente la forma canónica
   esperada, byte a byte.
2. Rechazar todo caso de `/conformance/invalid/` emitiendo el código de error esperado.
3. Producir el mismo digest que la suite para el mismo paquete de entrada.

Una implementación **NO DEBE** requerir conocimiento privilegiado de estructuras internas
de otra implementación. La implementación de referencia **DEBE** ejecutar la suite como
un consumidor externo.

> **La suite de conformidad es normativa.** Donde el texto de esta especificación y la
> suite discrepen, **la suite manda** y el texto es un defecto a corregir.

Una implementación **PUEDE** aceptar sintaxis de autoría adicionales —TypeScript, CUE,
otras— siempre que emitan la forma canónica definida en
[90 · Forma canónica](90-canonical-form.md).

---

## 4. Documentos definidos en v1alpha1

El alcance de v1alpha1 es deliberadamente mínimo. Cinco documentos, ni uno más.

| `kind` | Naturaleza | Responde a |
|---|---|---|
| `Package` | **perfil de ODCS** | quién responde, desde cuándo, con qué garantía |
| `Entity` | **gramática propia** (§7.2-bis) | qué existe |
| `Binding` | **perfil de ODCS** + `materialization` | dónde está y qué se copia |
| `Lattice` | **gramática propia** | qué etiquetas existen y cómo se ordenan |
| `ConduitPolicy` | **gramática propia** | qué sale por dónde y con qué autorización |

`Lattice` y `ConduitPolicy` se definen en [04 · Etiquetas, conductos y flujo](04-flow.md)
y son **la única gramática nueva que esta especificación introduce**. Todo lo demás es
perfil, extensión justificada o adopción.

### 4.1 · Las políticas son Cedar

OOS **NO DEFINE** un lenguaje de autorización. Las políticas se escriben en
**[Cedar](https://www.cedarpolicy.com/)** y esa es su forma canónica.

Justificación bajo el principio P7: un `Policy` propio con `subject`, `resource`,
`action`, `condition` y `effect` sería Cedar con otro vocabulario. Lo que se creía que
justificaba definirlo no lo justifica —las obligaciones se expresan como **anotaciones**
de política, la selección por etiqueta se expresa mediante la **jerarquía de entidades**
de Cedar, y la finalidad es `context.purpose`, ABAC estándar— y definir un lenguaje propio
además **renunciaría al analizador estático de Cedar**, que es la razón por la que se
eligió.

Lo que OOS sí define sobre Cedar:

1. El **vocabulario cerrado de desclasificadores** que una anotación puede invocar
   ([04 · §5](04-flow.md)).
2. El **mapeo determinista** de un paquete OOS a un esquema Cedar.

Una superficie de autoría en YAML que emita Cedar es admisible (principio P1); no es la
forma canónica.

**Aplazados a v1alpha2 o posterior:** `Relation` como documento propio (en v1alpha1 las
relaciones se declaran dentro de `Entity`), `Rule`, `Function`, `Test`, `Resolution`, y la
**resolución de dependencias** — cuyo campo `dependencies`, no obstante, **DEBE** existir
en la gramática desde v1alpha1 ([04 · §6](04-flow.md)).

> De esa lista, v1alpha2 cierra alcance con `Function` y `Resolution`. **`Rule` quedó
> retirado como documento** —`constraint` es `quality` de ODCS e `inference` es un campo de
> `Entity`— y `Test` sigue aplazado, por ser L2
> ([`spec/v1alpha2/00-scope.md`](../v1alpha2/00-scope.md) §3.1).

---

## 5. Principios de diseño

Estos principios son normativos para la evolución de la propia especificación.

**P1 · OOS es objetivo de compilación, no formato de autoría.**
La forma canónica **DEBE** ser completa (todo lo expresable en cualquier superficie de
autoría es expresable en OOS), canónica (un significado, una representación) e inerte
(datos puros, sin cómputo).

**P2 · Se declara lo que un humano decide; se computa lo que es derivable.**
Un campo derivable **NO DEBE** ser declarable. El linaje, la propagación de
clasificación, el grafo de consumidores y el radio de impacto son salida del compilador,
nunca entrada.

**P3 · Gobernar exige inercia.**
Los documentos que gobiernan —`Policy`, `ClassificationTaxonomy`, y el bloque
`materialization` de `Binding`— **DEBEN** ser datos inertes y revisables. **NO DEBEN**
admitir cómputo arbitrario.

**P4 · Denegación por defecto.**
Toda capacidad, todo acceso y toda materialización **DEBEN** ser denegados salvo
declaración explícita.

**P5 · Un paquete es autosuficiente.**
Interpretar un paquete **NO DEBE** requerir ningún servicio, catálogo ni plataforma
externa más allá de un motor conforme y las fuentes de datos que sus bindings declaran.

**P6 · Composición antes que invención.**
Donde exista un estándar abierto adecuado, OOS lo adopta en lugar de duplicarlo.
Ver sección 7.

**P7 · Carga de la prueba sobre lo que se define.**
Todo campo que OOS define y que ya exista en Apache Ossie, ODCS o SHACL **DEBE** llevar
en esta especificación una justificación escrita de por qué no puede absorberse.
Un campo sin esa justificación es un defecto, no una funcionalidad.

> Sin esta regla, OOS acaba siendo el cuarto formato YAML de semántica — que es
> exactamente el fracaso que su tesis pretende evitar.

---

## 6. Versionado

Se sigue la convención de Kubernetes: `alpha` → `beta` → estable.

- `v1alpha1`: **PUEDE** romper compatibilidad en cualquier publicación. Sin garantías.
- `v1beta1`: los cambios rompedores **DEBEN** anunciarse con una versión de antelación.
- `v1`: los cambios rompedores **NO DEBEN** producirse dentro de la versión mayor.

El campo `apiVersion` **DEBE** estar presente en todo documento y **DEBE** usar el
espacio de nombres DNS inverso `oos.dev/<versión>`.

La política de qué constituye un cambio rompedor **de la especificación** se define en
[91 · Versionado](91-versioning.md) §7, y es la misma taxonomía de cuatro ejes que se
aplica a un paquete.

### 6.1 · Qué exige el peldaño siguiente, y dónde estamos

**Promover no es una decisión: es una comprobación.** El siguiente peldaño es `v1beta1`, no
`v1` —la escalera no se salta—, y sus tres condiciones ya estaban fijadas en
[`docs/DESIGN.md`](../../docs/DESIGN.md) §1 antes de que hiciera falta medirlas:

| | Condición | Estado |
|---|---|---|
| **1** | compatibilidad de la **propia especificación** | **a medias.** La política existe —§7 de [91](91-versioning.md)— y el **mecanismo no**: `ore diff` compara paquetes, no especificaciones. Hoy se juzga a ojo |
| **2** | **suite extraída del texto** | **no.** Está escrita a mano, así que la especificación y la suite pueden divergir sin que nada avise |
| **3** | **arnés de runtime para L1** | **no.** No existe |

La segunda no es teórica y esta versión tiene la prueba: `v1alpha3/02-ruleset` afirmaba que
N4 ordena las aserciones de un `Ruleset`, la implementación no lo hacía, y **los casos
siguieron en verde** porque ninguno salía de esa frase. Con la suite extraída del texto, esa
afirmación habría generado su propio caso y la divergencia habría sido imposible.

### 6.2 · Por qué `v1` no está disponible, y no es prudencia

`v1` promete que **no habrá cambios rompedores dentro de la versión mayor**. Es una promesa
irrevocable, y se mide contra una sola cosa: **si los defectos siguen apareciendo.**

Siguen. Solo en las dos últimas revisiones aparecieron cuatro en material de v1alpha1:

| | |
|---|---|
| `nullable: true` | la ontología de referencia usaba una clave que el perfil no admite — enseñando una gramática que no existe |
| la descripción de `required` | decía *«si la propiedad admite ausencia de valor»* para un campo que significa lo contrario |
| `Entity.expr` | nombrado como campo real en ocho sitios, uno de ellos normativo. **Nunca existió** |
| N4 sin aplicar | nueve campos de lista sin clasificar desde v1alpha1, con lo que reordenar los endosos de una función daba otro digest — **G1 rota** |

El cuarto es el que decide. G1 —*el mismo commit produce el mismo digest*— es una de las dos
garantías que definen el producto, y estuvo rota sin que nada lo dijera.

> **Se promueve cuando los defectos dejan de aparecer, no cuando se decide que ya está.**

Y hay un quinto que no cuenta como defecto heredado y prueba la condición 2 mejor que
ninguno: durante esta misma revisión se publicó un esquema con **JSON inválido** y la suite
entera siguió verde, porque nada comprobaba que los esquemas publicados parseasen. Se añadió
la comprobación. Lo que no se puede añadir de uno en uno es la clase entera de fallo — para
eso está la suite extraída del texto.

---

## 7. Qué absorbe OOS y qué define

OOS **compone**; no compite. Esta sección es normativa a efectos del principio P7.

### 7.1 · Lo que se absorbe

Estos conceptos ya existen en estándares abiertos maduros. OOS **NO DEBE** redefinirlos.

| Superficie | Origen | Estado |
|---|---|---|
| Nombres del enum de tipos escalares · `unique_keys` · la idea de `ai_context` | **Apache Ossie** | absorber |
| Fundamentos del paquete: `id`, `name`, `version`, `domain`, `status` | **ODCS** | absorber |
| Equipo, canales de soporte, SLA, precios | **ODCS** | absorber |
| Servidores e infraestructura física | **ODCS** | absorber |
| Tipos lógicos y físicos de propiedad | **ODCS** | absorber |
| Reglas de calidad de datos | **ODCS** | absorber |
| **Etiqueta** de clasificación y marca PII a nivel de campo | **ODCS** (`classification`, `tags`, `criticalDataElement`) | absorber |
| Definiciones autoritativas y referencias | **ODCS** (`authoritativeDefinitions`) | absorber |
| Restricciones formales | **W3C SHACL** | absorber |
| Lenguaje de decisión de autorización | **Cedar** | absorber |
| Serialización canónica | **RFC 8785 (JCS)** | absorber |
| Atestaciones sobre el artefacto | **in-toto / SLSA / Sigstore** | absorber |
| Convención de versionado de API | **Kubernetes** | absorber |

### 7.2 · Lo que OOS define, y por qué no puede absorberse

Cada entrada satisface la carga de la prueba del principio P7.

| Lo que OOS define | Por qué no existe en ningún estándar abierto |
|---|---|
| **Propagación de la clasificación** | ODCS permite *etiquetar* un campo como PII. Ningún estándar computa que una propiedad derivada **hereda** la clasificación de sus orígenes. Una etiqueta que no se propaga miente a los seis meses, que es el modo de fallo que este proyecto existe para eliminar. |
| **Sumideros con nivel de autorización** | Nadie declara que una caché admite hasta `sensitivity: low`. Sin modelo de sumidero, la clasificación es inerte: dice que algo es sensible y nunca dice **qué prohíbe**. Es la mitad que falta. |
| **Comprobación hermética en compilación** | ODCS y Ossie son documentos: no tienen objetivo de compilación, ni artefacto, ni motor. Nada comprueba nada. La familia `OOS4xxx` no tiene equivalente. |
| **Obligaciones como vocabulario cerrado** | Cedar solo resuelve `permit`/`forbid`. ODCS no tiene modelo de decisión evaluable —sus `roles` describen a quién pedir acceso, no bajo qué condición se concede ni cómo se transforma el dato. Enmascarar, tokenizar y `aggregateOnly` no existen en ninguno. |
| **`materialization` declarada** | ODCS `servers` dice dónde vive el dato. Ningún estándar declara **qué se copia, a dónde y bajo qué restricción**, ni convierte una violación en error. |
| **El endoso de integridad** | Qué puede hacer un agente por su cuenta y qué exige una firma humana. Un endosante es a la integridad lo que un desclasificador es a la confidencialidad: `attested` eleva la de una **función**, `humanApproval` la de una **invocación**, y la regla `I(f) ⊒ I(destino)` decide si basta. Cedar concede o niega un permiso; nada en él ni en ningún estándar de datos dice **cuántos juicios humanos** hacen falta antes de que algo ocurra. |
| **Forma canónica, digest y bundle** | Ossie y ODCS describen; no compilan. Sin digest determinista no hay diff semántico, ni firma, ni promoción entre entornos, ni rollback. |

### 7.2-bis · Anfitriones y objetivos de emisión

No todos los estándares externos ocupan la misma posición, y confundirlos lleva a perfilar
lo que no se debe. El test que los separa:

> **¿Puede el documento expresarse como documento válido del anfitrión sin inventar
> valores?**

| Estándar | Posición | Por qué |
|---|---|---|
| **ODCS** | **anfitrión** de `Package` y `Binding` | un `Package` emite un contrato ODCS válido con lo que ya tiene |
| **Apache Ossie** | **objetivo de emisión** del bundle | su `Dataset` exige `source` y cada `Field` exige `expression`: ambos viven en el `Binding`. Una `Entity` sola no puede ser un modelo Ossie válido |
| **Cedar** | objetivo de emisión | el esquema se computa desde las etiquetas |
| **SHACL · OWL/RDF** | objetivos de emisión | formalismos de representación |

Un perfil funciona cuando el anfitrión es un superconjunto **con el mismo centro de
gravedad**. El de Ossie está en la analítica sobre un almacén; el de `Entity`, en el
dominio. Conformar relajando los campos obligatorios del anfitrión no es perfilar: es
fingir.

Consecuencia estratégica, y es mejor que la alternativa: **un bundle OOS emite un modelo
semántico Ossie válido, así que todo su ecosistema —Snowflake, dbt, Cube, Sigma, Hex,
ThoughtSpot— puede consumir una ontología OOS sin saber que OOS existe.**

### 7.3 · La formulación resultante

> **Ossie y ODCS describen. Cedar decide. SHACL restringe.**
> **OOS es el formato que convierte esas descripciones en un artefacto ejecutable con
> garantías verificables en tiempo de compilación.**

La analogía exacta es **SLSA**: SLSA no define cómo se construye software: define
propiedades verificables sobre construcciones y las atestaciones que las prueban. OOS no
define cómo se modela un dominio: define las propiedades de gobernanza verificables sobre
ese modelo y la compilación que las prueba.

### 7.4 · Consecuencia para v1alpha1

Los documentos `Package` y `Binding` **DEBEN** definirse como **perfiles** de ODCS —un
subconjunto requerido, más las extensiones justificadas en 7.2— y no como formatos
independientes.

`Entity` **NO DEBE** definirse como perfil. Es la consecuencia directa del test de 7.2-bis:
el `Dataset` de Ossie exige `source` y cada `Field` exige `expression`, y ninguno de los dos
está en una entidad —están en el `Binding`—, así que una `Entity` sola no puede ser un
documento Ossie válido. Conformar inventando esos campos no es perfilar. `Entity` es
gramática propia y Ossie es objetivo de emisión del bundle; el argumento completo está en
[`02-entity.md`](02-entity.md) §1.2.

> Consecuencia comprobable: un documento `Entity` **NO DEBE** declarar `profile`. El campo
> existe en `Binding`, que sí perfila.

Las tres únicas extensiones al modelo semántico admitidas en v1alpha1, cada una con su
justificación:

1. **Temporalidad** — ni Ossie ni ODCS modelan tiempo de validez y tiempo de transacción.
   Sin ellos, un salario es un número y no una función del tiempo.
2. **Unidades y precisión** — `logicalType: number` no distingue euros de dólares ni fija
   redondeo. Es un error silencioso: no falla, da cifras incorrectas.
3. **Clasificación como propiedad del tipo** — necesaria para que la propagación sea
   computable por el compilador y no una anotación documental.

---

## 8. Índice normativo

| Documento | Naturaleza | Contenido |
|---|---|---|
| `00-overview.md` | — | este documento |
| [`01-package.md`](01-package.md) | perfil de **ODCS** | manifiesto, propiedad, ciclo de vida, `dependencies` |
| [`02-entity.md`](02-entity.md) | **gramática propia** | propiedades, tipos, temporalidad, unidades, etiquetas, derivación, `moved`/`reserved` |
| [`03-binding.md`](03-binding.md) | perfil de **ODCS** | mapeo físico, `materialization`, `freshnessSLA`, perfil de conector |
| [`04-flow.md`](04-flow.md) | **gramática propia** | retículos, conductos, desclasificadores, la regla de flujo |
| [`05-ejecutor.md`](05-ejecutor.md) | **gramática propia** | qué debe hacer un L2: la ley del ejecutor, las dos aplicaciones, credenciales, marca de agua |
| [`90-canonical-form.md`](90-canonical-form.md) | — | normalización, serialización determinista, digest |
| `91-versioning.md` | — | versionado de la especificación y de los paquetes |
| [`99-errors.md`](99-errors.md) | — | registro de códigos de error |

Las políticas no tienen documento: **son Cedar** (§4.1).

### 8.1 · Anatomía de un documento de perfil

Los tres perfiles tienen la misma estructura, y las tres partes son igual de normativas:

1. **Restricción** — qué subconjunto del anfitrión es obligatorio, opcional o queda fuera.
2. **Extensión** — lo que OOS añade, cada campo con su justificación bajo P7, y el
   registro explícito de lo que se consideró extender y no se extendió.
3. **Traducción** — el mapeo **bidireccional** con el anfitrión.

La tercera decide si el perfil sirve de algo. **Un perfil que solo restringe es una
limitación; uno que hace ida y vuelta sin pérdida es interoperabilidad**, y es la razón de
perfilar en lugar de inventar.
