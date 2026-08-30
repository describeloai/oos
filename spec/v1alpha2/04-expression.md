# `expression`, promovida

**Estado:** alcance cerrado, primera versión. `spec/v1alpha1/` sigue siendo la versión
normativa.

v1alpha2 se cerró declarando **dos documentos nuevos y dos campos añadidos a documentos que
ya existen**. Los documentos se escribieron; de los campos, **uno no debía existir y el otro
tampoco era un campo nuevo**. Este documento es lo que queda de aquella frase cuando se la
examina, y la versión no está cerrada hasta que se examina.

---

## 1. `expr` no existe: es `expression`, promovida

El borrador proponía añadir `Entity.properties.<n>.expr`. **Es un error, y del que este
proyecto ya ha cometido y corregido cuatro veces**: `expression` existe en v1alpha1 desde el
primer día.

> *«Cómo se calcula, en prosa o pseudocódigo. **DOCUMENTAL: no se interpreta en v1alpha1.**
> Interpretarla exigiría un motor de consultas dentro del compilador y rompería su pureza.»*
> — [`entity.schema.json`](../../schemas/v1alpha1/entity.schema.json)

Un `expr` junto a un `expression` serían **dos nombres para un concepto**, separados por tres
letras, y ya sabemos cómo acaba eso: es el hallazgo del endosante
([`00-scope`](00-scope.md) §2), que estaba inventado tres veces con tres nombres.

Así que v1alpha2 **no añade un campo**: cambia el **estatuto** de uno que ya está.

| | v1alpha1 | v1alpha2 |
|---|---|---|
| `expression` | prosa o pseudocódigo | **CEL** |
| | documental | **se comprueba** |
| `derivedFrom` | normativo para la propagación | igual, sin cambios |

Y no hace falta migración ni periodo de aviso: **el `apiVersion` es el discriminante** —hay
un esquema por versión, y esa frase ya está escrita en el esquema del retículo—. Un documento
de v1alpha1 conserva su `expression` en prosa y sigue siendo válido; uno de v1alpha2 la
declara en CEL.

---

## 2. Lo que se comprueba, y lo que sigue sin computarse

**No se evalúa.** El compilador no calcula el valor de una propiedad derivada, ni en
v1alpha2 ni después: eso exige datos, es L2, y romper esa frontera rompería la pureza de la
compilación (invariante III). Una propiedad derivada **DEBE** seguir teniendo binding como
cualquier otra.

Lo que sí se comprueba es una consistencia que hasta ahora no podía comprobarse:

> Toda propiedad que la expresión lee **DEBE** estar declarada en `derivedFrom` (`OOS4015`).

### 2.1 · Por qué esto importa más de lo que parece

`derivedFrom` es lo que **propaga las etiquetas**. Si la expresión lee `salary` y
`derivedFrom` solo declara `department`, el compilador propaga la etiqueta de `department` y
**la de `salary` desaparece**. La propiedad derivada queda clasificada por debajo de lo que
le corresponde, y a partir de ahí fluye a sitios donde no debería.

Es el modo de fallo de `OOS4001` visto desde otro ángulo, y con un agravante: allí la
etiqueta está a dos saltos y no la ve nadie; **aquí está escrita en la línea de al lado, y
tampoco la ve nadie**, porque hasta ahora los dos campos no se hablaban.

### 2.2 · Por qué `derivedFrom` no se deriva de la expresión

Es la pregunta obvia —si la expresión dice lo que lee, ¿para qué declararlo?— y v1alpha1 ya
la contestó, en el mismo esquema:

> *«Es obligatoria y no se infiere porque **un análisis de contaminación sólido no puede
> depender de parsear cadenas de expresión**.»*

Esa decisión se mantiene, y fija la dirección de la comprobación:

| | |
|---|---|
| `derivedFrom` | **normativo.** Es lo que propaga |
| `expression` | **se comprueba contra él**, nunca al revés |

El análisis de la expresión es **conservador y solo puede apretar**: lo que encuentra tiene
que estar declarado; lo que se le escape no afloja nada, porque la propagación no depende de
él. Un analizador incompleto produce menos errores, nunca una etiqueta más baja — que es la
única dirección en la que un fallo de análisis es aceptable.

### 2.3 · Normativo

- `expression` en un documento de v1alpha2 **DEBE** ser una expresión CEL. Su superficie
  exacta sigue abierta ([`00-scope`](00-scope.md) §6).
- Una propiedad con `expression` **DEBE** declarar `derivedFrom`. Una computación sin
  procedencia declarada es un fallo de forma: `OOS1004`.
- Toda referencia que la expresión lee **DEBE** estar en `derivedFrom`: `OOS4015`.
- Una referencia a algo que no existe sigue siendo `OOS2005`, sin código nuevo.
- Una propiedad con `derivedFrom` sigue sin poder declarar `labels` (`OOS4008`) y sin poder
  ser destino de un efecto (`OOS7006`). Nada de eso cambia.

`OOS4015` es de la familia **`OOS4xxx`**, porque lo que está en juego es la solidez de la
propagación, y no cuenta entre los 52 de v1alpha1: es un código que vive en una familia
antigua y lo introduce una versión posterior, igual que `OOS2001`.

Y merece verse por lo que es: **una deuda de v1alpha1 que solo se hace visible cuando la
expresión pasa a ser comprobable.** Los dos campos llevaban tres versiones uno al lado del
otro sin que nada comprobase que dijeran lo mismo. No es un coste de v1alpha2 — es una
factura que v1alpha2 hace legible.

