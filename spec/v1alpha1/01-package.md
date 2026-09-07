# 01 · Package — perfil de ODCS

**Estado:** normativo. Parte de OOS v1alpha1.
**Anfitrión:** Open Data Contract Standard v3.1.0 (Bitol, Linux Foundation).
**Esquema:** [`schemas/v1alpha1/package.schema.json`](../../schemas/v1alpha1/package.schema.json)

---

## 1. Naturaleza

`Package` es el manifiesto de un paquete ontológico: quién responde de él, en qué estado
está, con qué garantías y de qué depende.

No es un formato nuevo. Es un perfil de ODCS: una restricción de su superficie, más una
extensión justificada, más la traducción bidireccional que permite que un contrato ODCS
existente entre y salga.

> **Principio de producto: el perfil debe ser invisible.**
> Quien escribe este documento no necesita saber que ODCS existe.

### 1.1 · Dos superficies

Distinción que gobierna los tres perfiles y que conviene fijar aquí:

| | Qué es | Tamaño |
|---|---|---|
| **Superficie de autoría** | lo que un humano escribe y el compilador valida | **mínima, con forma OOS** |
| **Superficie de transporte** | lo que sobrevive la ida y vuelta | mayor, opaca, sin validar |

Un campo que existe en ODCS y no sirve al propósito de OOS **no entra en la superficie de
autoría**: se transporta literalmente y no se valida. De ahí sale la regla operativa:

> **Se tipa lo que el compilador comprueba. Lo demás es transporte.**

---

## 2. Restricción

De las once secciones de ODCS, este perfil usa cinco.

| Sección ODCS | En el perfil |
|---|---|
| Fundamentals | **obligatoria** → `metadata` |
| Team · Roles · Support · SLA | opcionales → `spec` |
| Schema | **excluida** → [`02-entity`](02-entity.md) |
| Infrastructures & Servers | **excluida** → [`03-binding`](03-binding.md) |
| Data Quality | **excluida** → `quality` de ODCS, readmitida en v1alpha2 |
| References · Pricing · Custom Properties | transportadas sin interpretar |

### 2.1 · Fundamentals, campo por campo

| Campo ODCS | ODCS | OOS | Nota |
|---|:---:|:---:|---|
| `apiVersion` | obligatorio | — | OOS declara el suyo; se genera en emisión |
| `kind` | obligatorio | — | ídem: `DataContract` en emisión |
| `id` | **obligatorio** | *derivado* | §2.2 |
| `name` | opcional | **obligatorio** | un paquete sin nombre no puede ser referenciado por otro, y las dependencias son el mecanismo central del sistema |
| `version` | obligatorio | **obligatorio** | **DEBE** ser semver 2.0.0 |
| `status` | obligatorio | **obligatorio** | §2.3 |
| `domain` | opcional | **obligatorio** | es la unidad de propiedad y de radio de impacto |
| `tenant` · `tags` | opcional | absorbido | sin interpretar |
| `description` | opcional | absorbido | objeto `{purpose, limitations, usage}`, no cadena |
| `dataProduct` · `slaDefaultElement` | obsoletos | fuera | transportados |
| `contractCreatedTs` | opcional | **nunca se escribe** | §2.4 |

Restringir lo que el anfitrión deja opcional es legítimo y es a lo que un perfil sirve.

### 2.2 · `id` — divergencia consciente

ODCS exige un identificador estable para que renombrar no rompa referencias.

En OOS **no se escribe a mano**: si se omite, se deriva de forma determinista del nombre
cualificado (UUIDv5), de modo que emitir a ODCS produzca siempre el mismo identificador
sin que la compilación deje de ser pura (invariante III). Solo aparece explícito al
importar un contrato existente, donde **DEBE** conservarse literalmente para no romper a
sus consumidores.

La respuesta de OOS al mismo problema son `moved` y `reserved`, que además dicen en qué se
convirtió cada nombre y por qué. **Es un enfoque distinto con sus contrapartidas, no una
mejora estricta:** un consumidor que siguiera por id sobreviviría a un renombrado sin hacer
nada; uno que sigue por nombre necesita leer el `moved`.

