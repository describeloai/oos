# 91 · Versionado y compatibilidad

**Estado:** normativo. Parte de OOS v1alpha1.

---

## 1. Tres identidades distintas

La confusión habitual es creer que hay un número de versión. Hay tres, responden a
preguntas distintas y ninguna sustituye a las otras.

| Identidad | Quién la produce | Responde a |
|---|---|---|
| **Commit SHA** | Git | *¿es este el mismo **origen**?* |
| **Digest del bundle** | el compilador | *¿es este el mismo **artefacto**?* |
| **Versión semver del paquete** | un humano, verificado por `ore diff` | *¿puedo **usar este en lugar de aquel**?* |

Las dos primeras son **hechos**: se computan y son exactas. La tercera es un
**compromiso**: dice qué se le promete a quien consume.

---

## 2. Por qué Git no basta

Git versiona **bytes**. Eso da identidad, historia, culpa y reversión — y nada de ello es
compatibilidad.

**2.1 · Git no sabe qué significa un cambio.** `git diff` informa de que la línea 22 pasó
de `type: string` a `type: enum`. No informa de que eso estrecha el tipo y rompe a tres
consumidores. La diferencia entre *qué cambió* y *qué implica para ti* es exactamente el
hueco que esta especificación cubre.

**2.2 · Los commits no están ordenados.** Dados dos commits sin relación de ascendencia,
no hay forma de decir cuál es posterior ni cuál es compatible. Semver sí ordena, y por eso
`ontology.lock` puede escribir `version: "^2.1"`. No se puede escribir *"cualquier commit
compatible con `abc123`"*: no es una consulta que Git sepa responder.

**2.3 · El digest responde a otra pregunta.** El digest dice *si es el mismo*. Nunca dice
*si puedo sustituirlo*. Dos bundles con digests distintos pueden ser perfectamente
intercambiables; dos con el mismo digest lo son trivialmente. La sustituibilidad es una
relación entre versiones, no una propiedad de una.

**2.4 · Y lo importante:** en npm o en Cargo, la versión es **una afirmación humana que
puede ser falsa** — alguien sube un parche y rompe a medio ecosistema. Aquí no tiene por
qué serlo. Como la ontología es declarativa y sus consumidores están declarados, **el
carácter rompedor de un cambio se puede computar.**

> **Git versiona bytes. Semver versiona compromisos. `ore diff` es lo que traduce lo
> primero en lo segundo, y lo que convierte la versión de promesa en hecho comprobado.**

Precedente directo: Buf hace esto para Protobuf desde hace años. No es una idea nueva; es
una idea que nadie ha aplicado a la semántica de negocio.

---

## 3. Ejes de compatibilidad

Un cambio no es rompedor en abstracto: lo es **respecto a alguien**. Una implementación
conforme **DEBE** evaluar cada cambio contra los cuatro ejes por separado.

| Eje | Pregunta | A quién afecta |
|---|---|---|
| `CONSUMER` | ¿sigue siendo válida una consulta existente y sigue significando lo mismo? | aplicaciones, cuadros de mando, agentes |
| `POLICY` | ¿sigue la gobernanza siendo al menos igual de estricta? | seguridad, cumplimiento |
| `INDEX` | ¿sigue siendo válido el artefacto materializado o hay que reconstruirlo? | operación del runtime |
| `PACKAGE` | ¿sigue compilando un paquete que dependa de este? | otros equipos |

---

## 4. Las dos direcciones de la ruptura

Aquí está lo específico de una ontología, y no tiene equivalente en el versionado de
software convencional.

En una librería, **añadir capacidad es seguro** y quitarla es rompedor. En una ontología
gobernada hay **dos direcciones opuestas y ambas rompen**:

```
        ◀── restringir ──────────────────── relajar ──▶
        rompe al CONSUMIDOR                 rompe la GOBERNANZA
        (deja de poder leer)                (concede acceso en silencio)
```

**Relajar una política no rompe a ningún consumidor y es, sin embargo, el cambio más
peligroso que existe en este sistema.** Nadie recibe un error; simplemente más gente ve
más cosas. Un versionado que solo mire al consumidor lo dejaría pasar como
retrocompatible.

