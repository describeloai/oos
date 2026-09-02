# 99 · Registro de códigos de error

**Estado:** normativo. Parte de OOS v1alpha1.

---

## 1. Por qué los errores son parte de la especificación

Dos motivos, y ambos estructurales:

1. **La conformidad exige errores estables.** Un caso de `conformance/invalid/` afirma
   *qué* error se produce, no solo que algo falla. Sin códigos, dos implementaciones
   «conformes» podrían rechazar cosas distintas y nadie lo detectaría.
2. **El error es el producto.** La tesis del proyecto es que violar la gobernanza no
   compila. Un mensaje ilegible convierte esa garantía en una molestia. La familia
   `OOS4xxx` es la superficie más visible del sistema.

Una implementación conforme **DEBE** emitir el código exacto. **DEBERÍA** emitir además
ruta, línea y la cadena causal completa cuando el error sea de propagación.

**Este registro es la fuente autoritativa.** Un código citado en otro documento y ausente
de aquí es un defecto de este registro, no del otro documento.

---

## 2. Familias

| Rango | Familia | Fase | Suite |
|---|---|---|---|
| `OOS1xxx` | Sintaxis y esquema | análisis | `invalid/` |
| `OOS2xxx` | Referencias e integridad | enlazado | `invalid/` |
| `OOS3xxx` | Sistema de tipos | comprobación | `invalid/` |
| `OOS4xxx` | **Gobernanza y flujo de información** | comprobación | `invalid/` |
| `OOS5xxx` | Compatibilidad y cambios rompedores | `ore diff` | `diff/` |
| `OOS6xxx` | Forma canónica | serialización | `invalid/` |

### 2.1 · Precedencia

Un mismo fallo puede encajar en más de un código. La suite exige que **no se falle antes
con un código distinto del esperado**, así que la precedencia es normativa:

1. **El código más específico gana.** Una relación que apunta a una entidad inexistente es
   `OOS2005`, nunca una referencia genérica.
2. **Un código semántico gana sobre `OOS1004`, aunque el esquema JSON también detecte el
   fallo.** `entity.schema.json` sabe que falta `primaryKey`; solo `OOS2010` sabe *por qué
   importa* y puede sugerir `nature: event`.

La segunda no es cosmética. Si la tesis es que **el error es el producto**, dejar que gane
el genérico es rendirse en el único sitio donde se nota:

```
OOS1004: el documento no valida contra entity.schema.json
OOS2010: hr.AuditLog declara nature 'entity' y no tiene primaryKey.
         Un log de auditoría suele ser nature 'event' con timeKey.
```

---

## 3. `OOS1xxx` · Sintaxis y esquema

| Código | Condición |
|---|---|
| `OOS1001` | YAML mal formado |
| `OOS1002` | `apiVersion` ausente o no soportada |
| `OOS1003` | `kind` desconocido |
| `OOS1004` | el documento no valida contra su esquema JSON |
| `OOS1005` | clave desconocida sin prefijo de extensión `x-<proveedor>-` |

## 4. `OOS2xxx` · Referencias e integridad

