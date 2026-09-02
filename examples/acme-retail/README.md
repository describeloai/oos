# acme-retail · ontología de referencia

Minorista europeo. Tres dominios con niveles de sensibilidad deliberadamente muy
distintos: **cadena de suministro** (nada sensible), **clientes** (sensibilidad media),
**compensación** (crítica).

Construida sobre OOS `v1alpha1`. Cada fichero está anotado con qué demuestra.

## El plano de gobierno, sobre esto mismo

Dos añadidos de **v1alpha3** —borrador— convierten esta ontología en la demostración de que
la clasificación tiene consecuencias:

| | |
|---|---|
| `lattices/gdpr.yaml` gana `requiresGovernance` | desde `high`, `constraint`; desde `critical`, además `authorization` |
| `rulesets/gdpr-minimization.yaml` | el paquete de reglas del equipo de cumplimiento, con **su propio `owner`** |

Un `Ruleset` con **un solo objetivo** —`atLeast: { gdpr.sensitivity: high }`— gobierna
**once propiedades** repartidas por tres paquetes. Y varias de ellas no llevan la etiqueta
escrita: `hr.Employee.employeeId` entra porque el `datasource` de RRHH declara un suelo
—*todo lo que sale de aquí es al menos `high`*— y la propagación lo lleva hasta el gobierno.

Bórralo y el paquete **deja de compilar con once errores**, uno por propiedad. Rebájalo a
`severity: warning` y ocurre exactamente lo mismo: un aviso no descarga la obligación de
gobernar.

Y es lo que separa esto de un cuadro de mando: la cobertura no es un porcentaje que alguien
mira una vez al mes — **es una condición de compilación.**

---

## Estructura

```
acme-retail/
├── ontology.config.yaml        manifiesto: fuentes, dependencias, retículos activos
├── lattices/residency.yaml     retículo propio de ACME
├── conduits.yaml               qué sale por dónde  ← revisado por @acme/security
├── policies/hr.cedar           políticas en Cedar, con obligaciones como anotaciones
└── packages/
    ├── hr/          Employee · Workday · crítico, eu_only, passthrough
    ├── customers/   Customer · CRM     · medio,   eu_only
    └── supply/      Shipment · ERP     · none,    global, materializado
```

---

## Qué demuestra cada pieza

| Pieza | Demuestra |
|---|---|
| `ontology.config.yaml` | dependencias importadas: taxonomía GDPR, tipos ISO, conectores. Secretos por `connectionEnv`, nunca en Git |
| `lattices/residency.yaml` | **añadir una dimensión de gobernanza sin tocar la especificación ni el motor** |
| `conduits.yaml` | sumideros y capacidades de función unificados en un solo concepto |
| `hr/entities/Employee.yaml` | las tres extensiones a Ossie: temporalidad, `Money<EUR,2>`, etiquetas como tipo. Más `moved`, `reserved` y una derivada con etiqueta **computada** |
| `hr/tables/workday.yaml` | el objeto registrado **una vez**, con sus dos caras: qué se le puede pedir y qué cambios emite |
| `hr/views/empleados.yaml` | qué se expone de él, y **las dos formas en que materializarlo fallaría** — con la traza completa |
| `supply/entities/Shipment.yaml` | **un dominio entero sin nada sensible**, a propósito |
| `supply/tables/snowflake.yaml` | una fuente que **sí sabe decir qué cambió**: `{retract, snapshot}`, y por eso lo suyo se mantiene incrementalmente |
| `supply/views/envios.yaml` | lo que la migración desde el binding **perdió**, dicho en vez de tapado |
| `customers/entities/Customer.yaml` | relación entre paquetes y una derivada que **no** hereda criticidad |
| `policies/hr.cedar` | Cedar como forma canónica, obligaciones como anotaciones, ReBAC por la jerarquía de managers |
| `hr/package.yaml` | perfil de ODCS: `owner`, `sla`, `support`, `status` — absorbido, no inventado |

---

## Las tres cosas que conviene mirar

### 1 · La etiqueta que nadie escribió

```yaml
totalCompensation:
  derivedFrom: [baseSalary, bonus]
```

No declara etiqueta. El compilador computa `join(critical, critical) = critical`.
Declararla a mano sería `OOS4008`.

Es la diferencia entre una etiqueta que sigue siendo cierta a los seis meses y una que
miente. En cualquier catálogo del mercado, `totalCompensation` acabaría sin clasificar
porque alguien olvidó ponérsela.

### 2 · El error que ocurre sin conexión

`hr/views/empleados.yaml` es virtual a propósito. Añadirle `materialized` produce:

```
error[OOS4011]: el conducto `materialization.payload` no tiene autorización declarada
```

porque este repositorio no lo declara, y un conducto que no se lista es ⊥: **omitirlo no es
dejarlo abierto, es cerrarlo**. Y declarándolo al nivel de los otros dos:

```
error[OOS4002]: `hr.empleados.baseSalary` lleva `gdpr.sensitivity:critical` (declarada)
                y `materialization.payload` solo admite `gdpr.sensitivity:medium`
```

La etiqueta la puso la **entidad**, dos capas más arriba, y baja hasta la vista por el nombre
del campo. La vista no lleva significado y aun así no puede copiarse.

Sin conexión a Workday. Sin credenciales. Sin haber leído el registro de un solo empleado.

**Un auditor externo puede verificarlo clonando este repositorio.**

### 3 · Que no todo es sensible

`supply/` no tiene una sola etiqueta que restrinja nada, y por eso lo suyo se materializa
sin objeción. Un ejemplo donde todo es crítico engañaría sobre lo que el sistema pide en
la práctica: **la mayor parte de una ontología empresarial no es sensible, y el sistema de
flujo no estorba donde no hace falta.**

### 4 · Lo que la migración a v1alpha8 **perdió**

`supply/bindings/snowflake.yaml` traía `delayDays` calculado por Snowflake con un
`DATEDIFF(...)`. Una vista **renombra y recorta, y no calcula**, así que ese campo no tiene
dónde ir: `supply.Shipment.delayDays` sigue siendo una propiedad derivada —conserva su
`derivedFrom`, que es lo que propaga las etiquetas— y deja de estar calculada en el origen.

Está aquí porque una migración que solo enumera lo que conserva promete que no se pierde
nada. No es una pérdida de v1alpha8: v1alpha7 ya la causó al absorber el binding en la
vista, y no se notó porque nada se había migrado todavía.

---

## Cómo se recorre

```bash
ore validate .          # L0 · hermético: esquema, referencias, flujo. Sin red.
ore compile .           # → bundle firmado con digest reproducible
ore dev . --mcp         # L2 · sirve el contexto gobernado por MCP
```

Un agente conectado por MCP que pregunte *"compensación media del departamento de
logística"* recibe la respuesta si el grupo tiene ocho personas o más, y un rechazo
explicable si no. No porque el agente se porte bien: porque el motor aplica
`aggregate:minGroupSize=8` y el agente no puede saltárselo.

---

## Aviso

Ontología de ejemplo. Los mapeos de Workday, Snowflake y GS1 son plausibles pero
ilustrativos, no verificados contra los esquemas reales de esos productos.
