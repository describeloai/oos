# OOS v1alpha2 — alcance

**Estado:** borrador de alcance. Ningún documento de esta carpeta es normativo todavía.
`spec/v1alpha1/` sigue mandando.

| | |
|---|---|
| `00-scope` | **este documento** — qué entra en v1alpha2, qué no, y qué queda abierto |
| [`01-efectos`](01-efectos.md) | el núcleo — el régimen de efectos, del que se deriva todo lo demás |
| [`02-function`](02-function.md) | la superficie de efecto — el primer documento que aplica el régimen |
| [`03-resolution`](03-resolution.md) | el efecto sobre la identidad — el más peligroso de los tres |

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

El error caro sería escribir tres documentos con tres modelos de gobernanza. Casi todo lo
que hace falta **ya está en v1alpha1**: lo que falta es un eje —**integridad**, el dual
conocido de la confidencialidad, literatura de control de flujo desde los setenta— y una
decisión de composición para las expresiones.

Las dos se especifican en [`01-efectos.md`](01-efectos.md), que es el núcleo de esta
versión. Aquí solo consta el alcance y su estado:

| | Estado |
|---|---|
| **eje de integridad** — `Lattice` gana `axis`, y de ahí sale el combinador | decidido · `01-efectos` §1, §3.1, §4.2 |
| **endosante** — el dual del desclasificador | nombrado y acotado; el vocabulario sigue sin cerrar · §3.2 |
| **CEL** para expresiones — **P3** prohíbe el cómputo arbitrario en un documento que gobierna | adoptado; la superficie sigue sin decidir · §5 |
| **la regla de integridad**, y qué parte de ella cae en L0 | decidido · §4.1 |

Un hallazgo de alcance que sí pertenece aquí, porque es la razón de que los tres documentos
vayan juntos: **el endosante ya estaba inventado tres veces con tres nombres** en los
borradores de `docs/vision/` — `requireHumanApproval` en `Function`, `approvedBy` en
`Resolution`, y el `status: STABLE` revisado en un PR de `Rule`. Un concepto con tres
nombres acaba teniendo tres semánticas, y esa es exactamente la deriva que una versión
conjunta evita.

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
- **`requireHumanApproval`** — que es un endosante, y se renombró
  ([`01-efectos`](01-efectos.md) §3.2, [`02-function`](02-function.md) §6.1).

Escrito en [`02-function`](02-function.md). Dos cosas que conviene no perder de vista al
leer el borrador original: la regla **no** se enuncia como sale de la intuición —«el actor
que invoca alcanza la integridad que el destino exige»—, porque al compilar no hay actor y
esa formulación deja el régimen fuera de L0; y la integridad de una función **se computa**
de sus endosos, nunca se declara.

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
no es una opción de rendimiento — es la declaración del conducto, y se renombró a `conduit`.

Escrito en [`03-resolution`](03-resolution.md), donde el eje de integridad aporta lo único
que no era gratis: **una coincidencia probable no produce un hecho.** Por bien calibrada que
esté, una estrategia probabilística infiere, y `threshold: "0.99"` sigue sin ser una
observación.

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

**Cerrada desde que se escribió el núcleo:** *qué es certificable*. La partición está en
`01-efectos` §4.1 — la regla de integridad es L0 porque se escribe sobre la función y no
sobre quien la invoca; la invocación es L3 y es de Cedar. La suite solo puede crecer con
lo primero.
