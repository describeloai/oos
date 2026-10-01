# 01 · La función de código — `runtime: python`

**Estado:** borrador. Extiende [`v1alpha10/01-function`](../v1alpha10/01-function.md) con un
runtime y una clave, y conserva su naturaleza entera: lo que una función lee es la unión de lo que
declara, lo que devuelve es su `output`, y lo que causa, sus `effects`. Lo que no se dice aquí, es
lo de v1alpha10 (con `metadata.schema` desde v1alpha13).

---

## 1. Naturaleza

> **Una función de código es un `def` de un repositorio marcado con `@function`. Quien programa
> escribe el `def`; el documento `Function` se deriva de él, y es lo que se gobierna.**

Nadie escribe una función en YAML. Se escribe código —un `def` con sus tipos— y se marca: ese
`@function` es el acto explícito de promoverlo a algo que un consumidor puede nombrar. El documento
`Function` que lo acompaña en el árbol **no se escribe a mano**: lo produce la herramienta, en el
mismo commit que el código, con la regla de §4, y es lo que aporta el resto —el nombre en el
catálogo, la versión del paquete, la superficie de lectura, la autorización, el linaje—.

Es la figura del esquema Cedar (v1alpha1 `00` §5): un artefacto **generado** que se compromete, para
que todo lo que lee el árbol —el catálogo, `ore diff`, un consumidor, un validador sin el código
a mano— lo encuentre sin derivarlo, y que el compilador **coteja** con su fuente: un documento que no
es el que el código da es `OOS2013`.

Y se coteja **leyendo**, sin ejecutar nada: los decoradores, la cabecera del `def` y sus
anotaciones son sintaxis, no comportamiento.

## 2. Anatomía

Lo que se escribe:

```python
# packages/ventas/riesgo/funciones/riesgo.py
from dataclasses import dataclass
from ore import function


@dataclass
class Riesgo:
    nivel: str
    total: float


@function(over="ventas.clientes", reads=["ventas.pedidos"], models=["extractor"], timeout="60s")
def riesgo(cliente, umbral: float, moneda: str = "EUR") -> Riesgo:
    """El riesgo de un cliente por lo que ha comprado."""
    ...


@function
def sumar(a: int, b: int) -> str:
    return f"{a} + {b} = {a + b}"
```

Y lo que se deriva, uno por `@function`:

```yaml
apiVersion: oos.dev/v1alpha18
kind: Function
metadata:
  name: riesgo
  namespace: ventas
  description: El riesgo de un cliente por lo que ha comprado.
spec:
  runtime: python
  entrypoint: riesgo/funciones/riesgo.py:riesgo
  over: ventas.clientes
  reads: [ventas.pedidos]
  models: [modelo/extractor]
  input:
    umbral: { type: Float, required: true }
    moneda: { type: String }
  output:
    nivel: { type: String, required: true }
    total: { type: Float, required: true }
  limits: { timeout: 60s }
---
apiVersion: oos.dev/v1alpha18
kind: Function
metadata: { name: sumar, namespace: ventas }
spec:
  runtime: python
  entrypoint: riesgo/funciones/riesgo.py:sumar
  input:
    a: { type: Integer, required: true }
    b: { type: Integer, required: true }
  output: { type: String }
```

## 3. `runtime: python` y su `entrypoint`

`entrypoint` es **obligatorio** con `runtime: python`, y tiene la forma `<ruta>.py:<def>`:

- `<ruta>` es relativa a **la carpeta del paquete** (la que contiene su `package.yaml`), con `/`
  como separador, sin `..` y sin `/` inicial. Una función no nombra código de otro paquete.
- `<def>` es un identificador de Python.

La forma mal escrita es `OOS1004` (no valida contra el esquema). Bien escrita, y:

| | código |
|---|---|
| el fichero no existe en el paquete | `OOS2042` |
| el fichero no define `def <def>(…)` **en su nivel superior** (no dentro de una clase ni de otro `def`) | `OOS2042` |

Un `async def` no es un `def` y es `OOS2042`. `source` sigue siendo opcional e informativo, como en
v1alpha10; con `python`, el código fuente **es** el `entrypoint`.