| Código | Condición | Doc |
|---|---|---|
| `OOS2002` | ciclo en el grafo de dependencias | 01 §3.1 |
| `OOS2003` | elemento duplicado en un campo declarado como conjunto | 90 §N4 |
| `OOS2004` | `datasourceRef` no declarado en el manifiesto raíz | 03 §2.1 |
| `OOS2005` | referencia a una entidad, propiedad o etiqueta inexistente | 02 §10 |
| `OOS2006` | uso de un nombre declarado en `reserved` | 02 §8 |
| `OOS2007` | `version` no es semver 2.0.0 válido | 01 §2.1 |
| `OOS2008` | `status` fuera del vocabulario de ODCS | 01 §2.3 |
| `OOS2009` | `owner` ausente o mal formado | 01 §3.2 |
| `OOS2010` | `nature: entity` sin `primaryKey`, o `nature: event` sin `timeKey` | 02 §2 |
| `OOS2011` | el mapeo no cubre lo que necesita columna: clave, `via` o `payload` | 03 §2.1 |
| `OOS2014` | dos bindings del mismo objeto pueden reclamar la misma fila | 03 §3.5 |
| `OOS2015` | un filtro exigido —por `requiredFilters` o por un ámbito de fila— nombra una propiedad que el binding no mapea | 05 §5.3 |
| `OOS2012` | secreto de conexión presente en un documento | 03 §2.1 |
| `OOS2013` | artefacto generado desincronizado con su fuente — esquema Cedar u `ontology.lock` | 00 §5 |
| `OOS2016` | la firma de un paquete importado no verifica, o falta la que el lock afirma | v1alpha6 02 §5 |
| `OOS2017` | la prueba de transparencia de un paquete no verifica, o falta la que el lock afirma | v1alpha6 03 §5 |
| `OOS2018` | una vista, `backedBy`, un campo o un filtro nombran una vista o un campo que no existe | v1alpha7 01 §4 |
| `OOS2019` | la cadena de vistas vuelve sobre sí misma | v1alpha7 01 §4 |
| `OOS2020` | una vista cuya raíz de lectura no se deja leer —`reads: none`— no lleva `materialized` | v1alpha8 02 §5.1 |
| `OOS2021` | una vista materializada cuya raíz solo anexa —`changes.mode: append`— respalda una entidad `nature: entity` | v1alpha8 02 §5.2 |

## 5. `OOS3xxx` · Sistema de tipos

| Código | Condición | Doc |
|---|---|---|
| `OOS3001` | tipo fuera del conjunto del perfil | 02 §3 |
| `OOS3002` | `Money` o `Quantity` sin unidad o sin precisión | 02 §3.2 |
| `OOS3003` | `temporal` declarado sin `validTime` | 02 §7 |
| `OOS3004` | incompatibilidad de unidades en una derivación | 02 §5 |
| `OOS3005` | cardinalidad de relación incoherente con las claves declaradas | 02 §6 |
| `OOS3006` | el enlace no casa una clave declarada del destino: aridad, tipos o `toKey` | 02 §6 |

## 6. `OOS4xxx` · Gobernanza y flujo

**La familia que define el producto.** Todos son detectables herméticamente: sin red, sin
credenciales, sin tocar un solo dato.

| Código | Condición | Doc |
|---|---|---|
| `OOS4001` | violación de la regla de flujo **por propagación** | 04 §2 |
| `OOS4002` | violación **directa**: etiqueta por encima de la autorización del conducto | 04 §2 |
| `OOS4003` | etiqueta que no pertenece a ningún retículo declarado ni importado | 04 §3 |
| `OOS4005` | política que referencia una finalidad que `purposes` no declara | 06 §4 |
| `OOS4006` | desclasificador fuera del conjunto cerrado | 04 §5 |
| `OOS4007` | `aggregate` sin `minGroupSize`, o por debajo del umbral del retículo | 04 §5 |
| `OOS4008` | propiedad derivada que declara etiqueta en lugar de computarla | 02 §5 |
| `OOS4011` | conducto sin autorización declarada, usado por un binding o una función | 04 §4 |
| `OOS4012` | propiedad que rebaja la etiqueta heredada de su entidad | 02 §4.1 |
| `OOS4014` | `examples` no marcados como sintéticos en propiedad etiquetada por encima de `⊥` | 02 §4.2 |

### Ejemplo de mensaje para `OOS4001`

El formato no es normativo; **la cadena causal sí lo es**.

```
error[OOS4001]: flujo de información no autorizado

  hr.Employee.salary  ──derivación──▶  hr.netComp  ──binding──▶  materialization.payload

  etiqueta del origen      : gdpr.sensitivity = critical   (declarada)
  etiqueta de la derivada  : gdpr.sensitivity = critical   (computada, join)
  autorización del conducto: gdpr.sensitivity = low

  → declarado en   packages/hr/entities/Employee.yaml:22
  → propagado por  packages/hr/entities/Employee.yaml:31
  → alcanza        packages/hr/bindings/warehouse.yaml:12

  ayuda: baja el modo a `passthrough`, aplica un desclasificador autorizado
         (`mask`, `aggregate`), o eleva la autorización del conducto en
         conduits.yaml — lo último requiere revisión de CODEOWNERS.
```

