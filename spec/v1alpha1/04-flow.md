# 04 · Etiquetas, conductos y flujo

**Estado:** normativo. Parte de OOS v1alpha1.
**Sustituye a** el borrador previo `04-classification.md`.

---

## 1. Alcance

Este documento define el **sistema de flujo de información** de OOS: el único mecanismo
por el que se comprueba, en tiempo de compilación y sin acceso a datos, que un paquete no
expone información por encima de lo autorizado.

La clasificación de datos es **una instancia** de este sistema, no el sistema.

---

## 2. Tres primitivas

Todo el vocabulario de gobernanza de OOS se expresa con tres conceptos. No hay un cuarto.

| Primitiva | Qué es |
|---|---|
| **Etiqueta** | un valor de un **retículo**, adherido a una propiedad. Se propaga por derivación. |
| **Conducto** | cualquier lugar por el que la información sale de su origen. Tiene una **autorización**: la etiqueta máxima que admite. |
| **Desclasificador** | una transformación que **baja** la etiqueta de la información que lo atraviesa. Su uso **DEBE** estar autorizado. |

Y una sola regla:

> **REGLA DE FLUJO.** La información con etiqueta `L` **NO DEBE** alcanzar un conducto con
> autorización `C` salvo que `L ⊑ C`, o que atraviese un desclasificador autorizado que
> produzca `L' ⊑ C`.

Todo error de la familia `OOS4xxx` es una violación de esa regla. No hay más.

---

## 3. Retículos

Un **retículo** (`kind: Lattice`) declara un conjunto de etiquetas y su orden parcial.

```yaml
apiVersion: oos.dev/v1alpha1
kind: Lattice
metadata:
  name: sensitivity
spec:
  levels: [none, low, medium, high, critical]   # secuencia: orden ascendente
  join: max                                      # cómo se combinan dos etiquetas
```

Requisitos normativos:

- `levels` **DEBE** ser una secuencia; su orden **ES** el orden parcial.
- El retículo **DEBE** tener un elemento mínimo (`⊥`) y uno máximo (`⊤`).
- `join` **DEBE** definir la combinación de dos etiquetas. En v1alpha1 el único valor
  admitido es `max`: **la derivación de varias entradas toma la etiqueta más restrictiva
  de todas.**

### 3.1 · Propagación

La propagación es **computada, nunca declarada** (principio P2).

Para toda propiedad derivada `d` con orígenes `s₁…sₙ`:

```
etiqueta(d) = join( etiqueta(s₁), … , etiqueta(sₙ) )
```

Una implementación **NO DEBE** permitir que una propiedad derivada declare una etiqueta
distinta de la computada, salvo mediante un desclasificador explícito (§5).

### 3.2 · Retículos estándar de v1alpha1

Dos, y ambos usan la misma maquinaria:

| Retículo | Etiquetas | Qué restringe |
|---|---|---|
| `sensitivity` | `none ⊑ low ⊑ medium ⊑ high ⊑ critical` | quién y qué destino pueden recibir el dato |
| `maturity` | `STABLE ⊑ REVIEWED ⊑ DRAFT ⊑ DEPRECATED` | qué consumidores pueden depender de la definición |

> Que la madurez sea un retículo y no un caso especial es deliberado. **`ore promote` es
> un desclasificador**: baja la etiqueta `DRAFT` a `REVIEWED` mediante una autorización
> humana registrada en un commit. Es exactamente la misma operación que enmascarar un
> campo, aplicada a otra dimensión.

> **Por qué `STABLE` es el fondo y no el techo.** El orden de todo retículo es ascendente
> **por restrictividad**, no por progresión del ciclo de vida, y en madurez las dos van en
> sentidos contrarios: lo estable es lo que puede servirse a cualquiera, y un borrador es
> lo que no puede salir. Se sigue de que `promote` sea un desclasificador —desclasificar es
> **bajar**, luego `STABLE ⊑ REVIEWED ⊑ DRAFT`— y es lo que hace expresable el caso normal:
> un `contextSurface` que sirve lo estable y rechaza el borrador. Con el orden inverso,
> `cache` admitiría un borrador y `contextSurface` rechazaría lo estable.

Un paquete **PUEDE** declarar retículos adicionales —residencia de datos, control de
exportación, nivel de habilitación— sin que la especificación ni el motor cambien. **El
análisis de flujo es genérico sobre retículos.**

