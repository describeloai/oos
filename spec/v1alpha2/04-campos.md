# Los dos campos

**Estado:** alcance cerrado, primera versión. `spec/v1alpha1/` sigue siendo la versión
normativa.

v1alpha2 se cerró declarando **dos documentos nuevos y dos campos añadidos a documentos que
ya existen**. Los documentos se escribieron —[`02-function`](02-function.md) y
[`03-resolution`](03-resolution.md)—; los campos quedaron decididos en
[`00-scope`](00-scope.md) §3.1 y sin especificar. Esto es lo que faltaba para que la versión
esté cerrada de verdad.

---

## 1. `expr` no existe: es `expression`, promovida

El borrador proponía añadir `Entity.properties.<n>.expr`. **Es un error, y del que este
proyecto ya ha cometido y corregido cuatro veces**: `expression` existe en v1alpha1 desde el
primer día.

> *«Cómo se calcula, en prosa o pseudocódigo. **DOCUMENTAL: no se interpreta en v1alpha1.**
> Interpretarla exigiría un motor de consultas dentro del compilador y rompería su pureza.»*
> — [`entity.schema.json`](../../schemas/v1alpha1/entity.schema.json)

Un `expr` junto a un `expression` serían **dos nombres para un concepto**, separados por tres
letras, y ya sabemos cómo acaba eso: es exactamente el hallazgo del endosante
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

**Quinta vez que la respuesta correcta es quitar**, y la primera en que lo quitado no había
llegado a existir. Que salga más barato es el argumento entero de **P7**.

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

---

## 3. `quality` — el perfil, y el plano

El segundo campo, y aquí no hay sorpresa: es `quality` de ODCS v3.1, el mismo cuerpo que
[`v1alpha3/02-ruleset`](../v1alpha3/02-ruleset.md) §3 perfila. Lo único que este documento
fija es **dónde cuelga**.

### 3.1 · La partición es por plano, no por gusto

| Tipo | Dónde | Por qué |
|---|---|---|
| `library` — `nullValues mustBe 0` | **`Entity`** | es una afirmación sobre el **significado**: esta propiedad no es nula nunca. Sin dialecto |
| `sql` | **`Binding`** | está atada a un dialecto, y el dialecto solo se conoce donde se declara la fuente |

Y la consecuencia es estructural, no semántica: **el esquema de `Entity` no admite
`type: sql`**, así que escribirlo ahí es una clave con valor fuera del conjunto y no necesita
código propio. Un código semántico para algo que el esquema resuelve es peso muerto — la
lección de `OOS7010`, aplicada por quinta vez.

Lo que se hereda con `sql` es la limitación de ODCS y conviene decirlo en vez de fingir que
no está: **una regla `sql` no es portable entre fuentes.**

### 3.2 · Dónde cuelga exactamente

ODCS admite `quality` a nivel de propiedad y a nivel de esquema, y se perfilan los dos:

```yaml
kind: Entity
spec:
  quality:                                  # ← sobre la entidad entera
    - { id: al-menos-una-fila, metric: rowCount, mustBeGreaterThan: 0 }
  properties:
    taxId:
      type: String
      quality:                              # ← sobre esta propiedad
        - { id: sin-nulos, metric: nullValues, mustBe: 0, dimension: completeness }
```

`schedule` y `scheduler` de ODCS **no se perfilan**, por la misma frontera que fija
[`01-efectos`](01-efectos.md) §6 para las funciones: **ningún planificador**. Un documento
declara qué debe sostenerse; cuándo se comprueba es del motor que lo ejecute, y ODCS mismo
dice que ese motor es Soda, Great Expectations o dbt.

### 3.3 · Y su relación con `Ruleset`

Ahora que existen las dos mitades, la frase que las separa se puede leer entera:

> Una regla sobre **una** propiedad se escribe donde está la propiedad. Una regla sobre
> **una clase** de propiedades se escribe donde está la clase.

No compiten: comparten el cuerpo y difieren en **cómo se nombra el dominio** —escrito aquí,
computado allí—. El guardarraíl que impide que se solapen es que `Ruleset` **NO DEBE**
admitir objetivos por enumeración ([`v1alpha3/02-ruleset`](../v1alpha3/02-ruleset.md) §4).

Pero abren una pregunta que no estaba escrita y que hay que decidir antes de que muerda:
**¿una regla escrita aquí descarga una exigencia importada?** Está registrada como decisión
abierta en [`v1alpha3/00-scope`](../v1alpha3/00-scope.md) §6.

---

## 4. Lo que estos dos campos cuestan

**Un código.** `OOS4015`, y no sale de `quality` —que no necesita ninguno— sino de la
consistencia entre `expression` y `derivedFrom`.

Y merece verse por lo que es: **una deuda de v1alpha1 que solo se hace visible cuando la
expresión pasa a ser comprobable.** Los dos campos llevaban tres versiones uno al lado del
otro sin que nada comprobase que dijeran lo mismo. No es un coste de v1alpha2 — es una
factura que v1alpha2 hace legible.

`OOS4015` es de la familia **`OOS4xxx`**, porque lo que está en juego es la solidez de la
propagación, y no cuenta entre los 52 de v1alpha1: es un código que vive en una familia
antigua y lo introduce una versión posterior, igual que `OOS2001`.
