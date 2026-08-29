# acme-global — documento de visión

> **Esto no es una ontología conforme.** No valida contra OOS v1alpha1 y no
> pretende hacerlo. Es el argumento de hacia dónde va la especificación
> después de v1alpha1, escrito como ontología para poder discutirlo en
> concreto en lugar de en abstracto.
>
> Las ontologías de referencia conformes viven en `examples/`, y CI exige que
> validen. Este documento está fuera de `examples/` deliberadamente.

## Qué de esto es v1alpha1 y qué no

| Construcción | Estado |
|---|---|
| `Entity`, `Binding`, `Package`, `Lattice`, `ConduitPolicy`, `OntologyConfig` | **v1alpha1.** Ver `examples/acme-retail` |
| `Resolution`, `Policy`, `Relation`, `RelationSet`, `RuleSet`, `Function`, `TestSuite` | **No existen.** v1alpha1 fija cinco documentos, ni uno más: las políticas son Cedar y las reglas están aplazadas |
| `spec.identity`, `spec.temporality`, `spec.governedBy`, `spec.complianceFrameworks`, `spec.entities`, `metadata.status` | Vocabulario **pre-especificación**, anterior a que los tres perfiles se fijaran |

Cada fila de la segunda categoría es material para el **P7**: si alguna de esas
construcciones entra en una versión futura, tendrá que traer escrita la
justificación de por qué no puede absorberse en ODCS, Ossie o SHACL.

## Qué comandos existen hoy

`ore validate`, `ore compile`, `ore diff` y `ore export`.

`ore lint`, `ore test`, `ore plan`, `--sign` y `--attest` **no están
implementados** y no forman parte de v1alpha1. Donde este documento los
menciona, es hoja de ruta.

```
acme-global/
├── ontology.config.yaml        # manifiesto: datasources, defaults, identidad, serving
├── ontology.lock               # resolución determinista de dependencias
├── CODEOWNERS                  # gobierno: seguridad aprueba toda política
├── .github/workflows/          # el ciclo de vida en CI
└── packages/
    ├── customers/              # Salesforce + PostgreSQL, unificados
    ├── supply_chain/           # Snowflake, 800M filas, ninguna copiada
    └── people/                 # Workday, bitemporal, PII sin materializar
```

---

## Los siete puntos que este ejemplo argumenta

Marcados uno a uno, porque «demostrar» sería falso para cinco de ellos: descansan sobre
documentos que v1alpha1 no define. **v1alpha1** = expresable hoy, con la ortografía de
`examples/acme-retail`. **Hoja de ruta** = el argumento se sostiene, la construcción no
existe.

### 1 · Bitemporalidad — ⚠️ parcial

> **v1alpha1 en el fondo, hoja de ruta en la forma.** Los dos ejes existen, escritos
> `temporal.validTime` y `temporal.transactionTime` (`02-entity` §7). El bloque
> `temporality: { mode, systemTime }` de abajo es vocabulario pre-especificación, y
> «está testeado» es hoja de ruta: `kind: TestSuite` no existe.

Un salario no es un número: es una función del tiempo. Y hay **dos ejes**, no uno:

```yaml
temporality:
  mode: bitemporal
  validTime:  { from: effectiveFrom, to: effectiveTo }   # cuándo fue cierto
  systemTime: { recorded: recordedAt }                   # cuándo lo supimos
```

Una subida aprobada en marzo con efecto desde enero tiene `validFrom = enero` y
`recordedAt = marzo`. Un informe *"a fecha de febrero"* no debe verla; un informe *"según
lo que sabíamos en abril"* sí. Es el caso que rompe todos los sistemas de nómina, y aquí
está testeado en `tests/compensation.test.yaml`.

### 2 · Dinero con contrato — 🔭 hoja de ruta

> v1alpha1 tiene unidad y precisión en el tipo —`Money<EUR, 2>`— que es lo que evita el
> error silencioso del redondeo. **La divisa por propiedad y la política de FX no
> existen.**

```yaml
baseSalary:
  type: Money
  currency: { property: currency }
  fx: { policy: as_of_valid_time, source: finance.FxRate }
```

`amount: Money` no significa nada sin divisa, tipo de cambio y fecha. Convertir con el FX
de hoy en lugar del de la fecha de vigencia es un error **silencioso**: no falla, solo da
cifras incorrectas. Aquí es explícito y está testeado.

### 3 · Política sobre la topología del grafo — 🔭 hoja de ruta

> **`kind: Policy` no existe: las políticas son Cedar** (`00-overview` §4.1), y las
> relaciones se declaran dentro de la entidad (`02-entity` §6), no en documentos
> `Relation`/`RelationSet` sueltos.

```yaml
- id: management-chain
  effect: ALLOW
  when: graph.reachable(from: subject.employeeId, to: resource.employeeId,
                        via: "people.reportsTo", maxDepth: 5)
  properties: [baseSalary, currency, effectiveFrom]
```

*"Puedes ver el salario de quien esté por debajo de ti en la jerarquía, hasta cinco
niveles"* **no es escribible en un RLS de PostgreSQL.** Depende de la forma del grafo, no
de una columna. Y el motor lo aplica en un único punto: una aplicación no puede saltárselo
olvidándose de filtrar.

Un manager ve `baseSalary`. No ve `bonusTarget`. Eso es RRHH.

### 4 · Resolución de identidad como código — 🔭 hoja de ruta

> **`kind: Resolution` no existe.** v1alpha1 llega hasta `uniqueKeys`, que es lo que hace
> posible el caso determinista; el probabilístico está aplazado entero.

