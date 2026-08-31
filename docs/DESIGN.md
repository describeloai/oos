# Diseño y razonamiento

> **No normativo.** `spec/v1alpha1/` manda. Si algo de aquí la contradice, el defecto está
> aquí.
>
> **Regla anti-duplicación:** lo que la especificación define no se repite en este
> documento. Aquí vive únicamente el *porqué*, y lo que queda fuera del alcance de la
> especificación: el motor, el negocio y la posición competitiva.

---

## 1 · Por qué existe

Una empresa ya sabe describir sus datos. Tiene catálogos, contratos, capas semánticas y
diagramas. Lo que no tiene es forma de **demostrar** que esa descripción es cierta, ni de
**ejecutarla**.

Las etiquetas de PII se ponen a mano y dejan de ser ciertas en seis meses. Las políticas
viven en una plataforma y no en el pull request que cambia el dato. El linaje se escribe
en Confluence. Y cuando un agente pregunta, nadie puede decir con certeza qué tenía
permitido saber ni quién lo autorizó.

> **El cuello de botella no es describir. Es que la descripción no obliga a nada.**

Era tolerable mientras el consumidor era un humano que podía preguntar por Slack. Con
agentes autónomos deja de serlo: **un agente no pregunta, asume. Y asume mal.**

La respuesta refleja del mercado es copiar —otro lake, otro grafo, otro índice vectorial—
lo que multiplica coste, latencia y superficie de cumplimiento sin resolver nada. El
problema no es dónde están los datos: es que nadie ha escrito, **de forma ejecutable**,
qué significan.

### La tesis

Tratar el conocimiento de una empresa exactamente como su código: texto declarativo en
Git, revisado en pull requests, validado en CI, compilado a un artefacto ejecutable y
desplegado con rollback. Es el mismo movimiento que ya ocurrió con la infraestructura
(Terraform), el esquema (Flyway) y la transformación (dbt), aplicado al último dominio que
faltaba.

### El claim

> **OOS convierte un repositorio de Git descriptivo en un paquete portable, tipado y
> versionado, cuya gobernanza se demuestra al compilar —sin red, sin credenciales y sin
> tocar un solo dato— y cuyo artefacto ejecuta cualquier motor conforme.**

Formulación de v1alpha1, y conviene saber qué sustituye. La versión original decía
*«portable, tipado, gobernado, versionado, autosuficiente y ejecutable por cualquier
motor/script»*. Al cerrar la especificación, tres cosas cambiaron:

- **«Gobernado» se quedaba corto.** Es lo que dicen Collibra y Unity Catalog. Lo nuestro es
  que **la violación no compila**, y se comprueba sin tocar un dato.
- **«Versionado» también.** Git da versionado gratis. Lo que aporta OOS es que **el carácter
  rompedor de un cambio se computa** en cuatro ejes, en vez de afirmarse.
- **«Ejecutable por cualquier motor» no sobrevivía sin cualificar.** Cuando se escribió no
  existían los niveles de conformidad, y estos son implacables: **solo L0 es decidible por
  una suite de ficheros.** L1 exige un proceso vivo; L2 y L3, datos reales.

Y una honestidad que conviene mantener escrita: **una especificación no puede hacerse
ejecutable a sí misma.** «Cualquier motor conforme» no es una propiedad de OOS — es un
hecho empírico que se vuelve cierto **el día que una segunda implementación independiente
pasa la suite**. Hasta entonces hay evidencia —76 casos, 53 códigos, identidad determinista,
una implementación de referencia sin privilegios— y no prueba.

Mapa de cuándo se completa:

| | Qué añade al claim |
|---|---|
| **v1alpha1** | queda definido y comprobable en **L0** |
| **ORE fases 0–3** | queda **demostrado una vez** por la implementación de referencia |
| **v1alpha2** | `Function`, `Resolution` y la resolución de dependencias → «ejecutable» cubre L2 y L3, y «autosuficiente» se cierra |
| **v1alpha3** | [la capa de gobierno](../spec/v1alpha3/00-scope.md): el objetivo por clasificación, el `Ruleset`, la máscara y el deber → la cobertura es comprobable al compilar |
| **v1alpha4** | [el significado](../spec/v1alpha4/00-scope.md): `Property` como concepto compartido e `Interface` como forma → la clasificación deja de ser arbitraria |
| **v1beta1** | compatibilidad de la propia spec, suite extraída del texto, arnés de runtime para L1 |
| **segunda implementación** | el claim deja de ser intención y pasa a ser hecho |

Limitación asumida desde ahora: **L2 y L3 probablemente nunca sean certificables por una
suite de ficheros.** Ahí el claim descansará en que la especificación sea suficientemente
clara, no en que algo lo demuestre.

---

## 2 · El eje

Una sola cosa en cuatro estados. Casi toda la confusión del espacio viene de usar la
palabra *ontología* para las cuatro.

| Estado | Nombre | Lo produce | Su identidad es |
|---|---|---|---|
| Fuente | Ontology Repository | humano + scaffolder | un **commit SHA** |
| Artefacto | Ontology Bundle | el compilador | un **digest** |
| Materialización | el Grafo | el runtime | bundle + marca de agua |
| Superficie | MCP · GraphQL · SDK | el runtime | endpoint versionado |

Un consumidor nunca ve un repositorio ni un bundle: ve una superficie. Un operador nunca
despliega un repositorio: despliega un bundle. Un humano nunca edita un bundle: edita la
fuente.

Y cinco piezas, cada una con un trabajo:

| Pieza | Qué es | Análogo |
|---|---|---|
| **Ontology-as-Code** | el paradigma | Infrastructure-as-Code |
| **OOS** | el régimen: identidad, compilación, conformidad, gobernanza | OCI Image Spec |
| **Ontology Repository** | la fuente | `Dockerfile` + contexto |
| **Ontology Bundle** | el artefacto | imagen OCI |
| **ORE** | el motor | `containerd` |

> Los principios normativos de OOS (**P1–P7**) están en
> [`spec/v1alpha1/00-overview.md`](../spec/v1alpha1/00-overview.md) §5 y no se repiten
> aquí.

---

## 3 · ORE — el motor

Lo que sigue **no** es OOS. OOS define el artefacto;
[ORE](https://github.com/describeloai/ore) define la ergonomía y la ejecución. La separación
es sana: otro proveedor podría construir una experiencia mejor y seguir produciendo paquetes
conformes — y es literal, no retórica: son dos repositorios, y el de OOS no depende del otro
en ninguna dirección.

### 3.1 · Tres caras, tres fronteras de confianza

| Cara | Momento | Comandos | Frontera |
|---|---|---|---|
| **Scaffolder** | autoría | `init`, `source add`, `discover`, `review`, `drift-detect` | toca metadatos de producción y, opcionalmente, un LLM |
| **Compilador** | CI | `lint`, `validate`, `test`, `diff`, `plan`, `compile`, `promote` | **hermético**: sin red, sin credenciales |
| **Runtime** | producción | `dev`, `serve` + Helm | custodia credenciales vivas de todas las fuentes |

Que el compilador sea puro es argumento de venta por sí solo: **el paso que decide qué
significan las cosas es el único que no puede filtrar nada.** Nueve de catorce comandos no
abren un socket.

Y el scaffolder queda **fuera del camino de ejecución de confianza**: escribe ficheros,
nunca escribe en el grafo. Lo que produce es una propuesta en `DRAFT`, y la única vía de
propuesta a verdad es un commit revisado. **La IA aporta velocidad sin aportar autoridad.**

### 3.2 · Los dos planos

| Plano | Qué sirve | Dónde vive | Latencia |
|---|---|---|---|
| **Contexto** | entidades, relaciones, tipos, políticas, linaje | artefacto compilado, **mapeado en memoria** | µs–ms |
| **Datos** | filas y valores | consulta federada al origen | la de la fuente |

Casi todo lo que un agente necesita para no alucinar vive en el plano de contexto, que es
local y compilado. Decir esto explícitamente convierte el claim de rendimiento de
marketing en arquitectura.

**El plano de contexto no quiere una base de datos.** Son megabytes que no cambian entre
despliegues: la forma correcta es un artefacto de solo lectura mapeado en memoria (`rkyv`,
Cap'n Proto), no un KV store.

### 3.3 · Sin estado por defecto

> **ORE es *stateless* por defecto y *stateful* por declaración.**

Un repositorio que no materializa nada no necesita base de datos alguna: arranca, mapea el
bundle y sirve. El almacenamiento aparece solo cuando un binding declara `topology` o
`payload` — dos ejes independientes, no un modo con tres valores
([`03-binding`](../spec/v1alpha1/03-binding.md) §3.1).

Tres consecuencias: el ORE abierto es **apto para producción** en el caso mayoritario; la
complejidad operativa es proporcional a la ambición y no un peaje de entrada; y el tier
Enterprise tiene algo sustantivo que hacer —construir, firmar, distribuir y refrescar
índices grandes entre nodos.

Contraste útil: en Foundry el índice **no es opcional**; el Object Data Funnel y el Object
Storage *son* el camino de servicio.

### 3.4 · El bucle GitOps

```
merge a main → webhook → ORE descarga el delta → recompila → hot reload sin downtime
```

Estado deseado en Git, estado real en el grafo, un reconciliador que los converge. **Es
ArgoCD aplicado a la semántica** — una frase que cualquier ingeniero de plataforma entiende
en dos segundos, y que coloca el producto en una categoría que ya se compra.

Su corolario es la razón de compra en sector regulado: si el grafo es siempre función
determinista de un commit, *"¿qué sabía el agente el martes a las 14:32?"* se responde con
**un commit y una marca de agua**.

### 3.5 · Conectar una fuente

Nadie escribe un binding a mano.

```console
$ ore source add --name crm_prod postgres://acme:••••@db.internal:5432/crm
  ✓ credencial en .env.local (añadido a .gitignore) · config actualizado
  ✓ residency: <sin declarar>   ← decisión pendiente

$ ore discover --source crm_prod --out packages/customers
  12 entidades · 38 relaciones desde claves foráneas · 4 tablas puente
  6 critical · 11 high · 3 sin decidir (conf. 0.31)
  ⚠ 3 decisiones te esperan: ore review

$ ore review
  notes : text — confianza 0.31. ¿Sensibilidad?
  › high   texto libre, puede contener PII   (recomendado)
```

**No escriben ficheros: contestan preguntas.** Y las políticas tampoco se escriben —
`ore policy add --template gdpr.purpose-limitation` pide cuatro respuestas y emite nueve
líneas de Cedar correcto. Escribir Cedar a mano es la vía de escape del 10%, no el camino
normal.

`ore init --profile gdpr` arranca el repositorio con retículo, conductos sensatos y
catálogo de plantillas: **no se parte de un fichero en blanco, se parte de una postura
heredada del regulador.**

### 3.6 · Sobre la fricción frente a una interfaz gráfica

La interfaz nunca fue el valor. **La interfaz es una forma de rellenar un formulario.**

| | Plataforma gestionada | Aquí |
|---|---|---|
| El formulario produce | una fila en su base de datos | **líneas en un pull request** |
| ¿Revisable? ¿Reversible? | no · a veces | sí · `git revert` |
| ¿Existe sin el proveedor? | no | sí |

> **La fricción no está en el formulario. Está en lo que el formulario produce.**
> La interfaz es opcional; el artefacto no. En una plataforma gestionada es al revés.

Y el formulario también podemos tenerlo: `review`, `policy add`, la extensión de editor y
un editor visual en la plataforma — cuya salida sería **un commit**. Modelo GitHub exacto.

### 3.7 · Superficie de servicio

Tres, y ninguna más en v1: **MCP** (sustituye a seis adaptadores de framework y es donde
está la distribución del ecosistema agéntico), **GraphQL** (aplicaciones) y **protocolo
nativo** (alto rendimiento). JSON-LD y Cypher son `ore export --format`, no camino
caliente.

### 3.8 · Aplicación de política

La política la aplica el motor, en un punto único, **nunca el consumidor**. Una aplicación
o un agente no pueden saltarse el enmascaramiento olvidándose de aplicarlo. Cada decisión
—qué política, qué efecto, qué obligación— se registra: es artefacto de cumplimiento, no
línea de debug.

El *qué* de esa frase lo especifica [v1alpha3](../spec/v1alpha3/01-gobierno.md): la máscara
es un desclasificador del vocabulario cerrado de v1alpha1, y la obligación es una `Function`
de v1alpha2. Lo que aquí es una decisión de runtime, allí es una propiedad del artefacto.

---

## 4 · Materialización

### 4.1 · "Metadatos" son seis peldaños

| # | Peldaño | Tamaño | ¿Es dato? |
|---|---|---|---|
| 1 | Especificación (el bundle) | MB | no |
| 2 | Esquema físico | MB | casi nunca |
| 3 | Estadísticas | MB | **min/max e histogramas sí** |
| 4 | Muestras | KB | sí |
| 5 | **Topología** (aristas) | GB | **la más sensible en muchos sectores** |
| 6 | Valores materializados | TB | copia completa |

Dos trampas: el peldaño 3 filtra sin que nadie lo note —un `min/max` sobre `salary` *es* un
dato—, y el peldaño 5 es el más delicado y nadie lo discute: **saber que el paciente X está
enlazado con la clínica oncológica Y es el diagnóstico**, aunque no se haya copiado ningún
campo clínico.

### 4.2 · Por qué copiar la topología

Si `Customer` vive en Postgres e `Invoice` en Snowflake, recorrer `Customer → Invoice →
LineItem` son tres joins federados encadenados. Es lento, y es por lo que los motores de
federación decepcionan.

> **La única forma de hacer rápida la travesía sin copiar los datos es copiar las aristas.**

Mil millones de aristas son decenas de GB; los datos que describen, petabytes. Se almacena
del orden de una diezmilésima del volumen y se obtiene velocidad de grafo nativo.

De ahí una descripción del producto más precisa y más honesta que "federación cero-copia":

> **ORE es un índice secundario distribuido: topología local, carga útil en origen.**

Foundry es rápido porque materializa **todo**. El camino intermedio es genuinamente
diferenciado, y es lo que permite sostener a la vez la velocidad y la promesa.

### 4.3 · El claim correcto

> **Copiamos la topología, nunca la carga útil — y tú declaras en código qué se copia.**

Suena a ingeniería en vez de a marketing, y aguanta una evaluación técnica.

### 4.4 · El problema caro

Mantener el índice fresco es el trabajo de ingeniería más costoso del runtime. Foundry lo
resuelve con sondeo del origen, aprovechamiento del versionado nativo cuando el formato es
Delta o Iceberg, e indexación incremental. No hay atajo.

Ventaja de partida que merece medirse pronto: **la incrementalidad sobre topología es mucho
más barata que sobre carga útil** — cambiar la columna `notes` de un millón de filas no
altera ni una arista.

---

## 5 · Posición

### 5.1 · Frente a Palantir Foundry

Palantir lanzó **SuperRepo** con Ontology-as-code: object types, links, interfaces y
actions en TypeScript, Foundry CLI local, vista previa en la máquina del desarrollador,
bundle firmado, CI externa y Global Branching.

**Dos ventajas que se le atribuían a este proyecto ya no existen:** el branching semántico
y el "vive donde vive la ingeniería". Palantir llegó antes.

Léase también al revés: **el competidor mejor informado del mercado concluyó de forma
independiente que esto debe vivir en código.** La tesis era correcta.

Lo que sobrevive, en orden de fuerza:

1. **Dónde ejecuta el artefacto — la única irreducible.** Su documentación dice que las
   definiciones *"se materializan como entidades reales en tu enrollment"*. El código es
   fuente de la verdad **para la autoría**; el estado autoritativo vive en Foundry.
   > **Un SuperRepo sin Foundry no vale nada. Un Ontology Repository sin nosotros sigue
   > valiendo.**
   > SuperRepo es una app de Heroku; un Ontology Repository es una imagen OCI.
2. **Governance-as-code.** En SuperRepo se declaran object types, links, interfaces y
   actions. **No políticas, no clasificación, no ABAC, no materialización.** Eso vive en la
   plataforma: no va en el PR, no lo revisa `CODEOWNERS`.
3. **Ámbito.** Su propio encuadre: *"una Ontología y una aplicación que evolucionan
   juntas"*. Es un monorepo de producto. Palantir no ha llevado la ontología corporativa a
   código: ha llevado el modelado de dominio **de una aplicación** a código.
4. **Especificación abierta** y suelo de precio.

Matiz obligado: Foundry tiene **virtual tables** —punteros a sistemas externos sin
ingesta—, así que *"te obliga a ingerir todo"* ya no es exacto y no debe usarse.

Y un matiz de vocabulario que evita malentendidos al leer su documentación: **lo que Foundry
llama `rule` es lo que aquí se llama `Function`.** Sus doce reglas de *action type* son
`create object`, `modify object`, `delete link` y demás, más webhook, notificación y
*schedule*. Lo que aquí es una regla —una afirmación que debe sostenerse— allí son
*submission criteria*, y van **enumeradas dentro de cada action type**: sin objetivo, igual
que en ODCS.

Y donde Foundry gana, sin adornos: quince años de campo, sistema completo en vez de capa,
integración industrial, capa de aplicaciones, y el foso que no es tecnológico — los
Forward Deployed Engineers. **Competimos con un producto contra un servicio.**

> No compites con Foundry por funcionalidades. **Abaratas la capa sobre la que Foundry
> cobra.** Git no ganó a ClearCase siendo mejor punto por punto: ganó haciendo gratis la
> operación cara. Aquí la operación cara es **cambiar de opinión sobre lo que significan
> las cosas**.

Consecuencia práctica: el objetivo **no** son las cuentas donde Foundry está instalado.
Son las cien empresas que lo evaluaron y no pudieron pagarlo.

### 5.2 · Frente a los estándares abiertos

La casilla *"estándar abierto de metadatos semánticos"* **ya está ocupada**: Apache Ossie
(ex-OSI), bajo la ASF, con Snowflake, Salesforce, dbt Labs, Dremio, Cube, Atlan y
BlackRock. Y ODCS bajo la Linux Foundation.

No se compite: **se compone**, y el reparto está fijado normativamente en
[`spec/v1alpha1/00-overview.md`](../spec/v1alpha1/00-overview.md) §7.

> **Ossie y ODCS describen. Cedar decide. SHACL restringe. OOS convierte esas
> descripciones en un artefacto ejecutable con garantías verificables en compilación.**

La analogía exacta es **SLSA**: no define cómo se construye software; define propiedades
verificables sobre construcciones y las atestaciones que las prueban.

**Riesgo a vigilar:** en la coalición de Ossie están Alation, Atlan y Snowflake — vendedores
de gobernanza. Es plausible que el hueco se cierre. Refuerza lo ya decidido: **el foso
duradero es ORE y `ore discover`, no la especificación.**

### 5.3 · Frente a catálogos y capas semánticas

Los catálogos —OpenMetadata, DataHub, Collibra— **describen; no ejecutan**. Un catálogo
sabe que existe una columna `sal_amt`; no sabe que *ejecutivo* es quien gestiona a más de
ocho personas, ni puede calcularlo.

Y su tamaño explica el nuestro: OpenMetadata tiene 700+ esquemas porque enumera conectores,
envolturas de API REST, cada tipo de activo que existe y funcionalidades de producto
(`scim`, `jobs`, `monitoring`). **Tienen el tamaño de un producto, no el de una
especificación.**

> **OpenMetadata enumera el mundo. OOS aporta una gramática.**

Las capas semánticas (dbt, Cube, LookML) son métricas sobre un warehouse: sin grafo, sin
inferencia, sin políticas ejecutables, atadas a un motor.

Un aviso que conviene tener escrito porque va contra el instinto: **apuntar por clasificación
en vez de enumerar no es una idea nuestra.** Unity Catalog tiene en GA el filtrado de filas y
el enmascarado de columnas por etiqueta gobernada —`has_tag_value('pii','ssn')`— bajo el lema
*«Govern Once, Protect Everywhere»*, y Snowflake y BigQuery tienen lo equivalente. El mercado
convergió ahí. Lo que sigue siendo nuestro es **dónde vive** —en el artefacto versionado, no
en el catálogo de un motor—, que la aplicación sea decidible al compilar, y que la máscara
**declare qué clasificación produce**: la de un catálogo es opaca al gobierno, se evalúa en
tiempo de consulta y nadie sabe qué etiqueta sale por el otro lado.

### 5.3-bis · El plano de política: quién exige, y cuándo

La comparación que decide si v1alpha3 aporta algo no es de funcionalidades. Es una sola
pregunta hecha a los cuatro: **¿cómo sabes que este dato está gobernado?**

| | Cómo se sabe | Cuándo se sabe | Qué pasa si no lo está |
|---|---|---|---|
| **Microsoft Purview** | un **porcentaje** — *«% de activos clasificados»* en *Data Estate Insights* | en el comité mensual de gobierno | una fila roja en un informe |
| **Databricks UC** | clasificación automática por IA + *governed tags*, y ABAC encima | continuo, después de crear el dato | la política lo coge **si la IA lo etiquetó** |
| **AWS Lake Formation** | LF-Tags heredados por el catálogo | al conceder permisos | nada: sin etiqueta no hay política |
| **Palantir Foundry** | *mandatory controls* **heredados de las fuentes** | al materializar | lo más restrictivo gana — **falla cerrado** |
| **OOS** | una **diferencia de conjuntos** | **al compilar, antes del merge** | **no compila** |

Tres lecturas, y la tercera es la que importa.

**Solo Foundry y OOS paran algo.** Purview mide, AWS habilita, Databricks automatiza la
entrada. Foundry es el único competidor que **falla cerrado**, y conviene decirlo sin
adornos: su propagación de *markings* por las fuentes es, en fondo, nuestro `join`. Lo que
`00-overview` §7.1 reclama —*«ningún estándar computa que una propiedad derivada hereda la
clasificación de sus orígenes»*— sigue siendo cierto **de los estándares** y no de Foundry.
La diferencia con ellos no es que propaguemos: es **dónde vive el artefacto y cuándo falla**.

**Todos contestan una pregunta distinta de la nuestra.** La suya es *«¿está etiquetado?»*; la
nuestra es *«¿está gobernado?»*. Y son preguntas diferentes: una columna puede estar
perfectamente clasificada y no tener una sola regla encima. Databricks nombra el hueco con
precisión —*«la aplicación que depende de coordinarse con los dueños de los objetos deja
huecos»*— y lo cierra por el lado de la **entrada**, automatizando la clasificación con IA.
Es una buena respuesta a *su* pregunta, y deja la nuestra intacta.

> **Nosotros no clasificamos: hacemos que clasificar tenga consecuencias.**

Eso ordena el ecosistema en vez de disputarlo. Un clasificador automático —AWS COA, la
clasificación de Unity Catalog— es **una entrada** nuestra, no un competidor: produce
etiquetas, y `OOS8001` convierte cada etiqueta en una obligación que rompe la compilación si
nadie la asume.

**Y el porcentaje es el antipatrón, no el listón.** Un cuadro de mando que dice *«87 %
clasificado»* se mira una vez al mes y nunca ha impedido un despliegue. La cobertura como
métrica informa; **como error de compilación, obliga**. Es la misma distancia que hay entre
un linter y un compilador, y es toda la tesis del proyecto aplicada al plano de gobierno.

Lo que **no** tenemos y ellos sí, para que no se lea como una lista de victorias: no
escaneamos, no clasificamos, no evaluamos en tiempo de consulta y no tenemos plano de
control. Cuatro cosas de producto que no son de la especificación, y una que sí lo es —
**decidir si una regla es la adecuada** (§5.3-ter).

### 5.3-ter · Cobertura y adecuación no son la misma pregunta

`OOS8001` demuestra que **existe** una regla. No demuestra que sea **la adecuada**: una
política que permite todo cubre igual que una que no permite nada.

Conviene separar las dos, porque una es decidible y la otra no lo será nunca:

| | Pregunta | ¿Decidible al compilar? |
|---|---|---|
| **cobertura** | ¿hay una regla, y de la clase que esta clasificación exige? | **sí** — es una diferencia de conjuntos |
| **adecuación** | ¿es la regla correcta? | **no**, y fingir que sí sería el peor error del proyecto |

Lo que se puede hacer con la segunda es lo que este proyecto hace con todo lo indecidible:
**no computarla, sino exigir que alguien responda por ella**. Un `Ruleset` tiene `owner`; y
si hace falta más que un nombre, tiene el mecanismo que v1alpha2 ya inventó para esto —
`endorsements`, que es cómo se declara *me hago responsable* de forma verificable en el
repositorio.

> El compilador decide la **cobertura**. El endoso registra la **adecuación**.

Ninguno de los cuatro jugadores separa las dos, y por eso ninguno puede decir cuál de sus
reglas ha revisado un humano y cuál lleva tres años ahí porque alguien tenía prisa.

### 5.4 · Cuellos de botella donde esto paga

El patrón común: **una empresa no puede responder mecánicamente preguntas sobre su propia
semántica**, y hoy la única vía es arqueología manual.

| Workflow | Comprador | ¿Presupuesto ya existe? |
|---|---|---|
| **Migración de plataforma** — el binding dual permite `ore diff` de la salida semántica: equivalencia demostrada, no comparada fila a fila | VP Data | ✅ asignado, con padrino |
| **Cumplimiento y trazabilidad de agentes** | CISO / CCO | ✅ y crece |
| **DSAR / derecho al olvido** — el índice de topología *es* el mapa de qué fuente tiene qué instancia | DPO | ✅ recurrente |
| **M&A** — armonización explícita y revisable; los roll-ups de PE lo tienen 20 veces | IMO | ✅ urgente |
| **Superficie de acción gobernada** — el bloqueo de los pilotos agénticos no es la capacidad del modelo: es que no existe superficie con precondiciones, permisos y auditoría | CTO / CISO | ⚠️ en formación, mayor techo |
| Deriva de esquema · deprecación · modelo-vs-contexto | Data Platform | ⚠️ dolor sin partida |

Y el criterio de entrada: **¿qué workflow entrega valor completo sobre una ontología
pequeña?** Casi todos pagan por cobertura, que es lo que no hay el primer día. Solo dos
escapan porque son verticales: **DSAR sobre un dominio con PII**, y **cumplimiento sobre
una métrica regulada de extremo a extremo**.

> Aterrizar por cumplimiento en superficie estrecha · expandir por migración · capitalizar
> con la superficie de acción agéntica.

---

## 6 · Modelo de negocio

Open core. El sustrato abierto, el plano de control comercial.

### 6.1 · Los comparables son tres modelos, no uno

- **Motor más rápido** (Photon, Warp Speed) → se erosiona, y crea el incentivo perverso de
  no invertir en el motor abierto.
- **Hosting gestionado** (Confluent Cloud) → el más commoditizable. Kafka es ubicuo y
  Confluent vale mucho menos de lo que esa ubicuidad sugiere: **AWS MSK se comió el
  hosting**.
- **Plano de colaboración y gobernanza** (GitHub, Unity Catalog) → efecto de red y
  cumplimiento. El más defendible y el único sin conflicto de interés con el núcleo.

> **GitHub no vendió "Git más rápido". Vendió el pull request.** Ese es el modelo primario.

### 6.2 · La mecánica que zero-copy cierra

Databricks factura compute; Snowflake, compute y almacenamiento. **Nosotros, por diseño, no
hacemos ninguna de las dos**: la elegancia arquitectónica elimina los dos contadores más
fáciles.

Quedan **asientos, gobernanza y nodos**. No es mala noticia —mejor margen y renovación más
pegajosa que el consumo— pero obliga a diseñar para esa mecánica: **maximizar cuántos roles
tienen razón para entrar.**

### 6.3 · Los tres pilares, por defensibilidad

1. **Rendición de cuentas de agentes de IA.** No es una funcionalidad: es una categoría de
   cumplimiento sin proveedor. Lo compra un CISO —que no compara precios—, de otro
   presupuesto, y renueva siempre. **No venderlo como "gobierno del dato"**: ahí están
   Collibra e Immuta con ciclos de dieciocho meses.
   > *Cuando el regulador pregunte qué sabía tu agente y quién lo aprobó, respondes con un
   > commit.*
2. **Coordinación a escala.** Registry, dependencias, linaje cruzado, promoción de bundles.
   El único pilar con **efecto de red**, y el que decide si el techo son cientos de
   millones o miles de millones.
3. **Enterprise Runtime.** HA multi-región, sincronización de índices, conectores. Legítimo
   —cumple el criterio de *"lo que solo existe a partir del segundo nodo"*— con una línea
   que no se cruza.

### 6.4 · La trampa del núcleo capado

*"Perfecto para desarrollo local"* se lee como *"no apto para producción"*, y eso invierte
la estrategia: si el ORE abierto no aguanta producción, nadie estandariza sobre él.

| Diferenciar por… | ¿Legítimo? |
|---|---|
| Capacidades que solo existen a escala (HA, multi-región, flota) | ✅ nadie se siente engañado |
| Superficie de conectores enterprise | ✅ modelo Starburst |
| **Techo artificial de rendimiento en el camino caliente** | ❌ mata la captura del estándar |

> El ORE abierto **debe ser plenamente apto para producción** en un nodo y una región, sin
> límite de uso, para siempre.

### 6.5 · Licencia y encuadre

**Apache-2.0 para ORE core**, escrito desde el primer commit. Nada de BSL ni SSPL: la tesis
es captura de estándar, y una licencia no-OSI bloquea justo lo que se necesita. HashiCorp
pasó Terraform a BSL y OpenTofu existía en semanas.

**Gobernanza de OOS fuera de la empresa** — carta pública como mínimo, fundación
idealmente. Cuesta poco ahora y es casi imposible después.

Y el encuadre interno: llamar *caballo de Troya* al producto abierto lo enmarca como un
medio, y eso se filtra a las decisiones en el año cinco.

> **El producto abierto no es un caballo de Troya. Es el estándar. El negocio es lo que el
> estándar vuelve necesario a escala.**

### 6.6 · Dos avisos contra los invariantes

- **El log de decisiones de política es tan sensible como los datos.** "Quién consultó qué
  y cuándo" es un registro de patrones de acceso. Si sale de la VPC del cliente, es el punto
  exacto donde el CISO que compra el pilar 1 te lo tumba. Por defecto: almacén en
  infraestructura del cliente, plataforma indexando agregados.
- **La plataforma orquesta la materialización; no la aloja.** Control plane contra data
  plane, sin excepciones. Es lo que mantiene literal la frase *"tus datos no salen de tu
  infraestructura"*.

---

## 7 · Decisiones abiertas

### 7.1 · Bloquean el diseño

| | |
|---|---|
| **Motor de consulta federada** | Está el *qué* (cero copia) y no el *cómo*: sin planificador ni política de pushdown, "cero copia" es una intención. En Rust, **Apache DataFusion** es la respuesta evidente |
| **Frescura del índice** | CDC · sondeo con marca de agua · versionado nativo Iceberg/Delta. Lo más caro del runtime |
| **Writeback** | **Decidido en la especificación** — una transacción, una fuente ([`02-function`](../spec/v1alpha2/02-function.md) §5.2, `OOS7008`). Queda el *cómo*: qué hace el runtime cuando un flujo necesita dos fuentes y la spec le niega la atomicidad |
| **Resolución de identidad** | **Decidido** — [`03-resolution`](../spec/v1alpha2/03-resolution.md): la determinista lee solo la clave; la probabilística **es un conducto** y no alcanza la cima del retículo de integridad sin un endoso. Queda el emparejador en el runtime |
| **Enlace contra una clave alternativa** | SQL permite `REFERENCES t (columna_unica)` y los sistemas heredados enlazan justo asi —por NIF, por DUNS, por codigo de articulo—. `via` solo se empareja con la `primaryKey` del destino, y peor: `discover` emitiria una relacion **verde y equivocada** cuando la aridad y los tipos coincidan por casualidad. Forma propuesta: un `toKey` opcional. Reabierto desde **§7.1-bis** |
| **Atributos ABAC en tiempo de consulta** | ¿JWT, IdP, la propia ontología? Sin cerrarlo, las políticas no son ejecutables. Se decide con la capa de gobierno (v1alpha3) |

### 7.1-bis · El enlace compuesto — **cerrado**

> **Decidido y escrito.** `via` es una secuencia emparejada posición a posición con la
> `primaryKey` de `target`: [`02-entity`](../spec/v1alpha1/02-entity.md) §6, `OOS3006` para
> que la aridad y los tipos casen, `OOS5027` para que `ore diff` lo vea. Lo que sigue es el
> razonamiento, que no cabe en una especificación normativa y sin el cual la forma elegida
> parece arbitraria.

Salió construyendo `ore-read-postgres` contra un servidor real, no leyendo: una foránea
`facturas(id_cliente, cod_pais) → clientes(id, cod_pais)`. BigQuery no tenía ninguna, así
que la rama nunca se había ejercitado. El inductor la emitía **recortada a su primera
columna**, que es la forma de fallo que este proyecto lleva encontrando en todas partes —
una relación que une de menos tiene exactamente el mismo aspecto que una correcta.

**La asimetría, medida.** OOS ya sabe componer en todos los sitios menos en uno:

| Dónde | Qué admite |
|---|---|
| `primaryKey` | una **secuencia** de propiedades |
| `uniqueKeys` | un array de **arrays** — y su propósito declarado es la unión entre fuentes |
| `Resolution.match` ([v1alpha2 §2](../spec/v1alpha2/03-resolution.md)) | una **lista de pares** de columnas entre fuentes |
| `@key(fields: "a b")` ([v1alpha5](../spec/v1alpha5/01-emision-graphql.md)) | un **conjunto** de campos, y ORE ya lo emite |
| `relations.via` | **un** identificador |

> **El vocabulario admite el blanco y prohíbe la flecha.**

Y `OOS3005` —*«`one_to_one` exige que `via` esté en `primaryKey` o en `uniqueKeys`»*—
**subcomprueba** por lo mismo: con `primaryKey: [id, cod_pais]`, un `via: id` satisface la
regla sin identificar nada.

**Por qué es de escala y no de comodidad.** Una fuente moderna tiene claves subrogadas de
una columna y el problema no aparece. Cien fuentes traen sistemas heredados, y ahí la clave
natural compuesta es la norma: `(sociedad, documento)` en SAP, `(id, país)` en cualquier ERP
multipaís, `(fecha, tienda)` en cualquier almacén particionado por negocio. **La limitación
no se manifiesta al probar el producto: se manifiesta cuando el modelo empieza a valer
algo.**

#### Cómo lo maneja la industria

| | Cómo se dice un enlace de varias columnas |
|---|---|
| **R2RML** (W3C) | N × `rr:joinCondition`, cada una con `rr:child` y `rr:parent`: el enlace **es un conjunto de pares** |
| **Apollo Federation** | `@key(fields: "a b")` — la identidad es un conjunto de campos, y una entidad puede declarar varias claves |
| **dbt · MetricFlow** | las entidades SON las aristas; una `natural` es *"columnas o combinaciones de columnas"*, y `expr` permite derivar la clave |
| **Palantir Foundry** | el enlace referencia **una** propiedad clave; lo compuesto se resuelve materializando una clave única |
| **Cube · LookML** | SQL arbitrario (`sql_on`): no es una postura, es delegar en el motor |

Dos campos, y **solo uno nos sirve**:

- **Derivar una clave única** (Foundry, `expr` de dbt) **no está disponible aquí**:
  `expression` es documental en v1alpha1 y `Rule` se retiró, así que OOS no puede
  computarla. Y hay una objeción más de fondo: una clave concatenada es **un valor que nadie
  almacena**. Inventar una identidad es justo lo que este proyecto no hace.
- **SQL arbitrario** queda excluido dos veces: por [`02-entity`](../spec/v1alpha1/02-entity.md)
  §1.1 —una entidad no sabe de columnas— y por el invariante III, porque comprobarlo exigiría
  un analizador de SQL dentro de un compilador que es puro.

Queda el **enlace plural**, y ese es el sentido de la propuesta.

#### La forma propuesta, y por qué no es la de R2RML

`via` pasa a ser una **secuencia**, emparejada posición a posición contra la `primaryKey`
del `target`:

```yaml
  relations:
    cliente:
      target: ventas.Clientes      # primaryKey: [id, cod_pais]
      cardinality: many_to_one
      via: [id_cliente, cod_pais]  # ← se empareja en orden
```

R2RML nombra **los dos lados** porque no sabe cuál es la clave del padre. **OOS sí lo
sabe**: `target` declara su `primaryKey`, así que escribir el lado del padre sería declarar
lo derivable y violaría P2. Es la misma razón por la que `one_to_many` no existe.

#### Cómo se cerró, y qué límite queda escrito

- **`via` es una secuencia siempre**, también para una sola propiedad. No se admitió el
  escalar como atajo: obligaría a la forma canónica a normalizarlo, y de la forma canónica
  cuelga el digest. `via` entra en la lista de **secuencias** de N4 — si entrara como
  conjunto, la normalización la ordenaría y el enlace uniría por otros pares con el
  documento viéndose igual.
- **`OOS3006`** comprueba aridad y tipos posición a posición. Es un código propio porque no
  es `OOS2005` —todo resuelve— ni `OOS3005` —la cardinalidad es coherente—: lo que falla es
  que el enlace une de menos.
- **`OOS3005` se reescribió**: `one_to_one` exige que `via` **contenga** una clave declarada.
  Contener, no estar contenida. La redacción anterior aceptaba `via: [id]` contra
  `primaryKey: [id, país]`, que no identifica nada.
- **`OOS5027`** en `ore diff`. Es el cambio que un consumidor no puede ver venir: el campo se
  llama igual, devuelve el mismo tipo, el SDL emitido no cambia ni una letra, y devuelve
  otras filas.
- **El límite que queda, dicho en voz alta.** La transposición —`via: [codPais, id]` contra
  `primaryKey: [id, codPais]`— se caza **por tipos**, así que se caza cuando los tipos
  difieren y **no cuando no**. Con dos `String` el compilador no la ve. Está escrito en el
  módulo que la comprueba, porque una regla con una excepción no anunciada es peor que una
  que declara su límite.
- **A qué clave apunta — y aquí me equivoqué al cerrar.** Se empareja contra la
  `primaryKey` del destino y solo contra ella, así que una foránea contra un `uniqueKeys`
  no se puede decir. Lo escribí como *«raro incluso en sistemas heredados»* **sin medirlo**,
  y medirlo lo desmiente: SQL exige que una foránea referencie una PK **o una UNIQUE**, y
  referenciar por clave natural —el NIF, el DUNS, el código de artículo— es justo como los
  sistemas heredados enlazan. Un `CREATE TABLE ... REFERENCES clientes (nif)` se acepta sin
  protestar en PostgreSQL; está comprobado, no supuesto.

  Y tiene una consecuencia peor que no poder decirlo: hoy `discover` emitiría
  `via: [nifCliente]` contra un destino cuya `primaryKey` es `[id]`, la aridad casaría, los
  tipos también si ambos son `String`, y **saldría verde estando mal**. Queda reabierto en
  **§7.1** con una forma propuesta: un `toKey` opcional que nombre la clave del destino
  cuando no sea la primaria — omitirlo significa la primaria, que es lo derivable (P2).

#### Y la escala, que es la pregunta de fondo

Lo que **ya está resuelto** y conviene no volver a discutir:

- **Una entidad, N bindings.** El `Binding` lleva `targetEntity` y `datasourceRef`, y nada
  limita cuántos apuntan a la misma entidad — comprobado ejecutándolo: dos bindings al mismo
  `targetEntity` no producen error. **Ese es el enfoque centralizado, y ya existe**: el
  significado se declara una vez, los sitios físicos son cientos.
- **Dos problemas distintos, ya separados.** `Resolution` une **la misma** entidad entre
  fuentes —el cliente que es `SF-4471` en Salesforce y `0001234` en SAP—; `relations` une
  entidades **distintas**. Confundirlos es el error clásico de las capas semánticas, y el
  vocabulario ya no lo permite.

Con eso escrito, la conclusión es acotada: **para cientos de fuentes no falta un mecanismo
nuevo. Falta que el que hay admita la forma de las claves que esas fuentes tienen de
verdad.**

---

### 7.2 · Bloquean la primera venta enterprise

| | |
|---|---|
| **Modelo de amenaza** | ORE custodia credenciales de todas las fuentes: **es por diseño el objetivo de mayor valor de la infraestructura del cliente**. Vault, K8s Secrets, solo-lectura por defecto, aislamiento entre datasources — documentado *antes* del primer security review |
| **Observabilidad y log de política** | Formato, retención, inmutabilidad |
| **El Control Plane en el scaffolding** | `--with-ai-suggestions` envía metadatos al vendor. *"Solo metadatos"* no sobrevive a una revisión: el esquema de una BD clínica es sensible sin una sola fila. Tres modos —`ai: local` · `ai: byo` · `ai: managed`— y un principio: **el defecto debe ser el más privado que siga funcionando** |

### 7.3 · Implementación

| | |
|---|---|
| **Almacén de lo materializado** | **Cerrado, y la respuesta es que no hace falta ninguno.** La topología es un artefacto inmutable que se mapea, igual que el plano de contexto; la carga útil es una tabla Iceberg en el lago del cliente, que es lo que hacen Dremio y Trino. ORE no opera ninguna base de datos. `ore/docs/decisions/0006` |
| **`ore report` — la cobertura, como informe** | El dato ya se computa: `cobertura_efectiva()` está expuesto para el diff y `alcance()` se imprime al validar. Lo que falta es emitirlo como **propiedad × clase exigida × qué regla la descarga**, que es el artefacto que un equipo de cumplimiento pide de verdad — el *compliance status report* de GitLab es fila por (objetivo, control) y existe porque es lo que se pide. **Va después del `pendiente` con ventana**, no antes: hoy el informe tendría dos estados y el honesto tiene tres, así que construirlo ahora haría que *«nadie lo ejecutó»* y *«no hay nada»* se pintasen igual — el mismo defecto que el informe existe para destapar, un piso más arriba (`v1alpha3/02-ruleset` §9) |
| **Perfilado consciente de PII** | Sobre columnas marcadas: solo ratio de nulos y cardinalidad. Nunca min/max, histogramas ni muestras |
| **`ore refactor`** | Renombrar un concepto usado en 200 sitios debe ser un comando. Sin él, un modelo grande se congela |
| **Ficheros generados** | Dos personas ejecutando `discover` producen conflictos en ficheros que ninguna escribió: orden determinista y marcadores de región |
| **Colisión de identificadores** | `first.name` y `first_name` normalizan al mismo identifier. `discover` debe detectarlo y llevarlo a `review` |

### 7.4 · Estratégicas

| | |
|---|---|
| **Marca del namespace** | `node-ecosystems` para un motor Rust manda la señal equivocada. Decidir antes de publicar artefactos |
| **Qué NO se construye** | Foundry entrega apps operativas. *"Somos la capa semántica, tus apps las construyes con lo que ya usas"* es mejor respuesta que un intento a medias — pero hay que decirla en voz alta |
| **`Test`** | El único que queda de la lista original. `Function` y `Resolution` cierran alcance en v1alpha2 —y `Function` arrastra el **endoso de integridad** que desbloquea la IA agéntica: `humanApproval`, que es lo que permite que un agente prepare y proponga mientras un humano firma—; `Rule` se **retiró** como documento |

### 7.5 · Cerradas

Open core · lenguaje de autorización (**Cedar** + obligaciones cerradas) · YAML como
superficie de autoría · componer con Ossie y ODCS · arranque en frío (`discover` + `review`)
· deriva de esquema (`drift-detect --auto-pr`) · temporalidad y unidades · declarado vs.
computado · fijación de perfiles en el lockfile · superficie de servicio (MCP + GraphQL +
nativo) · caché frente a cero-copia · **selector del binding**
(`03-binding` §3.5) · **enlace compuesto** (§7.1-bis) · nombre (**OOS**,
decidido).