### 2.3 · `status` — se adopta su vocabulario

Valores: `proposed`, `draft`, `active`, `deprecated`, `retired`.

Se adopta el enum de ODCS **verbatim** en lugar de inventar uno propio, para que la
emisión no pierda nada. El nivel del retículo `oos.maturity` se **deriva**:

| `status` | `oos.maturity` |
|---|---|
| `proposed` · `draft` | `DRAFT` |
| `active` | `STABLE` |
| `deprecated` · `retired` | `DEPRECATED` |

Ese nivel es el **valor por defecto** de las entidades del paquete que no declaren el suyo.
Una entidad **PUEDE** declarar cualquier nivel, por encima o por debajo: un paquete
`active` admite perfectamente una entidad nueva en `DRAFT`, que es como se añaden cosas.

`REVIEWED` no tiene equivalente en ODCS y no lo necesita: es un estado de **entidad**, y a
ese nivel OOS no está perfilando nada.

### 2.4 · Sin reloj

`contractCreatedTs` **NO DEBE** escribirse nunca. El invariante III prohíbe el reloj en la
compilación: un artefacto con marca de tiempo no sería reproducible. Si viene en un
contrato importado, se conserva literalmente.

---

## 3. Extensión

**Dos, y la segunda llega con v1alpha8.** Que un perfil necesitara una sola extensión durante
siete versiones es la señal de que está bien cortado; que la segunda aparezca al hacerse el
paquete direccionable desde otro paquete dice de qué es la extensión, y no del corte.

### 3.1 · `dependencies`

```yaml
dependencies:
  - { package: oos.dev/regulatory/gdpr, version: "^2.1" }
```

**Justificación (P7).** Ni ODCS ni Apache Ossie tienen mecanismo de dependencia entre
artefactos: un contrato ODCS no referencia a otro contrato ODCS. Sin este campo son
imposibles el retículo importable, el perfil de conector, la ontología sectorial y el
registry.

Y lo que hace no es reutilizar código: **es transferir autoridad.** Declarar `gdpr@^2.1`
es afirmar que la definición de dato personal no es tuya, y acogerte a un enunciado
concreto y auditable de esa autoridad. Criterio: *si la respuesta a «¿quién decide si esto
es correcto?» no es «nosotros», es una dependencia.*

Requisitos: rango semver · resolución determinista fijada en `ontology.lock` · un ciclo
**DEBE** rechazarse (`OOS2002`) · la resolución **PUEDE** no estar implementada en
v1alpha1, pero el campo **DEBE** existir en la gramática para que activarla después no sea
un cambio rompedor.

### 3.2 · `exports` — lo público, y llega con v1alpha8

```yaml
spec:
  owner: team:rrhh
  exports: [hr.empleados]
```

> **`exports` declara lo que este paquete deja usar a OTRO. Es visibilidad, no membresía.**

#### Por qué no es la lista de lo que hay dentro

La primera formulación pedía que el manifiesto dijera **de qué se compone** el paquete, como el
*data model* de Cognite lista sus `views`. Medido sobre el corpus, eso ya lo dice el directorio, y
redeclararlo sería declarar lo derivable —**P2**—.

Lo que **no** está escrito en ninguna parte del árbol es otra cosa: *«esto lo expongo a
propósito»*. Se comprobó con tres reglas candidatas, y la que parecía derivarlo —*público = lo que
nadie del paquete usa*— publicaba **catorce documentos de casos inválidos**: desde dentro del
paquete, algo publicado y algo muerto se ven igual. No es que derivar la lista sea caro; es que
**la información no existe**.

Por eso el nombre es el de Java —`module-info` · `exports`— y el de Node —`package.json` ·
`"exports"`—, que declaran visibilidad, y no el de Cognite, que declara membresía.

#### Normativo

- Cada nombre **DEBE** resolver a un documento de **este** paquete — `OOS2027`. Lo de una
  dependencia lo exporta ella; aquí se declara `dependencies`.
