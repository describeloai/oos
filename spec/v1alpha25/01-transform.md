# 01 · Transform — el código que produce un dataset

**Estado:** borrador. Parte de OOS v1alpha25. Aplica la regla de
[`v1alpha18/01-la-funcion-de-codigo`](../v1alpha18/01-la-funcion-de-codigo.md) §4 —el código es la
fuente, el documento se deriva leyendo y se coteja— a un `kind` nuevo, y nombra el hueco que
[`v1alpha12/01-dataset`](../v1alpha12/01-dataset.md) §2 dejó: *«No es el trabajo que lo escribió.»*

---

## 1. Naturaleza

> **Un `Transform` es el productor declarado de un dataset escrito: código, en un commit, que lee
> unas entradas y escribe una salida. Lo que lee y lo que escribe se leen en su documento sin
> ejecutarlo.**

Quien programa escribe el código —un `def` marcado con `@transform`, o una sentencia SQL que
escribe—; el documento `Transform` **se deriva** de él, en el mismo commit, y lo coteja el
compilador (`OOS2013`). Es un artefacto generado, como el `Function` de un `@function`.

**Su identidad es su salida.** Una salida tiene un solo productor (§6), así que el nombre de lo
que escribe nombra al `Transform` sin ambigüedad: se pide construir `ventas.resumen`, no «el
transform `resumen`». Por eso no es un activo con nombre propio en un catálogo: lo que se ve es el
dataset, y el dataset dice quién lo produce.

Lo que el árbol gana con él, sin ejecutar nada: qué produce cada código, qué alimenta a qué, si dos
códigos escriben lo mismo, si el grafo vuelve sobre sí, y la etiqueta que baja por él (§7).

## 2. Qué **no** es

- **No es una `Function`.** Una función se invoca bajo demanda, devuelve un valor o propone efectos
  sobre la copia; un transform se **construye** y escribe un dataset. No lleva `input`, `output`,
  `effects`, `endorsements` ni `authorization`.
- **No es un `Dataset`.** El dataset es lo que se tiene —sus columnas, lo que admite (`changes`), su
  historia—; el transform es quien lo escribe. Lo que una salida admite lo declara su `Dataset`, no
  el `Transform`: el modo va en cada escritura.
- **No es una `View`.** Una vista es la pregunta, sin bytes; `create view` produce una `View`.
- **No es un `Dataset` mantenido.** Uno con `from` lo llena el sistema cumpliendo su plan; no tiene
  productor de código (`OOS2046`).
- **No es cuándo.** Cuándo se construye —una hora, el cambio de una entrada— no es del código y no
  está en el documento.
- **No es un build.** Las ejecuciones, su estado y lo que escribieron son del puntero de la salida
  (v1alpha12 §8), no del documento.

## 3. Anatomía

Lo que se escribe, en Python:

```python
# packages/ventas/etl/transforms/resumen.py
from ore import transform, over, write

PEDIDOS = "ventas.pedidos"


@transform(inputs=[PEDIDOS, "ventas.clientes"], output="ventas.resumen")
def resumen():
    """El total por país."""
    return write("ventas.resumen", over(PEDIDOS), mode="overwrite")
```

o en SQL:

```sql
-- packages/ventas/etl/transforms/resumen.sql
CREATE OR REPLACE DATASET ventas.resumen AS
SELECT c.pais, sum(p.importe) AS total
FROM ventas.pedidos p JOIN ventas.clientes c USING (cliente_id)
GROUP BY c.pais
```

Y lo que se deriva:

```yaml
# derivado por ore desde etl/transforms/resumen.py:resumen · se edita el código, no este fichero
apiVersion: oos.dev/v1alpha25
kind: Transform
metadata:
  name: ventas__resumen
  namespace: ventas
  description: El total por país.
spec:
  runtime: python
  entrypoint: etl/transforms/resumen.py:resumen
  inputs: [ventas.pedidos, ventas.clientes]
  output: ventas.resumen
```

## 4. Las claves