Por eso los cambios del eje `POLICY` **DEBEN** tratarse como rompedores **aunque amplíen
capacidades**, y **DEBEN** exigir revisión de los propietarios declarados en el paquete.

### 4.2 · Y una tercera clase que no tiene dirección: la **sustitución**

Las dos direcciones son movimientos en un **orden**, y por eso admiten espejo: cada dirección le
duele a otro, y una sola comparación elige a la vez el código y el eje. Es lo que hacen
`OOS5009`/`OOS5011` sobre una etiqueta, `OOS5012`/`OOS5026` sobre un conducto y
`OOS5028`/`OOS5029` sobre el recorte de una vista.

Hay una tercera clase que **no es un movimiento sino una sustitución de identidad**: cambiar
`primaryKey`, el `via` de una relación, la unidad de un tipo, el objeto del que salen las filas o
el sitio donde está la copia. No hay «más» ni «menos»: **cambió o no cambió**.

> **Una sustitución no tiene dirección, así que tiene UN eje — y el eje lo decide de quién era la
> identidad sustituida.** La que el consumidor nombra es `CONSUMER` —`OOS5006`, `OOS5010`,
> `OOS5027`—; la que produce el artefacto materializado es `INDEX` —`OOS5018`, `OOS5019`,
> `OOS5020`—.

Por eso ninguno de esos seis tiene espejo, y no es una omisión: **no hay nadie al otro lado.**

### 4.1 · El caso que demuestra que los ejes no son académicos

**Elevar** la etiqueta de una propiedad — de `high` a `critical`:

| Eje | Veredicto |
|---|---|
| `POLICY` | **compatible.** Es más estricto; la gobernanza mejora |
| `CONSUMER` | **rompedor.** Un consumidor que leía el valor ahora lo recibe enmascarado |

El mismo cambio, dos veredictos opuestos. Sin ejes separados habría que elegir uno y
mentir en el otro.

---

## 5. Taxonomía

Normativa. Una implementación conforme **DEBE** clasificar así.

### 5.1 · Rompedor en `CONSUMER`

| Cambio | Código |
|---|---|
| eliminar una propiedad sin `moved` ni `reserved` | `OOS5001` |
| estrechar un tipo (`string` → `enum`; retirar valores de un `enum`) | `OOS5002` |
| endurecer cardinalidad (`0..n` → `1..n`) | `OOS5003` |
| cambiar `primaryKey` | `OOS5006` |
| cambiar el `via` de una relación | `OOS5027` |
| eliminar una entidad o una relación | `OOS5007` |
| rebajar `oos.maturity` de una entidad `STABLE` | `OOS5008` |
| **elevar** la etiqueta de una propiedad | `OOS5009` |
| cambiar la unidad o la precisión de un tipo paramétrico | `OOS5010` |
| **rebajar** la autorización de un conducto | `OOS5026` |
| **estrechar el recorte de una vista** — sirve menos filas | `OOS5028` |

### 5.2 · Rompedor en `POLICY` — la dirección invertida

| Cambio | Código |
|---|---|
| **rebajar** la etiqueta de una propiedad | `OOS5011` |
| elevar la autorización de un conducto | `OOS5012` |
| añadir un `permit` que amplía el acceso efectivo | `OOS5013` |
| eliminar o debilitar un `forbid` | `OOS5014` |
| ampliar el conjunto de finalidades de una política | `OOS5015` |
| **aflojar un parámetro de seguridad** — `minGroupSize`, un umbral, una cota, un `quorum` | `OOS5016` |
| añadir un desclasificador donde no lo había | `OOS5017` |
| **ensanchar el recorte de una vista** — sirve filas que el contrato excluía | `OOS5029` |

### 5.3 · Rompedor en `INDEX`

| Cambio | Código |
|---|---|
| cambiar `primaryKey` o una clave de join materializada | `OOS5018` |
| cambiar **de qué objeto físico salen las filas** de una vista | `OOS5019` |
| cambiar **de dónde se leen** las filas de una vista — la copia aparece, se muda o desaparece | `OOS5020` |