---

## 3. `quality` **no** cuelga de la propiedad

El segundo campo se retira, y conviene decir por qué se llegó a escribir: **§3.1 adoptó la
topología de ODCS junto con su vocabulario, sin separar las dos cosas.** ODCS pone `quality`
colgando de la propiedad, y eso se copió sin argumento.

Pero este proyecto ya tiene la regla para exactamente eso, escrita para Ossie:

> **objetivo de emisión, no anfitrión de la entidad**
> — [`00-overview`](../v1alpha1/00-overview.md) §7.2-bis

**Adoptar el vocabulario de un estándar no obliga a adoptar su topología.** El cuerpo de una
aserción sigue siendo `quality` de ODCS, sin cambios; lo que se retira es que se **escriba**
ahí.

### 3.1 · Cinco razones, y la quinta es la que decide

| | |
|---|---|
| **1** | Reintroduce lo que v1alpha3 existe para arreglar. *«Una regla local enumera»* — y una regla inline **es** enumeración, por construcción |
| **2** | **No tiene dueño.** Un `Ruleset` existe porque quien responde del cumplimiento tiene que poder restringir sin poder editar. Una regla inline tiene el dueño de la entidad: es el antipatrón que justifica la alternativa |
| **3** | El guardarraíl era **unidireccional**. *«`Ruleset` no admite objetivos por enumeración»* impide que un `Ruleset` haga el trabajo de inline; **no impide lo contrario**, y nada detectaría el mismo `nullValues mustBe 0` escrito cuatrocientas veces |
| **4** | Deja un agujero en la cobertura: el equipo que clasifica una propiedad puede **descargarse a sí mismo** la exigencia que le impuso un paquete importado, y `requiresGovernance` deja de exigir nada |
| **5** | **La prohibición era autodestructiva.** Prohibir enumerar en `Ruleset` obligaba a construir la enumeración en otro sitio: movía el problema en vez de resolverlo, y producía las dos formas que quería evitar |

### 3.2 · Y lo que la hace innecesaria

> **`OOS8001` vuelve segura la enumeración.**

La razón por la que enumerar se pudre es que una propiedad nueva se escapa **en silencio**.
Con la regla de cobertura, una propiedad clasificada que ningún objetivo alcanza **rompe la
compilación**. Un objetivo por nombre dentro de un `Ruleset` deja de ser peligroso: la
cobertura caza la podredumbre.

La prohibición se escribió **antes** de que la cobertura existiera. La premisa que la
justificaba dejó de sostenerse y nadie la revisó — hasta ahora.

Así que `Ruleset` gana objetivos **por nombre** junto a los de predicado
([`v1alpha3/02-ruleset`](../v1alpha3/02-ruleset.md) §2), y el caso enumerado tiene sitio
**sin** que exista una segunda superficie de autoría.

### 3.3 · La distinción que debió usarse desde el principio

> **Lo que la propiedad *es* va en la propiedad. Lo que alguien *exige* de ella va donde
> está quien lo exige.**

| | Qué es | Dónde |
|---|---|---|
| `type` · `labels` · `derivedFrom` · `expression` | lo que la propiedad **es** | la propiedad |
| `quality` | lo que alguien **exige** de ella | un `Ruleset` — otro hablante, otro dueño, otra cadencia |

Y es la línea que separa a los dos grupos del campo, que no se dividen por gusto sino por
propósito: **dbt** pone sus tests inline junto al modelo —ergonomía de quien transforma—;
**Soda** y **Great Expectations** los ponen en ficheros aparte —gobierno de quien vigila—.
OOS es un artefacto de gobierno, y estaba eligiendo la ergonomía del otro.

### 3.4 · Objetivo de emisión

`quality` sigue siendo **el cuerpo** de una aserción y **el destino** de su emisión: un
contrato ODCS emitido desde un paquete OOS lleva sus aserciones colgando de la propiedad,
que es donde ODCS las espera y donde Soda, Great Expectations y dbt saben leerlas.

```json
{ "name": "taxId",
  "quality": [
    { "id": "sin-nulos", "metric": "nullValues", "mustBe": 0,
      "x-oos-ruleset": "eu.nif" } ] }
```

Dos decisiones de esa proyección, y las dos importan más que la mecánica:

**La selección no se recomputa al emitir: la da la misma fase que decide `OOS8001`.** Dos
selecciones serían dos semánticas, y la que gobierna al compilar tiene que ser exactamente la
que se emite. Lo único que la emisión aporta es el reparto — una aserción a cada propiedad que
su regla gobierna.

**`x-oos-ruleset` viaja con cada aserción**, y es lo que hace auditable el contrato: dice
**quién exige** la regla. Un contrato que enumera obligaciones sin decir de dónde vienen no se
puede revisar; hay que creérselo. Es la misma razón por la que un `Ruleset` tiene `owner`.

Un contrato importado no trae `Ruleset`, así que la ida y vuelta no proyecta nada: **no puede
inventar una obligación que nadie declaró**, y por eso la identidad que exige
`emit/roundtrip-odcs-unknown-sections` sigue en pie.

Queda la dirección contraria: importar un contrato ODCS con `quality` inline **levantando** un
`Ruleset` con objetivos por nombre. Hoy esa sección entra por el paso a través y sale intacta,
que conserva la fidelidad y no la convierte en gobierno.
