# OOS v1alpha31 · 01 — Las promesas de un activo

**Lo que el dueño de una copia promete de ella, y qué pasa cada vez que se refresca.**

Estado: borrador, alpha. §1–§3 y §5 son **del documento** (los comprueba el compilador); §4 y §6
son **de ejecución** (los cumple quien mantiene la copia). Las palabras **DEBE**, **NO DEBE**,
**DEBERÍA** y **PUEDE** tienen el sentido de RFC 2119.

---

## 1. Dónde se escriben

En el `spec` del activo, bajo `promises`: una lista de promesas, en el orden en que su dueño quiere
leerlas.

```yaml
apiVersion: oos.dev/v1alpha31
kind: Dataset
metadata: { name: pedidos, namespace: ventas }
spec:
  owner: team:ventas
  from: { table: neon.public.pedidos }
  freshness: 1h
  fields: { id: id, cliente: cliente, total: total, estado: estado }
  promises:
    - id: volumen
      metric: rowCount
      mustBeGreaterOrEqualTo: 900
    - id: cliente_presente
      column: cliente
      metric: nullValues
      unit: percent
      mustBeLessOrEqualTo: 1
      severity: warning
    - id: id_unico
      column: id
      metric: duplicateValues
      mustBe: 0
    - id: estado_valido
      column: estado
      metric: invalidValues
      arguments: { validValues: [pendiente, pagado, enviado, anulado] }
      mustBe: 0
      severity: warning
```

```yaml
apiVersion: oos.dev/v1alpha31
kind: MediaCollection
metadata: { name: imagenes, namespace: lago, schema: archivo }
spec:
  owner: team:data
  media: image
  formats: [jpeg, png]
  from: { objectTable: s3.fotos.objetos }
  promises:
    - id: solo_imagenes
      metric: invalidFormats
      arguments: { families: [image] }
      mustBe: 0
      severity: warning
    - id: sin_borrado_masivo
      metric: itemCountChange
      mustBeGreaterThan: -20
```

Solo admiten `promises` los activos que **se refrescan**: un `Dataset` (copiado de una fuente o de
una vista, o escrito por código) y una `MediaCollection` (mantenida o virtual: las dos listan su
origen en cada refresco). En una `View`, una `Table` o un `ObjectTable` la clave no existe
(`OOS1005`): lo que se lee en vivo no tiene refresco en el que comprobarse (`00` §3). La promesa va
en el `Dataset` o la colección que lo copia.

**La puerta es del documento.** `promises` existe desde v1alpha31. En un documento anterior es
`OOS1005`, y el remedio es subir su `apiVersion`, que para estos dos `kind` es neutro (`00` §4).

## 2. La forma de una promesa

Es la aserción del `Ruleset` (v1alpha3 [`02-ruleset`](../v1alpha3/02-ruleset.md)), de tipo
`library`, con tres cosas más. Esquema: [`promise.schema.json`](../../schemas/v1alpha31/promise.schema.json).

| Clave | | |
|---|---|---|
| `id` | **obligatoria** | Un identificador, **único en su activo** (`OOS2053`). Es lo que nombran una retención, un aviso y la consola |
| `metric` | **obligatoria** | Una métrica de la biblioteca de **su familia** (§3) |
| `column` | según la métrica | La columna que mide. **Obligatoria** en las métricas de columna, **prohibida** en las demás (§3). Tiene que ser una columna que el activo declara (`OOS2052`) |
| `arguments` | según la métrica | Lo que la métrica necesita: la lista de valores admitidos, el rango, los formatos (§3) |
| `unit` | opcional | Cómo se expresa lo medido: en unidades (`rows` en la tabular, `items` en la de objetos, por defecto) o en `percent` del total. Las métricas de cambio son siempre `percent` |
| un comparador | **exactamente uno** | `mustBe`, `mustNotBe`, `mustBeGreaterThan`, `mustBeGreaterOrEqualTo`, `mustBeLessThan`, `mustBeLessOrEqualTo`, `mustBeBetween`, `mustNotBeBetween`. Los nombres y el sentido son los de ODCS; los rangos son `[mínimo, máximo]`, cerrados. Un umbral es un entero, o un decimal **entre comillas** (`"0.5"`): sin ellas es `OOS6003`, como en todo documento |
| `severity` | opcional | `error` (*Blocking*, por defecto) o `warning` (*Warning*) (§6) |
| `description` | opcional | Para quien la lee |

Todo lo demás es `OOS1004`: una métrica que no existe o que es de la otra familia, un comparador que
falta o que sobra, un argumento que la métrica no admite, un rango con el mínimo por encima del
máximo.

## 3. La biblioteca, por familia

Una métrica **cuenta algo** de la versión que el refresco va a publicar. Lo que se compara con el
comparador es esa cuenta (o su porcentaje, con `unit: percent`).

**Tabular** (`Dataset`):

| `metric` | `column` | `arguments` | Lo que cuenta |
|---|---|---|---|
| `rowCount` | no | — | Las filas de la versión |
| `rowCountChange` | no | — | El cambio de filas respecto de la versión publicada anterior, en %: `(ahora − antes) / antes × 100`. Sin versión anterior, o con 0 filas antes, no se puede medir |
| `nullValues` | sí | — | Las filas con la columna nula |
| `missingValues` | sí | `missingValues`: la lista de valores que también cuentan como ausentes (`''`, `'N/A'`), opcional | Las filas con la columna nula o con uno de esos valores |
| `invalidValues` | sí | **uno** de `validValues` (la lista de lo admitido) o `between` (`[mínimo, máximo]`, cerrado) | Las filas cuyo valor, no nulo, queda fuera. Un nulo no es inválido: lo cuenta `nullValues` |
| `duplicateValues` | sí | — | Las filas cuyo valor, no nulo, ya apareció antes en la versión (filas no nulas − valores distintos) |