## 4. El documento se deriva del código

### 4.1 · Qué es una función

Un `def` del **nivel superior** de un fichero `.py` del paquete con un decorador que **es**
`ore.function` —`@nombre` o `@nombre(...)`—. Qué es un nombre se decide **leyendo el fichero como
Python lo resolvería**, sin ejecutarlo (§4.9):

- `from ore import function` liga `function` a `ore.function`; `from ore import function as f`
  liga `f`. `import ore` liga `ore`, y `@ore.function` es él; `import ore as o`, `@o.function`.
- Vale la ligadura vigente **donde está el `def`**, porque un decorador se evalúa al definir la
  función. Lo que la tapa después —otra importación, un `def`, una clase, una asignación del mismo
  nombre— vale para lo que viene detrás, no para lo de antes.
- Cuentan las ligaduras del nivel superior, también las de dentro de un `if` o un `try` de ese
  nivel (`if TYPE_CHECKING:`, `try: … except ImportError:`).

Un `function` de otra biblioteca no lo es, aunque se llame igual. Un fichero puede tener varias.
Un `def` decorado dentro de una clase o de otro `def` no es una función (una herramienta PUEDE
avisar: así no se publica).

### 4.2 · Los argumentos del decorador

Solo por nombre, y solo **literales** —una cadena, o una lista de cadenas—, porque se leen sin
ejecutar:

| argumento | en el documento |
|---|---|
| `over="<vista>"` | `spec.over` |
| `reads=["<vista>", …]` | `spec.reads` |
| `models=["<referencia>", …]` | `spec.models`, cada una como `modelo/<referencia>` (sin repetir el prefijo si ya lo trae) |
| `timeout="<duración>"` | `spec.limits.timeout` |

Un argumento que no es uno de estos, o que no es literal (una variable, una concatenación, una
llamada), es `OOS2043`.

### 4.3 · El documento

| campo | de dónde |
|---|---|
| `apiVersion` | `oos.dev/v1alpha18` |
| `metadata.name` | el nombre del `def` |
| `metadata.namespace` | el nombre del paquete |
| `metadata.description` | la primera línea no vacía de la *docstring* del `def`, si tiene; si no, no está |
| `spec.runtime` | `python` |
| `spec.entrypoint` | `<ruta del fichero desde la carpeta del paquete>:<def>` |
| `spec.over`, `reads`, `models`, `limits.timeout` | §4.2; los que no se dicen, no están |
| `spec.input` | un parámetro por cada uno del `def` —salvo la fila, §4.4—, en su orden: `{type: T, required: true}` si no tiene valor por defecto ni es opcional; `{type: T}` si lo tiene o lo es. Sin parámetros, no está |
| `spec.output` | del tipo de retorno, §4.5 |

**`required` ausente es `false`.** Vale para `input` y `output` de **todas** las versiones, y nadie
lo había escrito: un parámetro sin `required` es opcional; en `output`, `required: true` dice que el
valor no puede faltar en lo que la función devuelve. Por eso la derivación escribe `required: true`
solo en lo obligatorio, y nada en lo demás.

Lo que el documento lleva de más —`authorization`, `endorsements`, `effects`, `preconditions`,
`idempotency`— no sale del código en esta versión: una función con cualquiera de ellos no se deriva
y se escribe como en v1alpha10. Un `@function` y un documento que lo nombra con alguno de ellos es
`OOS2013`.

### 4.4 · Los parámetros

- **Con `over`**, el primer parámetro es **la fila**: posicional, sin valor por defecto y sin
  anotación obligatoria; su nombre es libre y no entra en `input`. Sin él, `OOS2043`.
- **Todos los demás llevan anotación de tipo** (§4.6). Uno sin ella es `OOS2043`: la firma de una
  función es explícita, porque es lo que un consumidor ve.
- **Opcional** es tener valor por defecto, o anotarse `Optional[T]` / `T | None`.
- Ni `*args` ni `**kwargs`: la superficie es cerrada (`OOS2043`). El parámetro solo-por-nombre
  (`*, moneda: str = "EUR"`) vale como cualquier otro.

