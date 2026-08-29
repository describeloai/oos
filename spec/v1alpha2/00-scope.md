# OOS v1alpha2 — alcance

**Estado:** borrador de alcance. Ningún documento de esta carpeta es normativo todavía.
`spec/v1alpha1/` sigue mandando.

---

## 1. La tesis

v1alpha1 tiene un vocabulario de gobernanza completo y **habla de una sola cosa**:

| | |
|---|---|
| `Etiqueta` | qué es esto |
| `Conducto` | a dónde puede ir |
| `Desclasificador` | cómo puede bajarse |

Los tres describen **observación**. La regla de flujo —`L ⊑ C`, o un desclasificador
autorizado— dice a dónde puede *llegar* la información. Todo lo que v1alpha1 gobierna es
lo que alguien puede llegar a **saber**.

Los tres documentos de v1alpha2 son, los tres, sobre lo contrario:

| | Efecto sobre |
|---|---|
| `Rule` | el **contenido** — deriva hechos que no están en ninguna tabla |
| `Function` | el **mundo** — escribe en una fuente física |
| `Resolution` | la **identidad** — decide que dos registros son uno |

> **v1alpha1 gobierna lo que se puede saber. v1alpha2 gobierna lo que se puede causar.**

Esa frase no es retórica: es la razón de que los tres vayan juntos en una versión y de que
ninguno se pueda especificar bien por separado.

---

## 2. Lo que hay que añadir son dos cosas, no cuatro

El error caro aquí sería escribir tres documentos con tres modelos de gobernanza. Casi
todo lo que hace falta **ya está en v1alpha1**; lo que falta es una adición conceptual y
una decisión de composición.

### 2.1 · El eje de integridad

La regla de flujo tiene un dual conocido y no hay que inventarlo. Es literatura de control
de flujo de información desde los años setenta:

| | Gobierna | Regla | Origen |
|---|---|---|---|
| **Confidencialidad** | lecturas | la información no sube a donde no está autorizada | Bell–LaPadula |
| **Integridad** | escrituras | el efecto no baja de la confianza que exige su destino | Biba |

Un retículo `gdpr.sensitivity` dice **cuán sensible** es un dato y gobierna quién lo ve. Un
retículo de integridad dice **cuán fiable** es un actor o un dato, y gobierna qué puede
modificar. Son ejes ortogonales y ambos son retículos: **el documento `Lattice` de v1alpha1
ya sirve para los dos**, sin cambios.

Lo que cambia es la dirección de la comparación. Para leer, `⊑`. Para escribir, `⊒`.

### 2.2 · El endosante

Si el desclasificador es la vía de escape autorizada de la confidencialidad, la integridad
necesita la suya: algo que **suba** el nivel de confianza de forma auditada.

```
Desclasificador   baja confidencialidad   mask · tokenize · redact · aggregate · promote
Endosante         sube integridad         ¿?
```

**Y los borradores ya lo inventaron sin nombrarlo, tres veces y de tres formas distintas:**

| Borrador | Cómo lo llama |
|---|---|
| `Function` | `authorization.requireHumanApproval.when` |
| `Resolution` | `requires.approvedBy: "@acme/security"` |
| `Rule` | *(implícito: `status: STABLE` revisado en un PR)* |

Tres nombres para un concepto es exactamente el síntoma que precede a tres semánticas
distintas. Nombrarlo unifica los tres documentos bajo una sola regla y hace que el
vocabulario de endosantes sea **cerrado y auditable**, igual que el de desclasificadores.

Candidatos para ese vocabulario cerrado, a decidir: aprobación humana registrada en un
commit, revisión de un equipo de `CODEOWNERS`, una suite de pruebas en verde, una firma.

### 2.3 · El lenguaje de expresiones

Los tres documentos necesitan expresiones —`preconditions`, `expr`, `match`— y **P3 prohíbe
el cómputo arbitrario en un documento que gobierna**. Un `expr` que pueda no terminar, o
que pueda llamar a la red, deja de ser dato inerte revisable.

Por **P6**, esto no se inventa. El candidato es **CEL** (Common Expression Language): total,
terminante, sin efectos, y ya es el motor de las políticas de admisión de Kubernetes —
exactamente el mismo problema. La sintaxis de los borradores ya es prácticamente CEL.

Lo que hay que decidir y especificar es la **superficie**: qué funciones se exponen. Los
borradores usan `graph.out`, `graph.in`, `graph.reachable`, `graph.depth`, `temporal.noOverlap`,
`size`, `count`, `band(...)`. Cada una de ellas es una decisión de gobernanza disfrazada de
utilidad, porque **cada una es una lectura**: `graph.reachable` sobre la jerarquía lee la
topología, y `band(employeeId)` lee valores de negocio. Ambas son flujos, y la regla de
flujo de v1alpha1 se les aplica sin ninguna extensión.

---

## 3. Los documentos

### 3.1 · `Rule`

Se parte en dos cosas que los borradores mezclan bajo un mismo `type:`, y que no se
parecen en nada:

| | Qué es | Gobernanza |
|---|---|---|
| `inference` | **produce** una propiedad nueva | es un efecto sobre el contenido |
| `constraint` | **afirma** un invariante | es una comprobación, no un efecto |