El mismo cliente es `SF-4471` en Salesforce y `0001234` en el ERP.

- **Determinista** (NIF, DUNS): un join sobre clave natural. Encaja nativamente en el
  índice de topología.
- **Probabilística** (similitud de nombre y dirección): exige leer valores reales, y por
  tanto declara `materialization: cache` **y** `approvedBy: @acme/security`. No puede
  activarse por descuido.

En Foundry esto vive dentro de un pipeline y es una caja negra. Aquí tiene umbral
declarado, `precision >= 0.99` verificada en CI contra un golden set, y `FLAG_FOR_REVIEW`
en caso de ambigüedad. Cuando alguien pregunte por qué el sistema fusionó dos empresas,
hay respuesta.

### 5 · Materialización declarada — ✅ v1alpha1

Los tres modos, en los tres paquetes.

> Éste sí. `materialization.mode` vive en el `Binding` y el análisis de flujo lo comprueba
> en L0, sin red y sin credenciales. Está en verde en `examples/acme-retail`.

| Paquete | Modo | Por qué |
|---|---|---|
| `people` | `passthrough` | PII. No se almacena nada, ni siquiera topología. `cache` aquí es **error de compilación**. |
| `supply_chain` | `index` | 800M envíos. Se copian ~1.200M **aristas** (~40 GB de topología) y ni una fila de carga útil. |
| `customers` | `index` | Travesía `Customer → Order → Product` sin tres joins federados encadenados. |

> **Qué se copia es, en sí mismo, Ontology-as-Code.** El cambio se ve en el diff de un PR
> y `CODEOWNERS` obliga a que lo apruebe seguridad. En cualquier otro sistema del mundo
> la configuración de caché es un ajuste de infraestructura que ningún auditor mira.

### 6 · Superficie de acción gobernada — 🔭 hoja de ruta

> **`kind: Function` no existe.** Es el documento que más lejos queda: exige un modelo de
> ejecución, no solo de descripción.

```yaml
authorization:
  requireHumanApproval:
    when: target.totalAmount > 50000 || subject.kind == "agent"
transaction:
  scope: single-datasource      # honestidad: no prometemos lo que no podemos cumplir
idempotency:
  key: "{purchaseOrderId}:{subject.id}"
```

**El agente no recibe credenciales de PostgreSQL. Recibe un contrato**: precondiciones
verificadas por el motor antes de ejecutar, sandbox WASM sin red, efectos declarados,
idempotencia y auditoría a siete años. Es la diferencia entre un piloto de solo lectura y
un despliegue que un CISO aprueba.

### 7 · Conocimiento que no existe en ninguna tabla — 🔭 hoja de ruta

> **`kind: RuleSet` no existe.** `02-entity` §1.4 aplaza métricas, agregados y reglas de
> calidad a un `Rule` que v1alpha1 no define: son cómputo, no estructura.

```yaml
- id: concentration-risk
  produces: supply_chain.Supplier.isConcentrationRisk
  expr: exists(graph.out(entity, via: "supply_chain.supplies")
          .where(p => count(graph.in(p, via: "supply_chain.supplies")) == 1))
```

*"¿Qué proveedores son punto único de fallo?"* hoy son semanas de análisis manual entre
Snowflake, el ERP y una hoja de cálculo. Aquí es una travesía de dos saltos.

Y la arista `orderContains` cruza de `supply_chain` a `customers`: **una interrupción de
suministro se traduce a clientes afectados.** El ERP no sabe nada del CRM; la ontología sí.

---

## Lo que el CI hace en cada pull request — 🔭 hoja de ruta

> De la secuencia de abajo existen hoy `ore validate` y `ore diff`. `ore lint`, `ore test`,
> `ore plan`, `--sign` y `attest` no están implementados.

```bash
ore validate   # ¿cumple OOS?
ore lint       # ¿consistentes tipos, reglas y SHACL?
ore test       # inferencia + bitemporalidad + divisa + POLÍTICAS
ore diff --breaking --base origin/main
ore plan
ore compile --sign && ore attest dist/bundle.oob
```

Todo esto **sin red y sin una sola credencial**. La plataforma recibe el veredicto y el
digest; nunca la fuente.

El único job que toca producción es `drift-detect`, que corre de noche en un runner
dentro de la VPC y **abre un pull request** si el DBA renombró una columna.

Y cada PR levanta su propio ORE de vista previa: tres definiciones competidoras de
*cliente en riesgo* pueden estar vivas a la vez en tres ramas, cada una con sus tests,
comparables lado a lado antes de decidir cuál se mergea.

---

## Notas de lectura

> Donde estas notas dicen «está testeado», es hoja de ruta: `kind: TestSuite` no existe en
> v1alpha1. `status` y `complianceFrameworks` son vocabulario pre-especificación; la
> madurez que sí existe se escribe como etiqueta de retículo, `oos.maturity`.

- **Se declara lo que un humano decide** (`complianceFrameworks`, `classification`,
  `status`, umbrales). **Se computa lo que se puede derivar** (linaje, `riskScore`,
  `isExecutive`, `lifetimeValue`). No hay un solo bloque `lineage:` escrito a mano en
  todo el repositorio: un linaje declarado es documentación, y la documentación miente.
- **Ningún secreto en Git.** `datasources` declara qué fuentes existen y de qué variable
  de entorno sale la conexión. Por eso este repositorio es publicable tal cual — y por eso
  lo estás leyendo.
- **`status` tiene consecuencias.** `serving.mcp.expose: [STABLE]`: los agentes en
  producción no alcanzan borradores. Está testeado.