- Una referencia de otro paquete a algo que este no exporta **NO DEBE** compilar — `OOS2028`. Y
  **no es `OOS2018`**: el nombre existe, y decir *«no existe»* manda a mirar el fichero
  equivocado.
- **Ausente significa NADA, no todo.** Es P4, la misma regla con la que un conducto no listado no
  autoriza y `reads` ausente es una negativa. Java exporta nada sin `exports`; Rust es privado por
  defecto; dbt es `protected`. El único con defecto abierto es Node, y lo documenta como
  compatibilidad hacia atrás.
- **Sin versión**, a diferencia de `dependencies`: se nombra lo propio, y `packageRef` lleva
  versión *«porque es la única referencia que cruza el límite del artefacto»*.
- `OOS2028` se aplica **solo a documentos que declaran v1alpha8 o posterior**. Un documento
  anterior se escribió cuando un paquete no tenía superficie pública, y aplicárselo cambiaría lo
  que significa algo ya escrito. Es el mismo razonamiento —y la misma puerta— que `OOS2022`.

#### Y dónde vive, que no es una preferencia

En `package.yaml` y no en el manifiesto del *workspace*: `ontology.config.yaml` **no viaja dentro
del `.oob`**, y la declaración existe justo para que la lea quien consume el paquete.

No toca el digest más de lo que lo toca cualquier contenido: nombra documentos por su nombre
cualificado, no por su ruta, así que la equivalencia de disposición de
[`90-canonical-form`](90-canonical-form.md) §5.2 se conserva — las dos disposiciones del mismo
paquete siguen convergiendo con la lista puesta.

---

### 3.4 · `moved` y `reserved` — el nombre de un documento

```yaml
spec:
  moved:
    - { from: hr.iberia, to: hr.iberica, since: 2.0.0 }
  reserved:
    - { name: hr.antigua, reason: se fusionó en hr.empleados }
```

> El manifiesto **PUEDE** declarar `moved` y `reserved` sobre **nombres cualificados de documento**
> de su propio paquete. Reutilizar uno reservado es `OOS2006`; un documento que desaparece
> anunciado **no** es `OOS5007`.

#### Por qué aquí, y no en el documento que se queda

Es la misma disciplina que la entidad tiene sobre sus propiedades y la vista sobre sus campos, y la
regla que elige la casa es una:

> ### Lo dice el que sobrevive. Si no sobrevive nadie, lo dice el paquete.

Un `moved` de documento **sí** tendría superviviente —el que se queda con el nombre nuevo, que es
la forma de los `aliases` de Avro—. **`reserved` no**: un nombre retirado para siempre no deja
documento donde vivir. Y los dos son un mecanismo —`ore diff` los une, y `OOS5001` no distingue de
cuál vino un nombre—, así que partirlos en dos casas sería peor que cualquiera de las dos.

De paso resuelve lo que la forma de Avro no puede: que un nombre **se mude de paquete**. El que lo
pierde puede decir a dónde fue; el que lo recibe no le sirve a quien solo tiene al primero.

#### Y esto completa una decisión de §2.2, no abre una nueva