Y la inferencia tiene una propiedad que la hace fácil: **es `derivedFrom` con el cómo**.
v1alpha1 ya especifica que una propiedad derivada computa su etiqueta por `join` de sus
orígenes y que declararla es `OOS4008`. Una regla de inferencia es lo mismo con una
expresión adjunta, así que **no necesita modelo de gobernanza nuevo**: hereda el que ya
existe y ya está implementado.

> **P7 · pendiente de resolver antes de escribir este documento.** SHACL es un lenguaje de
> restricciones sobre grafos, y SHACL-AF tiene reglas de inferencia. La carga de la prueba
> es nuestra: hay que escribir por qué `constraint` no es SHACL, o adoptar SHACL. No se
> escribe `Rule` hasta que esa pregunta tenga respuesta escrita.

### 3.2 · `Function`

La superficie de escritura gobernada, y el documento que convierte OOS de catálogo en
sustrato. El borrador es fuerte y ya trae la honestidad de diseño que hay que conservar:

- **`effects` declarados, no descubiertos.** Una función dice qué escribe. Es lo que
  permite comprobar la regla de integridad al compilar, sin ejecutar nada.
- **`transaction.scope: single-datasource`.** El borrador se niega a prometer atomicidad
  entre PostgreSQL y Salesforce. Esa negativa es una característica y se queda.
- **`network: DENY` en el sandbox.** El aislamiento es parte del contrato, no del despliegue.
- **`requireHumanApproval`** — que es el endosante de §2.2 y hay que renombrar.

Lo que falta y es el trabajo real: **la regla de integridad**. Una función solo puede
causar un efecto sobre una propiedad si el actor que la invoca alcanza la integridad que
esa propiedad exige, o si atraviesa un endosante autorizado. Es la frase dual de la regla
de flujo, y tiene que ser igual de comprobable **sin ejecutar la función**.

### 3.3 · `Resolution`

El efecto sobre la identidad, que es el más peligroso de los tres: **fusionar dos entidades
fusiona sus etiquetas.** Y aquí la maquinaria de v1alpha1 responde sola —`join = max`— así
que la entidad resuelta hereda el máximo de ambas, y eso ya se computa.

El borrador acierta en la distinción que importa:

| Estrategia | Qué lee | Consecuencia |
|---|---|---|
| `deterministic` | solo la clave | encaja en el índice de topología; no toca valores de negocio |
| `probabilistic` | **valores reales, a escala** | es un conducto, y como tal exige autorización declarada |

Esa segunda fila cae directamente de v1alpha1: comparar nombres y direcciones es hacer
fluir datos etiquetados hacia un emparejador. `requires.materialization: cache` del borrador
no es una opción de rendimiento — es la declaración del conducto. Renombrarlo para que lo
diga.

---

## 4. Resolución de dependencias

No es un documento: es **distribución**, y es lo que cierra «autosuficiente».

Hoy `ontology.lock` existe, `dependencies` existe, `OOS2013` comprueba que estén
sincronizados, y **nada puede traer un paquete**. El formato del lock ya apunta a un
registro (`resolved: https://registry.oos.dev/...`) que no está construido. Un mensaje de
error de ORE tuvo que dejar de recomendar `ore install` porque ese comando no existe.

Alcance mínimo: un protocolo de registro, el formato del paquete publicable (`.oob`), y el
resolutor. Sin esto, el paquete de clasificación importable —«GDPR como dependencia»— no
existe, y cada organización redeclara sus propios retículos.

---

## 5. Lo que NO entra

**`Policy` sigue muerto, y conviene decir por qué.** El borrador de acme-global define un
lenguaje de autorización propio: `defaultEffect: DENY`, `rules` con `effect: ALLOW`, `when:`.
Eso es exactamente lo que v1alpha1 decidió no hacer — **las políticas son Cedar**, y esa
decisión no se reabre.

Pero el borrador destapa un hueco real que hay que registrar:

```yaml
graph.reachable(from: subject, to: resource, via: "people.reportsTo", maxDepth: 5)
```

La proyección a esquema Cedar ya convierte una autorreferencia en jerarquía de entidades,
así que `resource in principal` expresa «por debajo de mí en la cadena de mando». Lo que
**no** expresa es `maxDepth: 5`: el operador `in` de Cedar es el cierre transitivo completo
y no admite límite de profundidad.

Es un límite de expresividad de Cedar, no un motivo para volver a un lenguaje propio. Las
salidas posibles —materializar la profundidad como propiedad, o aceptar el cierre completo—
son una decisión abierta.

**`Test` tampoco entra.** Es real y hace falta, pero es una comprobación sobre datos, y por
tanto L2/L3: no es certificable por una suite de ficheros. Va después.

---

## 6. Decisiones abiertas

1. **`Rule` frente a SHACL** — la pregunta P7 de §3.1. Bloquea escribir `Rule`.
2. **El vocabulario cerrado de endosantes.** ¿Cuáles, y cómo se verifica cada uno al
   compilar sin reloj y sin red?
3. **La superficie de CEL.** Qué funciones de grafo y temporales se exponen, sabiendo que
   cada una es una lectura sujeta a la regla de flujo.
4. **`maxDepth` en Cedar** — materializar la profundidad, o aceptar el cierre transitivo.
5. **Qué es certificable.** De todo lo anterior, cuánto cae en L0. La regla de integridad
   sí; la ejecución de una función, no. La suite solo puede crecer con lo primero.