### 4.5 · Lo que devuelve

La anotación de retorno es **obligatoria** (`OOS2043` sin ella, o con `-> None`):

- **un tipo de §4.6** → `output: { type: T }`, **un valor** (§4.7);
- **una `@dataclass` del nivel superior del mismo fichero** → `output` como mapa de sus campos,
  cada uno con su tipo de §4.6, `required: true` si no tiene valor por defecto ni es opcional.

Una clase es una `@dataclass` si un decorador suyo es `dataclasses.dataclass`, con argumentos o sin
ellos (los nombres, como en §4.1). Y sus campos son lo que `dataclasses` diría:

- los nombres anotados de su cuerpo, en orden, salvo `ClassVar[…]`, `InitVar[…]` y el separador
  `KW_ONLY`, que no son campos;
- `campo: T = field(...)` tiene valor por defecto solo con `default=` o `default_factory=`; sin
  ninguno de los dos es obligatorio;
- puede heredar de otras `@dataclass` del nivel superior del fichero: sus campos van delante, y uno
  que se redefine cambia en su sitio. Heredar de otra cosa (salvo `object`) o llevar argumentos de
  clase (`metaclass=…`) es `OOS2043`: esos campos no se leen sin ejecutar.

### 4.6 · Los tipos

| Python | OOS |
|---|---|
| `int` | `Integer` |
| `float` | `Float` |
| `str` | `String` |
| `bool` | `Boolean` |
| `date`, `datetime.date` | `Date` |
| `datetime`, `datetime.datetime` | `DateTime` |
| `Decimal`, `decimal.Decimal` | `Decimal` |
| `list[T]`, `List[T]` | `list<T>`, con `T` de esta tabla y sin listas dentro |
| `Optional[T]`, `T \| None`, `Union[T, None]` | `T`, y el parámetro es opcional |
| `Annotated[T, …]` | `T`: lo demás no es firma en esta versión |

Cualquier otro —`dict`, `Any`, una clase que no es una `@dataclass` del fichero, un tipo de otra
biblioteca— es `OOS2043`: lo que no tiene tipo en OOS no es firma.

**Cómo se lee una anotación:**

- **Por lo que el nombre es, no por cómo se escribe** (§4.1). `date` es `Date` si es
  `datetime.date` —`from datetime import date`, o `import datetime` y `datetime.date`, con alias o
  sin él—; `int`, `float`, `str`, `bool` y `list` son los del lenguaje salvo que el módulo los
  tape. Un nombre sin ligar, o ligado a otra cosa —una clase del fichero que se llama `date`—, es
  `OOS2043`.
- `typing` y `typing_extensions` son lo mismo. Una unión de un tipo con `None` es ese tipo,
  opcional; cualquier otra unión es `OOS2043`.
- **Entre comillas** (`"Decimal"`, `list["Linea"]`), la anotación es la expresión de dentro.
- **Cuándo**: como en el runtime (§4.10), una anotación se resuelve donde se evalúa —la de un
  parámetro o de lo que devuelve, en el `def`; la de un campo, en su clase—, así que una clase
  definida más abajo todavía no existe (`OOS2043`). Entre comillas, o con `from __future__ import
  annotations`, se resuelve al final del módulo.

### 4.7 · `output` como un valor

Desde esta versión `output` admite dos formas, para **todas** las funciones: el **mapa de campos** de
v1alpha2 (`nombre → {type, required, description}`) o **un tipo**, `{type: T}`, cuando la función
devuelve un valor sin nombre —un texto, un número, una lista—. Un mapa cuyos valores no son objetos
no es un mapa: `{type: String}` es un tipo.

En `ore diff`, cambiar el tipo de un `output` de un valor se clasifica como el de un campo (§7), con
sujeto `<función>.output`.

### 4.8 · La coherencia

Para cada fichero `.py` del paquete y cada documento `runtime: python`:

| | código |
|---|---|
| un `@function` sin ningún documento cuyo `entrypoint` lo nombre | `OOS2013` |
| un documento cuyo `entrypoint` nombra un `def` sin `@function` | `OOS2013` |
| un documento que no es el que su `@function` da (§4.3), campo a campo | `OOS2013` |
| un `@function` que no se puede derivar (§4.2, §4.4–§4.6) | `OOS2043` |
| un fichero con un `@function`, o que un `entrypoint` nombra, que no es Python del runtime: no se analiza, o usa sintaxis posterior a su versión (§4.10) | `OOS2043`, una vez por fichero |

Dónde vive el documento en el paquete no forma parte de la regla: un validador lo encuentra por su
`entrypoint`. La herramienta lo pone en `functions/<def>.yaml` del paquete, fuera del código: una
función publicada es un nombre del paquete, `<paquete>.<def>`, y no del sitio donde se escribe.

**La precedencia**, para una misma función: `OOS2042` (no está) antes que `OOS2043` (no se deriva)
antes que `OOS2013` (no es el que se deriva).

**Un paquete que no puede tener documentos** —su nombre no puede ser `namespace`, `OOS2030`— no
exige el de sus `@function`: no tienen dónde publicarse, y son código de la sesión. No es el sitio
de un proyecto: el paquete que nace con un proyecto se llama con un identificador
(`test_project`), y publica lo que hagan sus repositorios. Es un vocabulario importado
(`oos.dev`), cuyo nombre es la coordenada con la que se importa.

### 4.9 · Leer, nunca ejecutar

La derivación es **estática**: una implementación DEBE sacar la firma del texto del fichero y NO
DEBE importarlo ni ejecutarlo. Importar es correr el código del cliente —con sus efectos y sus
dependencias— dentro de quien compila, y daría una respuesta distinta en cada máquina; leer es una
función del texto.

Una implementación PUEDE negarse a leer lo que no es razonable leer —un fichero demasiado grande,
un anidamiento demasiado hondo—, como el propio CPython (más de 200 paréntesis abiertos, más de 100
niveles de sangría), y entonces es `OOS2043` en ese fichero.

### 4.10 · La versión de Python

El runtime `python` de esta versión es **Python 3.12**: su gramática, y cuándo evalúa las
anotaciones (en el `def`, salvo con comillas o `from __future__ import annotations`). La sintaxis
posterior —una t-string de 3.14, un parámetro de tipo con valor por defecto de 3.13— es Python
válido que el runtime no ejecuta: `OOS2043`. Subir la versión es una versión de OOS.

### 4.11 · La herramienta (no normativo)

`ore functions generate` escribe el documento de cada `@function` en `functions/<def>.yaml` del
paquete, y mueve allí el que nombre su `entrypoint` desde otro sitio; con los mismos bytes para la misma firma, y una primera línea de
procedencia, `# generado por ore desde <entrypoint>`, que le deja borrar el de un `@function` que
ya no existe sin tocar nunca uno escrito a mano. `--check` dice si algún documento no es el que el
código da, para el CI.

## 5. `models`

```yaml
models: [modelo/extractor, modelo/ia.chat]
```

Los modelos que el código **puede llamar**. Cada uno es `modelo/<referencia>`, y la referencia se
lee como la de `model` en [v1alpha15](../v1alpha15/00-scope.md) (una, dos o tres partes); tiene que
resolver a un `Model` (`OOS2005`).

- `models` es **solo** de `runtime: python`. Con `wasm` (sin red) o `model` (el modelo es lo que se
  ejecuta) es `OOS1004`.
- `model` y `prompt` siguen siendo **solo** de `runtime: model` (`OOS1004`, de v1alpha9).
- La regla de v1alpha10 «una función toca algo» admite `models`: sin `over`, `reads`, `effects` ni
  `models`, `OOS1004`.
- Y con `runtime: python` admite también **`input`**: una función de código puede trabajar solo
  sobre sus parámetros —`formatear(texto)`, `riesgo(importe, pais)`— sin leer la copia ni llamar a
  un modelo. La regla de v1alpha10 existía para que un documento que no declara superficie no se
  hiciera pasar por función; los parámetros **son** superficie, tipada y en el documento. Un `wasm`
  o un `model` siguen necesitando lo de antes.

**Por qué una clave y no `model`:** `model` dice qué se ejecuta; `models` dice qué se usa. Son dos
relaciones distintas con el mismo nodo, y una función de código puede usar varios.