## 7. `OOS5xxx` · Compatibilidad

Clasificados por **eje** ([`91-versioning`](91-versioning.md) §3). Un cambio se evalúa
contra los cuatro por separado, y **puede ser compatible en uno y rompedor en otro**.

### Eje `CONSUMER` — restringir

| Código | Condición |
|---|---|
| `OOS5001` | eliminar una propiedad sin `moved` ni `reserved` |
| `OOS5002` | estrechar un tipo, o retirar valores de un `enum` |
| `OOS5003` | endurecer cardinalidad |
| `OOS5006` | cambiar `primaryKey` |
| `OOS5027` | cambiar el `via` de una relación |
| `OOS5007` | eliminar una entidad o una relación |
| `OOS5008` | rebajar `oos.maturity` de una entidad `STABLE` |
| `OOS5009` | **elevar** la etiqueta de una propiedad |
| `OOS5010` | cambiar la unidad o la precisión de un tipo paramétrico |
| `OOS5026` | **rebajar** la autorización de un conducto |

### Eje `POLICY` — relajar

La dirección invertida: no rompe a ningún consumidor y **concede acceso en silencio**.

| Código | Condición |
|---|---|
| `OOS5011` | **rebajar** la etiqueta de una propiedad |
| `OOS5012` | elevar la autorización de un conducto |
| `OOS5013` | añadir un `permit` que amplía el acceso efectivo |
| `OOS5014` | eliminar o debilitar un `forbid` |
| `OOS5015` | ampliar el conjunto de finalidades de una política |
| `OOS5016` | **aflojar un parámetro de seguridad**: `minGroupSize` de un desclasificador `aggregate`, el umbral de una `Resolution`, la cota de una aserción, el `quorum` de un endoso |
| `OOS5017` | añadir un desclasificador donde no lo había |

### Eje `INDEX`

No bloquean el merge por sí solos, pero una implementación **DEBE** señalar que el índice
requiere reconstrucción.

| Código | Condición |
|---|---|
| `OOS5018` | cambiar `primaryKey` o una clave de join materializada |
| `OOS5019` | cambiar el binding físico de una propiedad indexada |
| `OOS5020` | cambiar el modo de materialización |

### Transversales

| Código | Condición |
|---|---|
| `OOS5021` | la versión declarada no corresponde a los cambios detectados |
| `OOS5022` | cambio rompedor sin el periodo de aviso que exige `sla.breakingChangePolicy` |

## 8. `OOS6xxx` · Forma canónica

| Código | Condición | Doc |
|---|---|---|
| `OOS6003` | pérdida de precisión: decimal significativo sin representación en cadena | 90 §4.1 |

> **No toda regla normativa se verifica rechazando algo.** La pureza de la compilación y la
> normalización Unicode son reglas reales que **ningún documento puede violar**: se
> verifican con casos `valid/` —el mismo paquete produce el mismo digest, dos entradas que
> difieren solo en composición Unicode producen la misma forma canónica— y no con códigos
> de error. Ver §9.

---

## 9. Números retirados y reservados

Un código, una vez publicado, **NO DEBE** reutilizarse con otro significado. Un código
retirado **DEBE** marcarse aquí y su número queda reservado para siempre.

Es la misma disciplina que `reserved` impone a los nombres de propiedad, aplicada a la
especificación misma.