[§2.2](#22--id--divergencia-consciente) ya eligió, frente al `id` estable de ODCS:

> *«un consumidor que siguiera por id sobreviviría a un renombrado sin hacer nada; **uno que sigue
> por nombre necesita leer el `moved`**.»*

La decisión estaba tomada y razonada. Lo que faltaba es que, **para un documento, no había ningún
`moved` que leer**: `Entity.spec.moved` nombra `identifier`, no `qualifiedName`, así que renombrar
un documento se leía como una supresión —y en una `Table`, como nada—. Terraform, la fuente que
§2.2 cita, renombra precisamente **direcciones de recurso**: teníamos media importación.

#### Lo que NO comprueba

Lo mismo que en la entidad: ni que `from` haya dejado de existir, ni que `to` exista. `moved` no se
comprueba en el enlazado — alimenta a `ore diff`. Y `to` **NO** admite todavía nombrar otro
paquete: el tipo lo permitiría, la regla no, y se dice para que el día que se abra sea una decisión
y no un descuido.

---

### 3.5 · La pertenencia — `OOS2030`

> Un documento que vive **dentro del directorio de un paquete** DEBE declarar como `namespace`
> el nombre de ese paquete.

La pertenencia la dice el directorio —§3.3— y la identidad la dice `metadata.namespace`, que es
con lo que `backedBy`, `from` y `exports` se refieren a todo. **Hasta aquí nada ataba las dos**, y
las dos mitades de la pinza se ven en un ejemplo: un documento en `packages/ventas` llamado
`otro.E` compilaba limpio, y ese mismo paquete declarando `exports: [ventas.E]` fallaba con
`OOS2027` — porque `exports` habla en nombre cualificado y el documento se llama otra cosa.

La consecuencia es que *«mover un documento a otro paquete»* no tenía un significado único: eran
dos cosas —el fichero y el nombre— que se movían por separado sin que nada protestara.

#### Alcanza al contenido gobernado, no al vocabulario compartido

`Entity`, `View`, `Table`, `Function` y `Resolution` son contenido que alguien **posee** y que se
mueve entre paquetes: su nombre es el del paquete.

`Lattice`, `Ruleset`, `Concept`, `Interface` y las políticas son **vocabulario compartido**: su
nombre es el del vocabulario y tiene que ser el mismo desde todos los paquetes, o deja de
compartirse. `gdpr.sensitivity` significa lo mismo en `hr` y en `crm`, y eso es justo la propiedad
que lo hace útil.

La distinción es por `kind` y **no por dónde esté el fichero**: en un árbol plano —con el
manifiesto en la raíz— todo está dentro del paquete, y no habría un «fuera» al que mover un
retículo.

#### Y un nombre de paquete no siempre puede ser un espacio de nombres

`packageName` admite puntos, guiones y barras —§2.1: el nombre **es también la coordenada con la
que otro lo importa**— y un `namespace` es un `identifier`, que no admite ninguno de los tres. Así
que hay nombres de paquete para los que esta regla es **insatisfacible**: un paquete llamado
`oos.dev` o `mi-paquete` **no puede contener contenido gobernado**.

No se arregla aflojando la regla —el `namespace` es lo que es—, se dice: ese paquete puede
contener vocabulario compartido, y para contenido gobernado hay que renombrarlo. El diagnóstico lo
explica en vez de pedir un `namespace` que el esquema rechazaría.

#### Ausente no es una forma de estar de acuerdo

Sin `namespace`, el nombre cualificado del documento no lleva el del paquete: `exports` no puede
nombrarlo y una referencia de fuera no lo alcanza. Es la misma regla, no una segunda.

#### Solo de v1alpha8 en adelante

El mismo razonamiento —y la misma puerta— que [`OOS2028`](#32--exports--lo-público-y-llega-con-v1alpha8):
un documento anterior se escribió cuando el `namespace` no significaba pertenencia, y aplicárselo
cambiaría lo que significa algo ya publicado.

---

### 3.6 · La lápida — `OOS2031`

Un paquete que se funde en otro **no tiene por qué desaparecer**, y no debe: se queda como
**lápida** —`status: retired`, sin documentos, y un `moved` de §3.4 por cada uno de los que se
fueron—. `moved.to` es un `qualifiedName` y **cruza de paquete**, así que el nombre viejo sigue
diciendo en qué se convirtió.

Se midió, con su control:

| cómo se deja el origen | qué dice `ore diff` |
|---|---|
| **lápida** | sin cambios · compatible en los cuatro ejes |
| vacío y retirado, **sin** el anuncio | `OOS5007` · rompedor en `CONSUMER` |
| el manifiesto **borrado** | `OOS5007` + `OOS5021` |

Y el estado no es vocabulario nuevo: §2.3 adopta el enum de ODCS verbatim, y `retired` es uno de
los cinco.

#### Lo que la lápida no cuenta, y por eso hay código

`ore diff` compara **dos versiones del mismo paquete**, así que la lápida le vale. A quien la
importa desde fuera no le decía nada: resolvía, compilaba, y nadie le contaba que lo que
importaba era una piedra con un nombre.

> Un paquete **NO DEBE** declarar en `dependencies` otro cuyo `status` sea `retired` — `OOS2031`.

Y el diagnóstico nombra el destino, porque la lápida lo sabe: su `moved` dice documento a
documento a dónde se fue cada uno.

La regla alcanza a lo que está **en el árbol**. Una dependencia de otro artefacto se resuelve por
el lock, y su estado es del registro: decirlo aquí exigiría red, y la compilación dejaría de ser
hermética.

---

### 3.7 · Lo que se consideró extender y no se extiende

Registro explícito, para que la disciplina de P7 sea auditable.

| Candidato | Resolución |
|---|---|
| `reviewers` | **No.** ODCS ya tiene `roles[].firstLevelApprovers` y `secondLevelApprovers`. La aplicación corresponde al control de versiones —`CODEOWNERS`—, no a la especificación |
| `lifecycle` | **No.** Es `status` |
| `contactChannels` | **No.** Es la sección Support |
| `sla.availability`, `sla.freshness` | **No se tipan.** OOS no las evalúa: viajan en `sla.properties` como `slaProperties` genéricas. Solo `breakingChangePolicy.noticePeriod` es normativo (`91-versioning` §6), y por eso es el único tipado |
| `owner` | **No es extensión**, es restricción más azúcar: ODCS lo expresa como miembro de `team` con `role: Owner`. OOS exige **exactamente uno** y lo escribe como handle `team:` o `user:`, que es lo que se alinea con `CODEOWNERS`. La emisión traduce |

---

## 4. Traducción

Un perfil que solo restringe es una limitación. **Uno que hace ida y vuelta es
interoperabilidad**, y esa es la razón de perfilar en lugar de inventar.

### 4.1 · Emisión — OOS → ODCS

Un `Package` conforme **DEBE** poder emitirse como contrato ODCS v3.1.0 válido:

- `apiVersion: v3.1.0`, `kind: DataContract`
- `id` derivado si no era explícito
- `owner` traducido: un `team:` se convierte en `team.name`; un `user:` en un miembro con
  `role: Owner`
- `sla.breakingChangePolicy` traducido a una `slaProperty`; `sla.properties` emitidas tal
  cual
- `dependencies` bajo `customProperties`:

```yaml
customProperties:
  - property: x-oos-dependencies
    value: [{ package: oos.dev/regulatory/gdpr, version: "^2.1" }]
```

### 4.2 · Importación — ODCS → OOS

Todo contrato ODCS v3.1.0 válido **DEBE** poder importarse:

- `x-oos-dependencies` se restaura si viene; si no, el paquete no tiene dependencias.
- `id` se conserva literalmente.
- Si falta `name` o `domain` —opcionales en ODCS, obligatorios aquí— el paquete entra en
  `DRAFT` y el campo se marca como decisión pendiente. **NO DEBE** inventarse.
- Las `slaProperties` no reconocidas van a `sla.properties`.

### 4.3 · Fidelidad

La ida y vuelta **DEBE** ser sin pérdida. Las secciones fuera del perfil —References,
Pricing, Custom Properties no reconocidas, `contractCreatedTs`— **DEBEN** conservarse
literalmente y **NO DEBEN** interpretarse ni validarse.

---

## 5. Errores

| Código | Condición |
|---|---|
| `OOS1004` | el documento no valida contra `package.schema.json` |
| `OOS1005` | clave desconocida sin prefijo de extensión `x-` |
| `OOS2002` | ciclo en el grafo de dependencias |
| `OOS2007` | `version` no es semver válido |
| `OOS2008` | `status` fuera del vocabulario de ODCS |
| `OOS2009` | `owner` ausente o mal formado |
| `OOS2027` | `exports` nombra algo que el paquete no contiene |
| `OOS2028` | una referencia cruza a un paquete que no la exporta |
| `OOS5021` | la versión declarada no corresponde a los cambios detectados |
| `OOS5022` | cambio rompedor sin el periodo de aviso que exige `sla.breakingChangePolicy` |
