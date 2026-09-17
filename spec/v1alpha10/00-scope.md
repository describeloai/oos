# OOS v1alpha10 — alcance

**Estado:** borrador de alcance. Gobierna los documentos que declaran su `apiVersion`, y es
**alpha**: sin garantías de compatibilidad.

| | |
|---|---|
| `00-scope` | **este documento** — qué entra, qué no, y por qué la función cambia de naturaleza |
| [`01-function`](01-function.md) | la función: lógica encapsulada que lee, edita o infiere sobre la copia, con su superficie en los dos sentidos |
| [`02-action`](02-action.md) | la acción: lo que un actor puede causar, sin código, como documento |

Esta versión **cambia la naturaleza de `Function`** y **añade un `kind`**, `Action`. No retira
ningún código de error y añade uno: `OOS7014`, una función que lee lo que no declara.

---

## 1. La tesis

Cada versión gobierna un verbo, y aporta **una** regla:

| versión | verbo | la regla |
|---|---|---|
| v1alpha7 | **preguntar** | la vista es la pregunta y compone |
| v1alpha8 | **apuntar** | lo físico se registra una vez, con dos caras |
| v1alpha9 | **razonar** | un modelo que se usa es un documento del árbol, y nombra un perfil medido |
| **v1alpha10** | **actuar** | **lo que una función toca se lee en su documento, en los dos sentidos: `lee(f) ⊆ reads(f)` y `causa(f) ⊆ effects(f)`** |

v1alpha2 definió la función por lo que **causa**, y solo por eso: `effects` obligatorio, la
lectura implícita en las precondiciones, el objeto implícito en `target`. Era la mitad que
hacía falta para el régimen de integridad, y la mitad que faltaba para que una función
sirviera para algo más que aprobar un pedido.

Lo que esta versión afirma: una función es **un trozo de lógica como código, encapsulado, que
lee o edita los hechos de la copia, y que es el puente por el que un modelo soberano infiere
sobre un conjunto de ellos**. Tres caras de una misma cosa —leer, editar, inferir— con un solo
régimen: lo que entra en el sandbox está enumerado, lo que sale está enumerado, y la
integridad de lo que sale se computa de los endosos.

## 2. Por qué cambia la naturaleza, y no solo la forma

Tres cosas se midieron antes de escribir esto, sobre `acme-retail` y el compilador de
referencia:

1. **Una función no podía entrar sola.** Escribir una función sobre una propiedad exigía
   siete escrituras de seis kinds: el retículo de integridad, la etiqueta, la clave de la
   tabla, la copia de la vista, el conducto de la copia autorizado, la función, y el esquema
   Cedar regenerado al final. Cuatro de las siete no eran de la función: eran de **dónde vive
   la copia**, que v1alpha8 decidía vista a vista.
2. **La copia ya no se decide vista a vista.** Una *database* es `standard` (copia entera,
   bajo control del inquilino) o `foreign` (un espejo: cada lectura va al origen). En una
   standard todas sus vistas tienen copia; en una foreign ninguna. Con eso, `materialized`
   deja de ser una elección por vista y pasa a ser la consecuencia de la database, y el
   conducto de la copia se autoriza una vez, no por vista.
3. **Lo que una función lee no se declaraba.** El arrastre de integridad (`OOS7001`) solo
   veía lo que una precondición miraba; una función que leyera veinte propiedades por su
   cuenta no arrastraba nada. Y lo que no se declara no fluye por la regla de flujo: **la
   mitad de la superficie estaba fuera del régimen.**

De ahí las tres decisiones: `reads` como sección propia y sus valores son **vistas**;
`effects` **opcional**, porque leer y devolver es legítimo; y el conjunto sobre el que la
función actúa es una **vista** (`over`), no una fila implícita.

## 3. Por qué la ontología no tiene objetos, y qué significa para una función

En OOS no hay objetos: hay **tablas** (punteros a lo físico, con sus dos caras), **vistas**
(preguntas sobre ellas) y **entidades** (el significado de esas preguntas), con la gobernanza
de extremo a extremo encima. Una función de Foundry recibe objetos y conjuntos de objetos; una
función de OOS recibe **las filas de una pregunta**. Y eso no es una limitación: es lo que
hace que el puente hacia un modelo no rompa la gobernanza. Lo que entra en el sandbox es una
vista, con sus etiquetas, y el sandbox es un conducto como cualquier otro (`04-flow`).

Por eso no hay «funciones de lectura» como kind aparte: una lectura **es una vista**. Una
función que lee y devuelve es una función con `reads` y `output` y sin `effects`, y lo que
lee sigue siendo una pregunta declarada, revisable en un pull request. Una pregunta que no
quepa en el vocabulario de `View` es una razón para que el vocabulario crezca, medida, no
para esconderla en código (**P3**).

## 4. Qué entra

- `Function` con `reads`, `over`, `effects` opcional, y el puente con el modelo por la misma
  función — [`01-function`](01-function.md).
- `kind: Action` — la invocación como documento: parámetros, criterios, lo que causa, quién
  puede, **sin código** — [`02-action`](02-action.md).
- `OOS7014` — la función lee lo que no declara: una precondición que mira una propiedad fuera
  de `over`, o un `reads` que no resuelve.

## 5. Qué no entra, y por qué

- **Un kind de database.** Que una database sea `standard` o `foreign` es un hecho del
  catálogo de quien la induce, no de la gramática: se refleja en el árbol como `materialized`
  en todas sus vistas o en ninguna. `OOS2025` sigue siendo el código de una escritura sobre una
  vista sin copia, y en v1alpha10 significa «la database es foreign».
- **La concurrencia entre el refresco y los efectos.** Si la copia se refresca desde el origen
  y la ontología la escribe, dos autores tocan la misma fila. `changes.mode` dice qué llega;
  **qué gana** cuando discrepan no se decide aquí. Se nombra para que nadie crea que está
  decidido.
- **El SDK del runtime.** Cómo el código recibe las filas de `reads` y devuelve `output` es del
  runtime (wasm, o el adaptador del modelo), no de la gramática.
- **La vuelta al origen.** Control sobre la copia no es control sobre Workday. Sigue siendo
  otro producto.

## 6. Compatibilidad, y cómo termina lo implícito

Ningún documento de v1alpha1 a v1alpha9 cambia de resultado. `reads`, `over` y `sets` son
claves de v1alpha10 y en una versión anterior son `OOS1005`.

Una función v1alpha10 **sin `over`** —la forma de v1alpha2, con `target` implícito— sigue
compilando en esta versión, acotada y con fin, como v1alpha7 hizo con `Binding`: la siguiente
versión que toque `Function` la retira. Se dice aquí para que la migración sea una tabla y no
una sorpresa.