| Código | Estado | Motivo |
|---|---|---|
| `OOS4004` | **retirado** | *«propiedad clasificada sin política que la cubra»*. Era un error de consistencia entre documentos que existía solo por una descomposición incorrecta, resuelta al unificar todo en el sistema de flujo |
| `OOS4005` | **REABIERTO** | Se retiró razonando que *«la comprobación corresponde al validador de Cedar»*. **Se midió, y Cedar no puede hacerla**: `context.purpose` es un `String`, y un validador comprueba el tipo, no el valor — `context.purpose == "compenstaion_review"` tipa perfectamente y no casa con nada. La premisa era falsa, así que el código vuelve, y ahora tiene contra qué comprobar: [`06-request`](06-request.md) declara `purposes`. Un código retirado por una razón que resulta falsa **se reabre**; lo que no se puede es reutilizar su número para otra cosa, y no se hace: significa exactamente lo mismo que significaba |
| `OOS4009` | **reservado** | capacidad solicitada por una función y no concedida. `Function` llega en v1alpha2 y sus errores son la familia `OOS7xxx`; sigue reservado porque el vocabulario de capacidades del sandbox no está escrito |
| `OOS4010` | **reservado** | acción invocable por agentes sin `requiresApproval` ni límite. En v1alpha2 eso es un **endosante** y la carencia la detecta `OOS7002`; sigue reservado por si el límite de invocación acaba siendo una condición propia |
| `OOS2001` | **reservado** | *«referencia a un nombre cualificado inexistente»*. Al poblar la suite se vio que **no es alcanzable**: toda referencia de v1alpha1 tiene código específico — entidad y propiedad (`OOS2005`), datasource (`OOS2004`), etiqueta (`OOS4003`). Se reserva porque `Function`, `Resolution` y `Test` introducen tipos de referencia nuevos |
| `OOS6001` | **retirado como código** | *«entrada no determinista en la compilación»*. Es una restricción sobre la **implementación**, no un defecto de un documento: ningún paquete puede contener un reloj. La regla sigue siendo normativa en `90-canonical-form` §2 y se verifica con casos `digest/`, comprobando que el mismo paquete produce el mismo digest |
| `OOS6002` | **retirado como código** | *«fallo de normalización Unicode»*. Sobre UTF-8 válido la normalización NFC no falla, y los identificadores de OOS son ASCII, así que no puede haber colisión tras normalizar. Se verifica como afirmación positiva: dos entradas que difieren solo en composición Unicode **deben** producir la misma forma canónica |
| `OOS4013` | **retirado** | *«`payload` sobre propiedad etiquetada sin desclasificador autorizado»*. Al escribir su caso de conformidad se vio que **no es una condición distinta de `OOS4002`**: si la etiqueta está por debajo de la autorización del conducto, cachear es legítimo y no hace falta desclasificar; si está por encima, ya lo cubre `OOS4002`. Además su premisa no existe: **no hay forma de declarar un desclasificador en tiempo de materialización** (ver la nota de v1alpha2 abajo). Una regla que no se puede convertir en un caso no es normativa |
| `OOS5004` | **retirado** | superado por `OOS5022`, que cubre cualquier cambio rompedor sin aviso, no solo el endurecimiento de una política |
| `OOS5005` | **retirado** | superado por `OOS5007` |

> **Hueco identificado para v1alpha2.** No existe forma de desclasificar **en tiempo de
> materialización**. Una obligación de política se evalúa por consulta y por sujeto; una
> materialización ocurre en la construcción del índice, sin sujeto. Cachear correos
> tokenizados para unir por ellos es un patrón real y hoy no se puede expresar: exigiría
> que `materialization.properties` admitiera un desclasificador por propiedad. Queda
> anotado, no improvisado.

---

## 10. Cobertura

**Cada código publicado exige al menos un caso de conformidad.** Un código sin caso no es
normativo: es una intención.

| Familia | Códigos activos | Directorio | Cubiertos |
|---|:---:|---|:---:|
| `OOS1xxx` | 5 | `invalid/` | **5 ✓** |
| `OOS2xxx` | 14 | `invalid/` | **14 ✓** |
| `OOS3xxx` | 6 | `invalid/` | **6 ✓** |
| `OOS4xxx` | 9 | `invalid/` | **9 ✓** |
| `OOS5xxx` | 22 | `diff/` | **22 ✓** |
| `OOS6xxx` | 1 | `invalid/` | **1 ✓** |
| **Total** | **57** | | **57 ✓** |

Y las reglas que **ningún documento puede violar** se verifican como afirmaciones
positivas, no con códigos: normalización canónica en `canonical/` (9 casos), reproducibilidad
del digest en `digest/` (8) e interoperabilidad en `emit/` (5).