| clave | | |
|---|---|---|
| `metadata.name` | **obligatoria** | la salida con `__` por separador: `<base>__<nombre>` en `default`, `<base>__<schema>__<nombre>` en otro (§5.3). No es un nombre que nadie elija |
| `metadata.namespace` | **obligatoria** | el paquete donde está el código |
| `metadata.description` | opcional | §5.3 |
| `spec.runtime` | **obligatoria** | `python` o `sql` |
| `spec.entrypoint` | **obligatoria** | `python`: `<ruta>.py:<def>`; `sql`: `<ruta>.sql:<n>`, la sentencia `n`-ésima del fichero, desde 1. La ruta, desde la carpeta del paquete |
| `spec.inputs` | **obligatoria** | lista, puede ser vacía, sin repetidos: lo que el código lee. Cada nombre, una `Table`, una `View`, un `Dataset` o una `MediaCollection` (`OOS2018`) |
| `spec.output` | **obligatoria** | lo que el código escribe: un `Dataset` escrito o una `MediaCollection` escrita, o un nombre que todavía no resuelve (§6) |
| `spec.owner` | opcional | quien responde (v1alpha21 `01`); el documento que nace lleva el de quien lo guarda |

Los nombres, como en todo el árbol (v1alpha13): la forma corta, `<base>.<nombre>` en `default` y
`<base>.<schema>.<nombre>` en otro. **No admite** —y es `OOS1005`— `changes`, `schedule`,
`labels`, `columns`, `input`, `output` como mapa, `effects`, `metadata.schema`: un transform no
vive en un schema; vive con su código.

## 5. El documento se deriva del código

### 5.1 · En Python: `@transform`

Un `def` del **nivel superior** de un `.py` del paquete con un decorador que **es**
`ore.transform`, resuelto como v1alpha18 §4.1 resuelve `ore.function`. Sus argumentos, por nombre:

| argumento | en el documento |
|---|---|
| `inputs=[…]` | `spec.inputs`, en su orden |
| `output=…` | `spec.output` |

Cada valor se lee sin ejecutar, y vale si es:

- una **cadena literal**;
- un **nombre del módulo ligado una sola vez**, en el nivel superior y antes del `def`, a una cadena
  literal (`PEDIDOS = "ventas.pedidos"`);
- **`ore.collection(<cadena>)`**, con la cadena como en las dos anteriores: nombra la colección.

Cualquier otra cosa —una concatenación, una llamada, un nombre ligado dos veces o en un `def`—, un
argumento que no es uno de estos dos, o que falte uno, es `OOS2043`. `inputs` que no es una lista,
también.

### 5.2 · En SQL: la sentencia que escribe

Un `.sql` del paquete da un transform por cada sentencia que **escribe datos**:

| sentencia | la salida |
|---|---|
| `create or replace dataset <d> as select …` | `<d>` |
| `insert into <d> select …` | `<d>` |
| `insert or replace into <d> select …` | `<d>` |
| `create or replace media collection <c> media … formats (…) as select …` | `<c>` |

`spec.inputs` es lo que lee la consulta, en el orden en que aparece por primera vez. No son
transforms la `select` que no escribe, `create view` ni `create materialized view` (producen una
`View`, v1alpha14), ni lo que crea algo vacío (`create database`, `create schema`,
`create dataset (…)`, `create media collection` sin `as`).

La última fila (añadida el 2026-10-08, ORE 0049 B10) es **ficheros que dan ficheros**: la consulta
da una fila por fichero de `<c>`, que es una `MediaCollection` escrita (v1alpha19) —por nacer, o
existente y sin `from`—. Cómo se calcula (ítem a ítem, con su registro) es de la plataforma; aquí
sólo cuenta que la sentencia escribe `<c>` y lee lo que lee. Sólo añade un transform donde antes
el `.sql` no se analizaba (`OOS2043`), así que ningún árbol que compilaba deja de hacerlo.

Un fichero que no se puede analizar es `OOS2043`, una vez por fichero.

### 5.3 · El documento

| campo | de dónde |
|---|---|
| `apiVersion` | `oos.dev/v1alpha25` |
| `metadata.name` | `spec.output` con cada `.` cambiado por `__` |
| `metadata.namespace` | el paquete |
| `metadata.description` | Python: la primera línea no vacía de la *docstring*; SQL: no está |
| `spec.runtime`, `entrypoint`, `inputs`, `output` | §4, §5.1, §5.2 |

### 5.4 · La coherencia

Para cada `.py` y `.sql` del paquete y cada documento `Transform`:

| | código |
|---|---|
| el `entrypoint` no está: el fichero no existe, no define ese `def` en su nivel superior, o no tiene esa sentencia | `OOS2042` |
| un transform que no se puede derivar (§5.1, §5.2) | `OOS2043` |
| un transform del código sin documento que lo nombre; un documento cuyo `entrypoint` no es un transform; un documento que no es el que el código da (§5.3), campo a campo | `OOS2013` |

La precedencia, para un mismo transform: `OOS2042` antes que `OOS2043` antes que `OOS2013`. Un
`Transform` **siempre** se deriva: no hay forma escrita a mano.

Dónde vive el documento en el paquete no forma parte de la regla: un validador lo encuentra por su
`entrypoint`. Leer, nunca ejecutar: v1alpha18 §4.9, tal cual.

## 6. Lo que resuelve

- **Las entradas** resuelven a lo que se puede leer (§4) **o a la salida de otro `Transform` del
  árbol**, aunque esté por nacer: así se encadena un pipeline antes de su primer build. Una que no
  resuelve a nada de eso, `OOS2018`.
- **La salida, si resuelve**, es un `Dataset` **escrito** (con `columns`, sin `from`) o una
  `MediaCollection` **escrita** (sin `from`); cualquier otra cosa es `OOS2046`. **Si no resuelve,
  está por nacer**: el código todavía no la ha escrito, y la primera escritura la registra. No es
  un error: sus columnas no se saben antes de ejecutar, y un `Dataset` escrito las exige.
- **Un solo productor por salida**: dos `Transform` del árbol con la misma `output` es `OOS2047`,
  en los dos.
- **Sin ciclos**: la salida entre sus propias entradas, o un camino de vuelta por las aristas
  `inputs → output` de los transforms y los `from` de los datasets mantenidos, es `OOS2019`. Leer
  lo que uno mismo escribió —un incremental— no se declara como entrada.

## 7. El flujo

Una salida escrita por un transform **lleva el join de lo que llevan sus entradas**, en cada
columna, como un `Dataset` escrito con `derivedFrom` (v1alpha12 §5): las `inputs` son lo que el
código declara leer, y se saben **antes** de la primera ejecución. Con eso, quien lee la salida
—una vista, otro dataset, una entidad, una función— ve su carga al compilar, y las reglas de
`04-flow` se aplican sin cambio (`OOS4001`, `OOS4002`, `OOS4011`). No hay código nuevo: el
conducto es el de siempre, y el transform es una arista más por la que baja la etiqueta.

## 8. Las reglas

| | código |
|---|---|
| falta `metadata.name`, `namespace`, `runtime`, `entrypoint`, `inputs` u `output`; `runtime` fuera de `python`/`sql`; `entrypoint` sin la forma de su runtime; `inputs` con repetidos | `OOS1004` |
| una clave que no es de aquí (`changes`, `schedule`, `labels`, `metadata.schema`…) | `OOS1005` |
| `kind: Transform` en v1alpha24 o antes | `OOS1003` |
| una entrada que no resuelve | `OOS2018` |
| la salida entre las entradas; un ciclo por transforms y mantenidos | `OOS2019` |
| el `entrypoint` no está | `OOS2042` |
| no se deriva | `OOS2043` |
| no es el que el código da; sin documento; documento sin código | `OOS2013` |
| la salida resuelve a algo que no es un `Dataset` ni una `MediaCollection` escritos | `OOS2046` |
| dos transforms con la misma salida | `OOS2047` |
| la salida lleva lo que su conducto niega | `OOS4001`, `OOS4002`, `OOS4011` |

## 9. Lo que la gramática no decide

**Dónde vive el documento (no normativo).** La herramienta de referencia lo escribe junto al
código, no en el paquete: en `<repositorio>/pipeline/<salida>.yaml`, con `<repositorio>` la primera
carpeta del `entrypoint` y `<salida>` la forma corta de la salida. Una primera línea de procedencia
le deja borrar el de un transform que ya no existe.

**Construirlo.** Correr el código del commit y escribir una transacción en la salida, con la
procedencia `Transform@commit`, es de la implementación; también cuándo, en qué orden y quién puede.

**Lo que se escribe de verdad.** El documento dice lo que el código **declara**; que en ejecución
no lea ni escriba otra cosa lo hace cumplir quien lo ejecuta, como la superficie de una función
(v1alpha18 §6).

**Otros lenguajes.** `jvm` y `node` entran por esta misma regla cuando su declaración se pueda leer
sin ejecutar.