> **`OOS5019` y `OOS5020` cambiaron de sujeto en v1alpha8, no de regla.** Se predicaban del
> `Binding`, que llevaba dentro `source` y `materialization`; al partirse en `Table` + `View`, el
> eje `INDEX` se quedó **sin sujeto** y los dos códigos siguieron vivos en el paradigma anterior y
> ciegos en este.
>
> Ahora se predican de la **vista**, y de su raíz **resuelta por la cadena**: repuntar la tabla de
> debajo y repuntar la vista son, para quien consume, el mismo hecho. Por lo mismo, `OOS5020` mira
> la *raíz de lectura* y no el `materialized` declarado — una vista que no se toca puede cambiar de
> sitio porque lo hizo la de abajo.

Los cambios de este eje **NO DEBEN** bloquear el merge por sí solos, pero una
implementación **DEBE** señalar que el índice requiere reconstrucción.

### 5.4 · Compatible

Añadir una propiedad opcional · añadir una entidad, relación o retículo · añadir un
`forbid` · declarar `moved` o `reserved` · elevar `oos.maturity` · cualquier cambio sobre
entidades en `DRAFT`.

> **«Endurecer un conducto» estuvo en esta lista y no debía.** Contradecía al §4 de este mismo
> documento —*restringir rompe al CONSUMIDOR*— y nadie lo notó porque, mientras ningún
> conducto tuvo consumidor, endurecerlo solo restringía materialización, exportación y log:
> operaciones internas, sin nadie al otro lado. La cuarta superficie de emisión le dio un
> consumidor a `contextSurface` y el error se volvió visible. Es `OOS5026`, y es el espejo de
> `OOS5012`: cada dirección de un conducto tiene ahora su código.

> Que **todo cambio sobre `DRAFT` sea compatible** es lo que permite tener miles de
> entidades en curso sin frenar a nadie. El compromiso empieza en `STABLE`, y empieza
> porque un humano ejecutó `ore promote`.

---

## 6. Consecuencias sobre la versión

Dado el conjunto de cambios entre dos versiones de un paquete:

| Si hay… | La versión **DEBE** subir |
|---|---|
| algún cambio rompedor en `CONSUMER`, `POLICY` o `PACKAGE` | **mayor** |
| solo cambios compatibles que añadan superficie | menor |
| solo correcciones sin cambio de superficie | parche |

`ore diff` **DEBE** fallar cuando la versión declarada no corresponda a los cambios
detectados (`OOS5021`). **La versión deja de ser una afirmación y pasa a ser una
comprobación.**

Y cuando el paquete declara `sla.breakingChangePolicy.noticePeriod`, un cambio rompedor
**DEBE** fallar salvo que la deprecación se hubiera anunciado con esa antelación —
`moved`, `reserved` o `DEPRECATED` con fecha.

---

## 7. Versionado de la especificación

`apiVersion: oos.dev/<versión>`, convención de Kubernetes.

| Fase | Garantía |
|---|---|
| `v1alpha1` | **PUEDE** romper en cualquier publicación. Sin garantías |
| `v1beta1` | los cambios rompedores **DEBEN** anunciarse con una versión de antelación |
| `v1` | **NO DEBEN** producirse cambios rompedores dentro de la versión mayor |

Los **perfiles** se versionan aparte y se fijan en `ontology.lock`: una publicación nueva
de Ossie o de ODCS no cambia el significado de un paquete ya compilado. Actualizar un
perfil es un cambio de esta especificación, sujeto a esta misma taxonomía.

---

## 8. Errores

`OOS5001`–`OOS5010` · ruptura en `CONSUMER`
`OOS5011`–`OOS5017` · ruptura en `POLICY`
`OOS5018`–`OOS5020` · invalidación de `INDEX`
`OOS5021` · la versión declarada no corresponde a los cambios detectados
`OOS5022` · cambio rompedor sin el periodo de aviso que exige el SLA del paquete

Registro completo en [`99-errors.md`](99-errors.md).