---

## 4. Conductos

Un **conducto** es cualquier salida de información. OOS v1alpha1 define estos:

| Conducto | Aparece en | Ejemplo de autorización |
|---|---|---|
| `materialization` | `Binding` — modos `index` y `cache` | qué puede escribirse en disco |
| `datasource` | capacidades de `Function` | qué fuentes puede tocar una función |
| `export` | `ore export` | qué puede salir del paquete |
| `contextSurface` | superficie servida a consumidores (MCP, GraphQL, SDK) | qué puede ver un agente |
| `log` | traza de decisiones y observabilidad | qué puede escribirse en un log |

```yaml
kind: ConduitPolicy
spec:
  conduits:
    cache:          { sensitivity: low,    maturity: STABLE }
    contextSurface: { sensitivity: medium, maturity: REVIEWED }
    log:            { sensitivity: none,   maturity: DEPRECATED }
```

Un conducto sin autorización declarada **DEBE** tratarse como `⊥`: no admite nada
(principio P4, denegación por defecto). Lo mismo aplica a un retículo omitido dentro de un
conducto que sí está declarado.

Toda referencia a un conducto **DEBE** tener la forma `<clase>.<instancia>`, incluidas las
clases que parecen singleton: puede haber más de un log —auditoría y depuración— con
autorizaciones distintas.

### 4.1 · Combinación de varias políticas

Un repositorio **PUEDE** tener varias `ConduitPolicy`: típicamente una importada de un
paquete regulatorio y otra local.

Al combinarlas, la autorización efectiva de cada conducto **DEBE** ser la **más
restrictiva** de todas las declaradas — el *meet* del retículo, no el *join*.

> **Una política local nunca puede aflojar lo que una importada restringe.**

Sin esta regla, importar `gdpr` sería decorativo: bastaría declarar localmente un conducto
más permisivo para anularlo. Es la misma asimetría que hace que relajar la gobernanza sea
un cambio rompedor ([`91-versioning`](91-versioning.md) §4).

> **La unificación que esto produce:** los sumideros de datos y las capacidades de una
> función eran, en borradores anteriores, dos conceptos. Son el mismo: *un conducto con
> autorización*. La especificación pierde un concepto y no pierde ninguna capacidad.

---

## 5. Desclasificadores

Un desclasificador es la **única** forma legal de bajar una etiqueta. Es el vocabulario
cerrado de obligaciones, visto desde la teoría de flujo de información.

| Desclasificador | Efecto sobre la etiqueta | Justificación |
|---|---|---|
| `mask(FULL\|LAST4\|HASH)` | `critical`/`high` → `low` | el valor deja de identificar |
| `tokenize` | `high` → `low` | reversible solo con la bóveda |
| `redact` | cualquiera → `none` | el valor desaparece |
| `aggregate(minGroupSize: n)` | `high` → `low` si `n ≥ umbral` | k-anonimato: un agregado de ≥n sujetos no identifica a ninguno |
| `promote` | `DRAFT` → `REVIEWED` → `STABLE` | revisión humana registrada en un commit |

Requisitos normativos:

- El conjunto de desclasificadores es **cerrado**. Una implementación **NO DEBE** admitir
  desclasificadores definidos por el usuario. Un conjunto abierto sería incomprobable
  estáticamente e inauditable, y violaría el principio P3.
- Todo uso de un desclasificador **DEBE** estar autorizado por una política. La política
  decide *quién*, en qué contexto y con qué finalidad; el desclasificador define *qué le
  ocurre al dato*.

> `aggregate` merece atención: **es la razón formal por la que el k-anonimato funciona**,
> y es el desclasificador que hace utilizable a un agente sobre datos sensibles. Un agente
> puede conocer el salario medio de un departamento de cincuenta personas y no el de uno
> de dos, y eso es una propiedad demostrable en compilación, no una convención.

---

## 6. Taxonomías como paquetes importables

Un retículo y su `ConduitPolicy` **NO DEBEN** ser específicos de una empresa. Se declaran
en un paquete y se consumen como dependencia:

```yaml
# ontology.config.yaml
dependencies:
  - { package: oos.dev/regulatory/gdpr, version: "^2.1" }
  - { package: acme/internal-classification, version: "1.4.0" }
```

Consecuencias, y son grandes:

- Una **taxonomía regulatoria** —GDPR, HIPAA, PCI-DSS— se publica una vez y la consume
  todo el mundo. La consistencia entre organizaciones deja de depender de que cada una
  invente sus etiquetas.
- Un **perfil regulatorio** puede contener retículo, autorizaciones de conducto,
  plantillas de política y **tests de conformidad**. Importarlo hace que tu CI falle si tu
  ontología no satisface los requisitos estructurales derivables de esa norma.
  *Importar el cumplimiento como una dependencia.*
- La resolución es determinista vía `ontology.lock`, igual que cualquier otra dependencia.

**Restricción de v1alpha1:** la resolución de dependencias **PUEDE** no estar
implementada. Un retículo declarado localmente es el caso degenerado de un paquete sin
dependencias. Pero el campo `dependencies` **DEBE** existir en la gramática del manifiesto
desde v1alpha1, para que la migración no sea un cambio rompedor.

---

## 7. El criterio de importación

No hay cinco clases de paquete. **Hay un solo artefacto —el paquete ontológico— y puede
contener cualquier documento OOS.** Lo que varía es qué aporta, y eso lo declara el propio
paquete en `provides`.

Y hay un único criterio para decidir si algo debe vivir en tu repositorio o llegar como
dependencia:

> **Un paquete importable es la parte de tu ontología cuya autoridad está fuera de tu
> organización.**
>
> Prueba operativa: **¿quién decide si esto es correcto?**
> Si la respuesta no es *"nosotros"*, debe ser una dependencia.

| Lo que aporta | Quién tiene la autoridad |
|---|---|
| `Lattice`, `ConduitPolicy`, plantillas, tests de cumplimiento | un **regulador** decide qué es PII |
| `Binding` de objetos estándar, `capabilities` | un **fabricante** decide cómo es el modelo de Salesforce |
| tipos ISO 4217, ISO 3166 | un **organismo de normalización** |
| `Entity` y relaciones sectoriales | un **sector** decide qué es un *trade item* |
| tus entidades, tus políticas, tus conductos | **tú**, y por eso viven en tu repositorio |

### 7.1 · Consecuencia: el lockfile es un registro de autoridad delegada

Importar no es reutilizar código. **Es transferir autoridad**: al declarar
`gdpr@^2.1` estás diciendo que la definición de qué es un dato personal no es tuya, y que
te acoges a un enunciado concreto y auditable de esa autoridad.

Por eso `ontology.lock` fija versión **y digest**. Un auditor que lo lea no ve una lista
de dependencias:

> ve **de quién procede cada decisión que esta organización no tomó por sí misma**, con
> su versión exacta y su digest verificable.

Eso explica por qué `dependencies` resultó ser la única extensión que `Package` necesitaba
([`01-package`](01-package.md) §3): no es una comodidad de empaquetado. **Es el mecanismo
por el que una ontología declara lo que no decidió.**

---

## 8. Errores

| Código | Condición |
|---|---|
| `OOS4001` | violación de la regla de flujo por propagación |
| `OOS4002` | violación directa: propiedad etiquetada alcanza un conducto sin autorización |
| `OOS4003` | etiqueta no perteneciente a ningún retículo declarado o importado |
| `OOS4006` | desclasificador fuera del conjunto cerrado |
| `OOS4007` | `aggregate` sin `minGroupSize`, o por debajo del umbral del retículo |
| `OOS4008` | propiedad derivada que declara etiqueta distinta de la computada, sin desclasificador |
| `OOS4011` | conducto sin autorización declarada usado por un binding o una función |

`OOS4004` ("propiedad clasificada sin política que la cubra") **queda retirado**: era un
error de consistencia entre documentos que existía solo por una descomposición
incorrecta. Su número queda reservado (§9 de `99-errors.md`).

---

## 9. Lo que este documento colapsa

Cinco conceptos de borradores anteriores dejan de existir por separado:

| Antes | Ahora |
|---|---|
| taxonomía de clasificación | un `Lattice` |
| sumideros de datos | conductos |
| capacidades de función | conductos |
| ciclo de vida `DRAFT`/`STABLE` | un `Lattice`, y `promote` es un desclasificador |
| obligaciones de política | desclasificadores |

Tres primitivas, una regla, un mecanismo de comprobación. Añadir una dimensión de
gobernanza nueva —residencia, control de exportación— **no requiere cambiar la
especificación ni el motor**: requiere declarar un retículo.
