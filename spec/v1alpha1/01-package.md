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

**Una sola.** Que un perfil necesite una sola extensión es la mejor señal de que está bien
cortado.

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

### 3.2 · Lo que se consideró extender y no se extiende

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
| `OOS5021` | la versión declarada no corresponde a los cambios detectados |
| `OOS5022` | cambio rompedor sin el periodo de aviso que exige `sla.breakingChangePolicy` |