## 6. La superficie en tiempo de ejecución

La gramática la fija; el runtime la hace cumplir. Un ejecutor conforme de `runtime: python`:

- **DEBE** dar al código solo lo que `over` y `reads` exponen, y rechazar la lectura de cualquier
  otro nombre;
- **DEBE** dejar salir de la red solo hacia lo declarado: los modelos de `models`, y nada más;
- **DEBE** llamar al `def` con la fila (si hay `over`) y con los parámetros de `input` **por su
  nombre**, ya validados contra sus tipos;
- **DEBE** cortar la invocación al pasar `limits.timeout` y darla por fallida con ese motivo. Sin
  `limits.timeout`, el plazo es del ejecutor y lo dice;
- **DEBE** devolver lo que el `def` devuelve contra `output`: un objeto con sus campos, o un valor
  de su tipo. Lo que no lo cumple es un error de **esa invocación** —de esa fila, con `over`—, con su
  motivo, y no tumba a quien la llamó.

Esto es **L2**: la suite no lo certifica (no hay datos ni red en un caso). Lo que se certifica es
lo de §3–§5.

## 7. La versión de una función, parámetro a parámetro

Una aclaración de [`v1alpha1/91-versioning`](../v1alpha1/91-versioning.md) §5 que vale para
**todas** las versiones: `input` y `output` son superficie del consumidor **parámetro a parámetro**,
como las propiedades de una entidad. El sujeto del cambio es `<función>.input.<parámetro>`,
`<función>.output.<campo>` o, con `output` de un valor, `<función>.output`.

| cambio | código | eje |
|---|---|---|
| quitar un parámetro de `input` o un campo de `output` | `OOS5001` | `CONSUMER` |
| añadir un parámetro de `input` **obligatorio**, o hacer obligatorio uno opcional | `OOS5003` | `CONSUMER` |
| estrechar el tipo de un parámetro o de lo que devuelve | `OOS5002` | `CONSUMER` |
| cambiar la unidad o la precisión de su tipo paramétrico | `OOS5010` | `CONSUMER` |
| añadir un parámetro opcional, o un campo de `output` | compatible · menor | — |
| cambiar `entrypoint`, `runtime` o el código | compatible · parche | — |

`models` no se clasifica en esta versión: qué cambia para el consumidor que una función use un
modelo más se decide cuando se mida.

## 8. Las reglas

| | código | |
|---|---|---|
| `runtime` fuera de `wasm`, `model`, `python` | `OOS1004` | |
| `runtime: python` sin `entrypoint`, o con un `entrypoint` mal formado | `OOS1004` | §3 |
| `runtime: python` en una versión anterior | `OOS1004` | el enum de v1alpha10 |
| `models` con otro runtime, o en una versión anterior | `OOS1004` · `OOS1005` | §5 |
| `model` o `prompt` con `runtime: python` | `OOS1004` | de v1alpha9 |
| sin `over`, `reads`, `effects` ni `models` —ni `input`, con `python`— | `OOS1004` | §5 |
| el fichero o el `def` del `entrypoint` no están | `OOS2042` | §3 |
| un `@function` que no se puede derivar, o un fichero que no es Python del runtime | `OOS2043` | §4, §4.10 |
| un `@function` sin documento, un documento sin `@function`, o uno que no es el que se deriva | `OOS2013` | §4.8 |
| un modelo de `models` que no resuelve | `OOS2005` | §5 |
| lo demás | lo de v1alpha10 §6 | |

## 9. Lo que la gramática no decide

- **Cómo llegan las filas y los modelos al código**: un SDK, un cliente, un contexto. Es del
  runtime.
- **Dónde corre y con qué latencia**: bajo demanda o residente es despliegue, no gramática. Una
  vista previa del código que todavía no está en un commit tampoco es gramática: no hay documento
  que cotejar.
- **Quién puede invocarla**: `authorization` (Cedar), como en v1alpha10.
- **`node` y `jvm`**: entran por esta misma regla —una función exportada marcada, su firma como
  documento derivado— cuando haya quien los ejecute.
