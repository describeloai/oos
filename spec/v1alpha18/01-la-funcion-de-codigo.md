# 01 · La función de código — `runtime: python`

**Estado:** borrador. Extiende [`v1alpha10/01-function`](../v1alpha10/01-function.md) con un
runtime y una clave, y conserva su naturaleza entera: lo que una función lee es la unión de lo que
declara, lo que devuelve es su `output`, y lo que causa, sus `effects`. Lo que no se dice aquí, es
lo de v1alpha10 (con `metadata.schema` desde v1alpha13).

---

## 1. Naturaleza

> **Una función de código es un `def` de un repositorio que un documento promueve: el documento
> es el contrato y el `def` lo cumple.**

El código vive en el paquete, junto a lo demás, y **por sí solo no es una función**: un fichero
`.py` de un repositorio se ejecuta, lee y escribe por sus frutos, pero no tiene superficie que un
consumidor pueda nombrar. Pasa a tenerla cuando un `Function` lo nombra en su `entrypoint`. Esa
promoción es **explícita**: un documento escrito, revisado y versionado con el paquete. Una
herramienta puede escribirlo a partir del código, una vez; el documento no se regenera solo, porque
lo que otros consumen no puede cambiar porque alguien editó un fichero.

Y el compilador comprueba que el código **cumple** el documento: que el `def` existe y que su
cabecera es la firma. Lo comprueba **leyendo**, sin ejecutar nada: la cabecera de un `def` es
sintaxis, no comportamiento.

## 2. Anatomía

```yaml
apiVersion: oos.dev/v1alpha18
kind: Function
metadata: { name: riesgo, namespace: ventas }
spec:
  runtime: python
  entrypoint: funciones/riesgo.py:riesgo   # <ruta>.py:<def>, dentro del paquete

  over: ventas.clientes                    # una fila por llamada: el primer parámetro
  reads: [ventas.pedidos]                  # lo demás que el código puede leer
  models: [modelo/extractor]               # los modelos que el código puede llamar

  input:
    umbral: { type: Decimal, required: true }
    moneda: { type: String }               # sin `required`: opcional
  output:
    nivel: { type: String }
    total: { type: Decimal }

  limits: { timeout: 60s, memory: 2Gi }
```

```python
# packages/ventas/funciones/riesgo.py
def riesgo(cliente, umbral, moneda="EUR"):
    ...
    return {"nivel": "alto", "total": 1234.5}
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

Un `async def` no es un `def` y es `OOS2042`. Que el fichero lleve más código —imports, otras
funciones, constantes— no importa: el `entrypoint` nombra **una** función del módulo.

`source` sigue siendo opcional e informativo, como en v1alpha10; con `python`, el código fuente
**es** el `entrypoint`.

## 4. La firma: la cabecera del `def`

### 4.1 · Qué se lee

Solo la lista de parámetros del `def`: sus **nombres**, si tienen **valor por defecto**, y si hay
`*args` o `**kwargs`. Las anotaciones de tipo, los decoradores y el cuerpo **no** forman parte de la
firma: los tipos son los del documento, que es el contrato. Una implementación puede avisar cuando
una anotación contradice el tipo del documento; no es un error de compilación.

### 4.2 · Las reglas

| regla | si no |
|---|---|
| **con `over`**, el primer parámetro es **la fila**: posicional y sin valor por defecto; su nombre es libre | `OOS2043` |
| **sin `over`**, no hay fila: el `def` se llama una vez, sobre el conjunto entero de `reads` | — |
| los demás parámetros son **exactamente** las claves de `input`: ni uno más, ni uno menos; el orden no importa | `OOS2043` |
| un parámetro de `input` obligatorio **no** tiene valor por defecto en el `def`; uno opcional **sí** | `OOS2043` |
| ni `*args` ni `**kwargs`: la superficie es cerrada | `OOS2043` |

El parámetro solo-por-nombre (`*, moneda="EUR"`) vale como cualquier otro.

### 4.3 · `required` ausente es `false`

Vale para `input` y `output` de **todas** las versiones, y nadie lo había escrito: un parámetro sin
`required` es opcional. En `output`, `required: true` dice que el valor no puede faltar en lo que
la función devuelve.

### 4.4 · Lo que devuelve

Con `output` declarado, el `def` devuelve **un objeto con las claves de `output`**. Es una regla
del runtime, no de la compilación: una devolución que no la cumple es un error de **esa
invocación**, con su motivo, y no tumba a quien la llamó.

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
  `limits.timeout`, el plazo es del ejecutor y lo dice.

Esto es **L2**: la suite no lo certifica (no hay datos ni red en un caso). Lo que se certifica es
lo de §3–§5.

## 7. La versión de una función, parámetro a parámetro

Una aclaración de [`v1alpha1/91-versioning`](../v1alpha1/91-versioning.md) §5 que vale para
**todas** las versiones: `input` y `output` son superficie del consumidor **parámetro a parámetro**,
como las propiedades de una entidad. El sujeto del cambio es `<función>.input.<parámetro>` o
`<función>.output.<campo>`.

| cambio | código | eje |
|---|---|---|
| quitar un parámetro de `input` o un campo de `output` | `OOS5001` | `CONSUMER` |
| añadir un parámetro de `input` **obligatorio**, o hacer obligatorio uno opcional | `OOS5003` | `CONSUMER` |
| estrechar el tipo de un parámetro | `OOS5002` | `CONSUMER` |
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
| la cabecera del `def` no es la firma | `OOS2043` | §4 |
| un modelo de `models` que no resuelve | `OOS2005` | §5 |
| lo demás | lo de v1alpha10 §6 | |

## 9. Lo que la gramática no decide

- **Cómo llegan las filas y los modelos al código**: un SDK, un cliente, un contexto. Es del
  runtime.
- **Dónde corre y con qué latencia**: bajo demanda o residente es despliegue, no gramática.
- **Quién puede invocarla**: `authorization` (Cedar), como en v1alpha10.
- **`node` y `jvm`**: entran por esta misma regla —un `entrypoint` que nombra una función
  exportada, su cabecera como firma— cuando haya quien los ejecute.
