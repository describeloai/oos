# OOS · Open Ontology Specification

**Ontology-as-Code.**

> OOS convierte un repositorio de Git **descriptivo** en un paquete **portable, tipado y
> versionado**, cuya **gobernanza se demuestra al compilar** —sin red, sin credenciales y
> sin tocar un solo dato— y cuyo artefacto **ejecuta cualquier motor conforme**.

Apache-2.0 · `oos.dev/v1alpha1` · **borrador inestable, no implementar en producción**

<sub>*«Cualquier motor conforme» es una intención de diseño con evidencia —una suite de
conformidad normativa, identidad determinista, implementación de referencia sin
privilegios— y **no una prueba**. Se vuelve un hecho el día que una segunda implementación
independiente pasa la [suite](conformance/README.md).*</sub>

---

## El problema

Tu empresa ya sabe describir sus datos. Tiene catálogos, contratos de datos, capas
semánticas y diagramas. Lo que no tiene es una forma de **demostrar** que esa descripción
es cierta, ni de **ejecutarla**.

Las etiquetas de PII se ponen a mano y dejan de ser ciertas en seis meses. Las políticas
viven en una plataforma y no en el pull request que cambia el dato. El linaje se escribe
en Confluence. Y cuando un agente de IA pregunta, nadie puede decir con certeza qué tenía
permitido saber ni quién lo autorizó.

**El cuello de botella no es describir. Es que la descripción no obliga a nada.**

---

## Qué garantiza

Cinco promesas. Una implementación conforme las cumple todas o no es conforme.

| | Garantía |
|---|---|
| **G1** | **Identidad determinista.** El mismo commit produce el mismo digest, siempre y en cualquier máquina. |
| **G2** | **Gobernanza demostrada.** Si compila, ningún dato clasificado alcanza un sumidero no autorizado. No es una alerta: es que **no compila**. |
| **G3** | **Linaje que no miente.** El linaje lo produce el compilador. Nadie puede escribirlo a mano, así que nadie puede desincronizarlo. |
| **G4** | **Verificable sin acceso.** G1 y G2 se comprueban leyendo el repositorio. **Un auditor externo valida tu gobernanza sin que le concedas acceso a un solo dato.** |
| **G5** | **Portable.** El paquete se ejecuta sin su autor, sin su proveedor y sin ninguna plataforma. Cualquier motor conforme lo corre. |

---

## Las cuatro ideas de las que sale todo lo demás

Una especificación es elegante cuando un puñado de ideas genera el resto. Estas son las
cuatro:

**1 · La clasificación es un tipo, no una etiqueta.**
Y por tanto **se propaga**: si `netComp` se calcula desde `salary`, hereda su
clasificación sin que nadie lo escriba. Los destinos —caché, exportación, superficie de
agente, logs— tienen nivel de autorización. Un flujo cuesta arriba es un error de tipos.
→ *De aquí salen la propagación, los sumideros y toda la familia de errores `OOS4xxx`.*

**2 · La compilación es pura.**
`bundle = f(fuente@commit, versión OOS, lock)`. Sin red, sin credenciales, sin reloj, sin
aleatoriedad.
→ *De aquí salen el digest reproducible, la firma, la promoción del mismo artefacto entre
entornos, el rollback — y el hecho de que la comprobación de gobernanza no necesite datos.*

**3 · Lo derivado no se declara.**
Un campo que se puede computar **no puede** declararse. El linaje, la clasificación
propagada y el grafo de consumidores son salida, nunca entrada.
→ *De aquí sale que la documentación no pueda mentir, y que una política no pueda ser la
salida de un programa: si lo fuera, nadie podría revisarla en un pull request.*

**4 · El paquete se basta a sí mismo.**
Lleva dentro su contrato de ejecución completo: qué significa, dónde está, quién puede
verlo, qué se puede hacer y cómo se verifica.
→ *De aquí sale que no haya plataforma obligatoria, que el motor sea reemplazable y que
irse sea barato.*

Y dos disciplinas: **denegación por defecto** en toda capacidad, acceso y
materialización; y **componer antes que inventar**.

---

## Cómo se ve

Un retículo importado, un conducto, una etiqueta y una derivada:

```yaml
# lattices/ · importado de oos.dev/regulatory/gdpr
kind: Lattice
metadata: { name: sensitivity, namespace: gdpr }
spec: { levels: [none, low, medium, high, critical], join: max }
```

```yaml
# conduits.yaml · qué sale por dónde   ← revisado por @acme/security
kind: ConduitPolicy
spec:
  conduits:
    materialization.cache: { gdpr.sensitivity: low }
```

```yaml
# packages/hr/entities/Employee.yaml
properties:
  baseSalary: { type: Money<EUR,2>, labels: { gdpr.sensitivity: critical } }
  bonus:      { type: Money<EUR,2>, labels: { gdpr.sensitivity: critical } }

  totalCompensation:                        # sin etiqueta: el compilador la computa
    derivedFrom: [baseSalary, bonus]        # join(critical, critical) = critical
```

```yaml
# packages/hr/bindings/warehouse.yaml
materialization: { mode: cache }            # ← escribiría totalCompensation en disco
```

```console
$ ore compile

error[OOS4001]: flujo de información no autorizado

  hr.Employee.baseSalary  ──derivación──▶  totalCompensation  ──binding──▶  materialization.cache

  etiqueta del origen      : gdpr.sensitivity = critical   (declarada)
  etiqueta de la derivada  : gdpr.sensitivity = critical   (computada, join)
  autorización del conducto: gdpr.sensitivity = low

  → declarado en  packages/hr/entities/Employee.yaml:22
  → propagado a   packages/hr/entities/Employee.yaml:31
  → alcanza       packages/hr/bindings/warehouse.yaml:12

  ayuda: baja el modo a `passthrough`, aplica un desclasificador autorizado
         (`mask`, `aggregate`), o eleva la autorización del conducto en
         conduits.yaml — lo último requiere revisión de @acme/security.
```

Nadie clasificó `totalCompensation`. El compilador lo hizo, y por eso la etiqueta sigue
siendo cierta dentro de seis meses.

Sin conexión a la base de datos. Sin credenciales. Sin un solo dato leído.

---

## Qué **no** es OOS

| No es | Eso es |
|---|---|
| un vocabulario de modelado | **Apache Ossie** |
| un formato de contrato de datos | **ODCS / Bitol** |
| un lenguaje de autorización | **Cedar** |
| un lenguaje de restricciones | **SHACL** |
| una base de datos, un catálogo, un ETL o un lenguaje de consulta | otra cosa |
| una plataforma | ninguna hace falta |

> **Ossie y ODCS son vocabularios. OOS es un régimen.**
> Un vocabulario dice cómo nombrar las cosas. Un régimen dice qué debe ser cierto, quién
> lo comprueba y qué ocurre cuando no lo es.

OOS **absorbe** todo el modelo semántico y contractual de Ossie y ODCS. Lo que define
está sujeto al principio **P7**: todo campo que ya exista en otro estándar abierto y que
OOS redefina lleva justificación escrita, o es un defecto.

Lo que aporta son cuatro cosas, y solo la última son campos: un **régimen de identidad**,
un **modelo de compilación**, un **contrato de conformidad** y un **vocabulario de
gobernanza**.

---

## Niveles de conformidad

| Nivel | Qué hace | ¿Acceso a datos? |
|:---:|---|:---:|
| **L0** · Validador | valida, normaliza, comprueba el flujo, emite digest | **no** |
| **L1** · Servidor de contexto | entidades, relaciones, tipos, políticas, linaje | **no** |
| **L2** · Ejecutor | resuelve bindings, aplica obligaciones, federa consultas | sí |
| **L3** · Actor | ejecuta funciones y **verifica el acto que un endoso declara** | sí, con escritura |

**L0 es lo que hace de OOS un estándar.** Es hermético e implementable en cualquier
lenguaje en un fin de semana: una acción de CI, un linter de editor, un `pre-commit`.