**Objetos** (`MediaCollection`): sobre los ítems **actuales** de la colección tras el refresco.

| `metric` | `arguments` | Lo que cuenta |
|---|---|---|
| `itemCount` | — | Los ítems actuales |
| `itemCountChange` | — | El cambio de ítems actuales respecto del refresco publicado anterior, en % |
| `emptyItems` | — | Los ítems de 0 bytes |
| `invalidFormats` | **uno** de `formats` (formatos, como en `spec.formats`) o `families` (las familias de v1alpha29) | Los ítems cuyo formato queda fuera |
| `invalidSizes` | `between`: `[mínimo, máximo]` en bytes | Los ítems cuyo tamaño queda fuera |
| `duplicateItems` | — | Los ítems con el mismo contenido que otro ítem actual, en otro camino |
| `lostItems` | — | Los ítems que el origen ya no puede servir (v1alpha16 [`02`](../v1alpha16/02-media-collection.md)) |

Ninguna de objetos lleva `column`.

**La columna se comprueba contra lo que el activo declara**: las claves de `fields` en una copia,
las de `columns` en uno escrito por código. Si el documento no declara ninguna de las dos (una copia
de una vista que no las enumera), el compilador no puede comprobarla, y una columna que no esté se
sabrá al medir (§6: `unknown`).

**El esquema y la frescura no son métricas.** El esquema del origen ya se compara en cada refresco
(v1alpha30 §5, capa 0), y la frescura es `freshness`, que sigue siendo la promesa de tiempo.

## 4. Solo lo que sale del refresco

Toda métrica de §3 se puede medir **sobre lo que el refresco ya lee o ya escribe**: las filas que
pasan por él, o la lista de ítems que ya compone. Una implementación:

- **NO DEBE** leer otra vez el origen, ni la versión escrita, para medir una promesa de esta versión;
- **DEBERÍA** medir solo lo que alguna promesa del activo necesita, de modo que un activo sin
  promesas no cueste nada más;
- **PUEDE** poner un tope a lo que una medida guarda en memoria (`duplicateValues`,
  `duplicateItems`). Si se pasa, la promesa es `unknown` (§6), nunca un aprobado.

## 5. `notEmptied`, la promesa de serie

Todo `Dataset` y toda `MediaCollection` tienen, sin escribirla, la promesa `notEmptied`: **una
versión sin filas (o sin ítems), cuando la anterior las tenía, no se publica**. Es la primera guarda
de base de v1alpha30 §4, con nombre y con severidad `error`.

Su dueño la puede **ablandar**, nunca quitar, declarándola con su `id` y nada más que la severidad
(y, si quiere, la descripción):

```yaml
  promises:
    - id: notEmptied
      severity: warning
      description: el origen se vacía cada noche antes de recargarse
```

Una promesa con `id: notEmptied` que lleve `metric`, `column`, `arguments`, `unit` o un comparador
es `OOS1004`.

## 6. Qué pasa al refrescar

Antes de publicar una versión (v1alpha30 §4), quien mantiene la copia **DEBE** comprobar cada
promesa del activo, también `notEmptied`. Cada una da uno de tres resultados:

| Resultado | Cuándo |
|---|---|
| `pass` | Se midió, y cumple |
| `fail` | Se midió, y no cumple |
| `unknown` | No se pudo medir: la columna no está en lo escrito, se pasó el tope de memoria, una métrica de cambio sin versión anterior |

Y entonces:

- **Una `error` que da `fail` retiene el refresco**: no se publica, y el intento queda `held` con la
  promesa como guarda (`refresh-held`, con `guard` = su `id`). Se sirve la última buena.
- **Una `warning` que da `fail` no retiene**: se publica, con el motivo `guard-warning` y su `guard`.
- **`unknown` no retiene ni cambia el estado** del activo (v1alpha30 §2). **DEBE** enseñarse donde
  se enseñan las promesas, con su porqué. Una promesa que no se pudo medir no es un aprobado: no se
  puede contar como `pass` en ningún resumen.

Lo escrito por código (un `Dataset` que escribe un `Transform`, o una escritura directa) se comprueba
igual, al publicar lo escrito: si una `error` falla, lo escrito queda retenido y quien escribió lo
sabe con la promesa, lo medido y lo esperado.

Quien mantiene la copia **DEBE** guardar con cada intento el resultado de cada promesa: su `id`, el
resultado, lo medido y lo esperado. Y **PUEDE** ofrecer publicar lo retenido por decisión expresa de
quien responde del activo (v1alpha30 §4).

## 7. Conformidad

Los casos de esta versión (`conformance/v1alpha31`) comprueban §1–§3 y §5 sobre documentos:

- **válidos:** un `Dataset` copiado con promesas de las cuatro métricas de columna; un `Dataset`
  escrito por código; una `MediaCollection` con promesas de objetos; `notEmptied` ablandada;
- **inválidos:** `promises` en un documento de v1alpha30 (`OOS1005`), en una `View` (`OOS1005`),
  una métrica de objetos en un `Dataset` (`OOS1004`), sin comparador (`OOS1004`), con dos
  (`OOS1004`), una columna que el activo no declara (`OOS2052`) y dos promesas con el mismo `id`
  (`OOS2053`).

§4 y §6 se comprueban ejecutando (v1alpha30 §7).