La conformidad la decide la [suite](conformance/README.md), no una implementación.
**[ORE](https://github.com/describeloai/ore), la implementación de referencia, no tiene
ningún privilegio** y ejecuta la suite como un consumidor externo más.

---

## Estado

**Todas las versiones son `alpha`**, y eso significa exactamente lo que dice
[`00-overview` §6](spec/v1alpha1/00-overview.md): pueden romper compatibilidad en cualquier
publicación, sin garantías. El siguiente peldaño es `v1beta1` —la escalera no se salta— y
sus tres condiciones, con su estado medido, están en §6.1 del mismo documento.

**Promover no es una decisión: es una comprobación.**

Las tablas de abajo no llevan cuentas de casos. Cada borrador tiene su propio marcador y lo
imprime al correr la suite; una cifra copiada aquí envejece en silencio, y ya lo hizo: de las
cuatro que había, **tres estaban desfasadas** —la peor, por catorce casos.

```
spec/v1alpha1/     documentos normativos — y alpha: sin garantías
spec/v1alpha2/     alcance cerrado — los efectos y la derivación
spec/v1alpha3/     alcance cerrado — la capa de gobierno
spec/v1alpha4/     borrador de alcance — el significado
spec/v1alpha5/     borrador de alcance — la emisión a GraphQL
spec/v1alpha6/     borrador de alcance — la distribución
spec/v1alpha7/     borrador de alcance — la vista
spec/v1alpha8/     borrador de alcance — la tabla
schemas/v1alpha1/  JSON Schema publicado — generado
schemas/v1alpha3/  ruleset y lattice
schemas/v1alpha4/  property, interface, entity y ruleset
schemas/v1alpha7/  view, y entity con `backedBy`
schemas/v1alpha8/  table, view adelgazada, entity
conformance/       suite de conformidad — NORMATIVA
examples/          ontologías de referencia — validan con CERO diagnósticos
packages/          vocabulario publicable — se consume, no se copia
docs/              diseño y razonamiento — no normativo
docs/vision/       ontologías escritas contra el lenguaje completo — NO validan
```

`schemas/v1alpha5/` no existe, y no falta: esa versión no inventa gramática. **Un directorio
de esquemas es consecuencia de haber añadido un `kind`, no un requisito de tener versión.**


| | v1alpha1 · normativo |
|---|---|
| [`00-overview`](spec/v1alpha1/00-overview.md) · alcance, conformidad, principios, absorción | ✅ |
| [`01-package`](spec/v1alpha1/01-package.md) · el perfil de ODCS: quién responde y desde cuándo | ✅ |
| [`02-entity`](spec/v1alpha1/02-entity.md) · qué existe, y qué convierte a una entidad en principal | ✅ |
| [`03-binding`](spec/v1alpha1/03-binding.md) · dónde está el dato y qué se copia | ✅ · **histórico** desde v1alpha8 |
| [`04-flow`](spec/v1alpha1/04-flow.md) · retículos, conductos, desclasificadores | ✅ |
| [`05-ejecutor`](spec/v1alpha1/05-ejecutor.md) · qué puede hacer quien **sí** toca el dato | ✅ |
| [`06-request`](spec/v1alpha1/06-request.md) · qué entra con una petición, y quién responde | ✅ |
| [`90-canonical-form`](spec/v1alpha1/90-canonical-form.md) · normalización, JCS, digest | ✅ |
| [`91-versioning`](spec/v1alpha1/91-versioning.md) · los ejes de cambio y la compatibilidad | ✅ |
| [`99-errors`](spec/v1alpha1/99-errors.md) · registro de códigos | ✅ |
| [`schemas/v1alpha1/`](schemas/v1alpha1/) · JSON Schema publicado | ✅ generado |
| [`examples/acme-retail`](examples/acme-retail/README.md) | ✅ completo · en verde |
| [`docs/vision/acme-global`](docs/vision/acme-global/README.md) | 🔭 visión · no valida, y es correcto |

Esta tabla tenía tres de esos documentos marcados como ⬜ **siguiente** y dos como
pendientes. Se escribieron —y con ellos el ejecutor y la petición, que ni siquiera
figuraban— y nadie movió el marcador. La causa no es el descuido: **la casilla que planifica
y la que informa eran la misma**, y una casilla que hace las dos cosas deja de hacer la
segunda en cuanto se hace la primera. Lo que viene después de v1alpha1 se planifica en el
alcance de cada borrador, que es donde tiene dueño.

Alcance cerrado de v1alpha1: **seis documentos**. `Package` y `Binding` son **perfiles**
sobre ODCS; `Entity`, `Lattice`, `ConduitPolicy` y `RequestPolicy` son **gramática propia**
—Ossie es objetivo de emisión del bundle, no anfitrión de la entidad (`00-overview`
§7.2-bis)—. Las políticas siguen siendo **Cedar**, no un documento OOS: `RequestPolicy` no
autoriza nada, declara **de dónde vienen los atributos con los que Cedar decide**. Fue el
sexto y llegó el último, cuando el ejecutor puso un principal delante de un dato
([`00-overview` §4](spec/v1alpha1/00-overview.md)).

| | v1alpha2 · alcance cerrado, no normativo |
|---|---|
| [`00-scope`](spec/v1alpha2/00-scope.md) · alcance, la retirada de `Rule`, y lo que abre v1alpha3 | ✅ |
| [`01-efectos`](spec/v1alpha2/01-efectos.md) · el régimen: eje de integridad, endosante, la regla | ✅ |
| [`02-function`](spec/v1alpha2/02-function.md) · la superficie de escritura gobernada | ✅ |
| [`03-resolution`](spec/v1alpha2/03-resolution.md) · el efecto sobre la identidad | ✅ |
| [`04-expression`](spec/v1alpha2/04-expression.md) · la promoción de `expression` | ✅ |
| [`conformance/v1alpha2/`](conformance/v1alpha2/README.md) · borrador | ✅ **entero en verde** |

**v1alpha1 gobierna lo que se puede saber; v1alpha2, lo que se puede causar.** Añade los dos
verbos —`Function` y `Resolution`—, **una promoción** —`expression`, que pasa de prosa
documental a CEL comprobada— y la resolución de dependencias. `quality` de ODCS es el
**cuerpo** de una aserción y su **destino de emisión**, y no se escribe colgando de la
propiedad: eso sería una segunda superficie de autoría sin dueño propio. `Rule` se retiró como documento
([`00-scope`](spec/v1alpha2/00-scope.md) §3.1). Su suite vive en un árbol aparte y se cuenta
por separado, para que **la cuenta de v1alpha1 siga queriendo decir lo mismo** cuando este
directorio tenga cincuenta casos.

`Test` y lo temporal siguen aplazados.

**v1alpha3 abre la capa de gobierno** —[`spec/v1alpha3/`](spec/v1alpha3/00-scope.md), con
esquema y [su propia suite](conformance/v1alpha3/README.md) en un tercer árbol—, y no inventa el
plano: lo termina. v1alpha1 ya declaraba el vocabulario cerrado de obligaciones
y lo dejó sin sitio donde engancharse. Lo único que falta es **el objetivo**, y sale gratis:
*una etiqueta ya es un conjunto*. El retículo que v1alpha1 usa para comparar dos elementos
—`L ⊑ C`— nombra, leído al revés, el conjunto entero.

| | v1alpha4 · borrador de alcance, no normativo |
|---|---|
| [`00-scope`](spec/v1alpha4/00-scope.md) · alcance, la prueba de fuego y lo que encontró | ✅ |
| [`01-significado`](spec/v1alpha4/01-significado.md) · el régimen: el concepto, el mapeo, la forma | ✅ |
| [`02-property`](spec/v1alpha4/02-property.md) · el concepto: qué cabe en él y qué hereda quien lo referencia | ✅ |
| [`03-interface`](spec/v1alpha4/03-interface.md) · la forma: qué es satisfacerla y qué alcanza una regla | ✅ |
| [`conformance/v1alpha4/`](conformance/v1alpha4/README.md) · borrador | ✅ **entero en verde** |
| **listo para v1** | ✅ **12 de 12 estaciones** — [`00-scope`](spec/v1alpha4/00-scope.md) §8 |

**v1alpha4 gobierna qué es la misma cosa**, y no es la capa de encima: es **la que faltaba
debajo**. Toda la maquinaria de v1alpha1 y v1alpha3 opera sobre etiquetas y nada comprobaba
que la clasificación fuera consistente, porque no había forma de decir que dos propiedades
son la misma — *v1alpha3 gobierna lo que alguien acertó a etiquetar*. Un `Concept` es el
concepto, un `Interface` es la forma, y `is` hace hacia arriba lo que un `Binding` hace hacia
abajo. La herencia no se inventó: `OOS4012` sube un nivel **sin cambiar una letra**.

Los esquemas y la suite se escribieron **antes** que `02-property` y `03-interface`, y a
propósito: el alcance exige enfrentar el vocabulario a algo que lo use antes de cerrarlo.
Encontró tres defectos, uno de ellos **con cuatro versiones de antigüedad**
([`00-scope`](spec/v1alpha4/00-scope.md) §7.1). Los dos documentos se redactaron después, con
la implementación delante.

**Y ahora sí quiere decir terminado, en el sentido que el propio alcance define.** Un `kind`
atraviesa doce estaciones —despacho, forma, referencias, tipos, flujo, gobierno, significado,
forma canónica, sellado, compatibilidad, emisión y dependencia— y `Concept` e `Interface`
**las atraviesan las doce**, con un caso por tránsito. Ese criterio no existía: se escribió
midiendo, y midiendo salió que **v1alpha1 llegó al final y cada borrador posterior se quedó
antes sin decirlo**.

La fase 1 cerró la forma canónica —y destapó que `Lattice.requiresGovernance` llevaba **una
versión entera** siendo sensible al orden—. La fase 2 cerró la compatibilidad **con un solo
código nuevo de cinco**: retirar un concepto, cambiarle el tipo o mover su clasificación son
los códigos de v1alpha1 sin tocar, porque un concepto declara lo mismo que una propiedad. Y
la fase 3 cerró la emisión: una propiedad que solo declara `is` sale al contrato con el tipo,
la clasificación y el `enum` que hereda — idéntica a la misma propiedad escrita a mano, salvo
por la clave que permite **deshacer** la traducción. El criterio de «listo» **nunca había estado escrito** —por eso cada borrador
terminó en una estación distinta sin decirlo— y ahora lo está, con las cuatro fases que
faltan: [`00-scope`](spec/v1alpha4/00-scope.md) §8.

Y **no queda ninguna decisión abierta**. Las tres últimas se cerraron con teoría delante y
por el mismo criterio —*preguntar de qué clase de objeto se está hablando*—: una `Function`
**no** puede apuntar a una interfaz porque su garantía se compila donde se define y se invoca
en otra parte; un concepto **sí** puede exigir gobierno porque la regulación clasifica por
categoría y no por nivel; y la herencia entre interfaces **se computa**, porque un `Interface`
es una clase definida y su jerarquía es inferida por construcción
([`00-scope`](spec/v1alpha4/00-scope.md) §6). Ninguna añade un código nuevo.

| | v1alpha8 · borrador de alcance, no normativo |
|---|---|
| [`00-scope`](spec/v1alpha8/00-scope.md) · alcance, la dualidad como regla, y por qué el puntero físico no era de la vista | ✅ |
| [`01-table`](spec/v1alpha8/01-table.md) · qué es una tabla, sus **dos caras**, y las tres codificaciones del cambio | ✅ |
| [`02-view`](spec/v1alpha8/02-view.md) · la vista adelgazada, la raíz de lectura, y **las dos reglas nuevas** (§5) | ✅ |
| [`schemas/v1alpha8/`](schemas/v1alpha8/) · `table`, `view` sin `capabilities` ni `version`, `entity` | ✅ |
| [`conformance/v1alpha8/`](conformance/v1alpha8/README.md) · borrador | ✅ |
| **listo para v1** | ⏳ **la migración del árbol y el retiro** — [`00-scope`](spec/v1alpha8/00-scope.md) §5 |

| | v1alpha7 · borrador de alcance, no normativo |
|---|---|
| [`00-scope`](spec/v1alpha7/00-scope.md) · alcance, la tesis, y por qué la vista absorbe al binding | ✅ |
| [`01-view`](spec/v1alpha7/01-view.md) · qué es una vista, su forma, la cadena, y qué significa que esto esté listo (§9) | ✅ |
| [`schemas/v1alpha7/`](schemas/v1alpha7/) · `view`, y `entity` con `backedBy` | ✅ |
| [`conformance/v1alpha7/`](conformance/v1alpha7/README.md) · borrador | ✅ |
| **listo para v1** | ✅ **sustituida por v1alpha8**, que es su §9 ejecutado: el puntero físico sale de la vista y `Binding` se retira |

| | v1alpha6 · borrador de alcance, no normativo |
|---|---|
| [`00-scope`](spec/v1alpha6/00-scope.md) · alcance, la tesis, y por qué la distribución es lo último | ✅ |
| [`01-distribucion`](spec/v1alpha6/01-distribucion.md) · el formato `.oob`, el contrato de obtención, y qué significa que esto esté listo (§6) | ✅ |
| [`conformance/v1alpha6/`](conformance/v1alpha6/README.md) · borrador | ✅ el formato; los otros dos peldaños se ejecutan, no se declaran |
| **listo para v1** | ✅ **los tres peldaños** — [`01-distribucion`](spec/v1alpha6/01-distribucion.md) §6 |

| | v1alpha5 · borrador de alcance, no normativo |
|---|---|
| [`00-scope`](spec/v1alpha5/00-scope.md) · alcance, la tesis, y por qué GraphQL | ✅ |
| [`01-emision-graphql`](spec/v1alpha5/01-emision-graphql.md) · el mapeo normativo, y qué significa que esto esté listo (§6) | ✅ |
| [`conformance/v1alpha5/`](conformance/v1alpha5/README.md) · borrador | ✅ **entero en verde** |
| **listo para v1** | ✅ **los cuatro peldaños** — [`01-emision-graphql`](spec/v1alpha5/01-emision-graphql.md) §6 |

**v1alpha6 gobierna de quién es lo que usas.** Su regla se lee: *nada entra en una
compilación sin que su digest esté escrito en el lock*. Y de ahí sale la frase que decide el
diseño entero — **el registro no es de confianza**, y no hace falta que lo sea: un paquete se
identifica por lo que contiene, no por de dónde vino, así que un registro que sirviera otra
cosa produciría otro digest y la compilación se pararía. Lo único que puede hacer es **no
servirte**.

La decisión que cierra no era la evidente. **Un `.oob` no es un archivo comprimido**: uno
lleva marcas de tiempo, orden de entradas y nivel de compresión, así que el mismo paquete
daría bytes distintos y el digest dejaría de ser función del contenido. Un `.oob` es **la
forma canónica escrita en un fichero** — que ya es determinista y ya tiene digest desde
v1alpha1—, con dos consecuencias que valen por sí solas: **el contenedor no cambia la
identidad**, así que un lock resuelto contra un árbol sigue valiendo cuando ese paquete se
publique; y **no hay que extraerlo para verificarlo**, así que nadie escribe en disco algo que
todavía no ha comprobado.

Lo que **no** entra es tan importante: el registro como servicio, y **cómo una coordenada se
convierte en una URL**. Traer un paquete se delega en un programa del usuario, igual que se
delega leer una fuente, y por la misma razón — un compilador que resolviera nombres en la red
dejaría de ser una función del árbol de ficheros.

**v1alpha5 gobierna lo que se puede pedir**, y es la versión de menor radio del proyecto: no
añade ningún `kind`, ningún esquema y ningún código de error. Añade **un objetivo de
emisión** —GraphQL— y los casos que lo certifican. La emisión es aditiva por construcción:
nada de lo ya escrito cambia de significado porque exista un destino más. El único código que
su escritura hizo aparecer, `OOS5026`, **es de v1alpha1**: v1alpha5 no lo añadió — destapó
que la tabla de compatibilidad no tenía el espejo de `OOS5012` ([`91-versioning`](spec/v1alpha1/91-versioning.md) §158).

Lo que decide su diseño cabe en una frase: **la clasificación no se emite — se ejecuta al
emitir.** Un campo cuya etiqueta excede el techo de `contextSurface` no sale prohibido:
**sale ausente**. El consumidor no puede pedir lo que el contrato no declara, así que en el
momento de la petición no queda nada que aplicar — ya se aplicó al compilar. Es `G2` mirado
desde el otro lado: donde v1alpha1 dice *«ningún dato clasificado alcanza un conducto no
autorizado»*, esta versión dice **lo mismo desde la superficie de consumo**.

Y sus cuatro peldaños de *listo* no son fases: son propiedades independientes, cada una
medible sin las otras. Que un motor ajeno acepte el SDL **sin retocarlo** —lo comprueba
`graphql-js` en la CI de la implementación de referencia, no una aserción nuestra—; que bajar
el techo de un conducto borre **exactamente** el conjunto gobernado, ni una propiedad más ni
una menos; que dos ejecuciones den el mismo byte; y que `ore diff` clasifique un cambio del
esquema emitido **sin un solo código nuevo**. El cuarto es el que convierte los *schema
checks* que un registro comercial cobra aparte en algo que **se deriva de un commit**.

---

## Prototipo

El motor es **[ORE](https://github.com/describeloai/ore)** —Rust, Apache-2.0—, y vive en su
propio repositorio a propósito: **si la especificación no pudiera existir sin el motor, la
frase que la vende sería falsa por construcción del repositorio.** OOS entra ahí como
submódulo; nunca al revés.

El estado de cada fase se lee en su README y no aquí: duplicar un marcador garantiza que una
de las dos copias acabe mintiendo.

Ordenado por riesgo retirado, no por capas.

| Fase | Qué | Criterio de éxito |
|---|---|---|
| **0** · Esqueleto | esquemas, `ore validate`, `ore compile` | compila un paquete de ejemplo y emite digest estable |
| **1** · `source add` · `discover` · `review` | separar secreto de conexión, introspección, FK→relaciones, heurísticas PII con confianza, **y una cola interactiva de decisiones para lo dudoso** | apuntar a un esquema sucio de ~50 tablas y que un arquitecto diga *"está un 80% bien"* tras contestar cinco preguntas |

**El criterio de la fase 1 depende de v1alpha4, y conviene decir por qué.** *«Cinco
preguntas»* solo es formulable con un vocabulario controlado: sobre conceptos —*«¿esta columna
es un `personalEmail`?»*— se contestan cinco; sobre etiquetas —*«¿qué clasificación merece
esta columna?»*— son cinco ensayos. La especificación aporta **el molde**
([`spec/v1alpha4/`](spec/v1alpha4/00-scope.md)); esta fase es la herramienta que escribe
contra él, y sin el molde escribiría conjeturas.

Y la frontera al revés también: **cómo** se induce —qué se introspecciona, si hay un modelo
de por medio, cómo se pregunta— es de ORE y no de OOS. La especificación no dice cómo se
descubre; dice qué tiene que cumplir lo descubierto.
| **2** · La gobernanza que no compila | retículos, conductos, propagación por derivación, chequeo de flujo, Cedar embebido | `ore validate` falla con error legible y cadena causal ante PII que alcanza un conducto no autorizado |
| **3** · Consumo | `ore dev` + servidor MCP + obligaciones en lectura | un agente pregunta por MCP y el PII vuelve enmascarado sin haber hecho nada |

**Justo después del prototipo, y por delante de todo lo demás:** `dependencies` +
`ontology.lock` + **el primer perfil de conector**. No es comodidad de adopción — sin él,
`capabilities` es un campo que nadie rellena bien y la federación no funciona. Es
prerrequisito de la segunda fuente de datos, no un lujo posterior.

Detalle, estimaciones y qué queda fuera: [`docs/DESIGN.md` §7](docs/DESIGN.md) — decisiones abiertas.

---

## Diseño y razonamiento

**[docs/DESIGN.md](docs/DESIGN.md)** — documento único, no normativo. El *porqué* detrás de
cada decisión, y lo que queda fuera del alcance de la especificación:

| Sección | Contenido |
|---|---|
| 1 · Por qué existe | problema y tesis |
| 2 · El eje | los cuatro estados, las cinco piezas |
| 3 · ORE | tres caras, dos planos, GitOps, conectar una fuente, superficie de servicio |
| 4 · Materialización | la escalera de metadatos, por qué la topología |
| 5 · Posición | Foundry y SuperRepo, Ossie y ODCS, catálogos, cuellos de botella |
| 6 · Modelo de negocio | open core, mecánica de ingreso, licencia |
| 7 · Decisiones abiertas | lo que falta por cerrar |

**Reglas de trabajo:**

1. **`spec/` manda.** Si `DESIGN.md` la contradice, el defecto está en `DESIGN.md`.
2. **La suite de conformidad manda sobre `spec/`.** Si discrepan, el defecto está en el
   texto normativo.
3. **Sin duplicación.** Lo que define la especificación no se repite en `DESIGN.md`.
