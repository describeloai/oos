# 01 · La función de TypeScript — `runtime: node`

**Estado:** borrador. Abre a TypeScript la regla de
[v1alpha18 `01`](../v1alpha18/01-la-funcion-de-codigo.md) —**se escribe el código; el documento
`Function` se deriva de él y se coteja**— con la forma que el lenguaje tiene para decir «esto es lo
que este módulo ofrece»: su **exportación por defecto**. Lo que no se dice aquí es lo de v1alpha18
`01` (§1 la naturaleza, §5 `models`, §7 la versión parámetro a parámetro), lo de v1alpha20 `01` §4–§5
(las estructuras, la referencia a un ítem) y lo de v1alpha21 `01` §4 (`owner` no sale del código).

---

## 1. Por qué no un decorador

TypeScript no decora una función suelta: un decorador solo se aplica a una clase y a sus miembros.
Copiar `@function` obligaría a envolver cada función en una clase que no significa nada. El estándar
de la industria para funciones de TypeScript —un fichero por función, que la **exporta por defecto**,
y su configuración como un **objeto exportado** al lado— ya es una marca explícita y se lee sin
ejecutar. Es la que se adopta:

```ts
// packages/ventas/facturacion/functions/quoteOrder.ts
import type { Decimal, Money } from "ore";

export const config = { reads: ["ventas.pedidos"], timeout: "30s" };

/** El total de un pedido, con su descuento. */
export default async function quoteOrder(orderId: string, discount: Decimal<5, 2> = "0"): Promise<Money<"EUR", 2>> {
  …
}
```

```yaml
apiVersion: oos.dev/v1alpha23
kind: Function
metadata:
  name: quoteOrder
  namespace: ventas
  description: El total de un pedido, con su descuento.
spec:
  runtime: node
  entrypoint: facturacion/functions/quoteOrder.ts
  reads: [ventas.pedidos]
  input:
    orderId: { type: String, required: true }
    discount: { type: 'Decimal<5, 2>' }
  output: { type: 'Money<EUR, 2>' }
  limits: { timeout: 30s }
```

## 2. `runtime: node` y su `entrypoint`

`entrypoint` es **obligatorio** con `runtime: node`, y es `<ruta>.ts`: la ruta del fichero desde
**la carpeta del paquete**, con `/`, sin `..` y sin `/` inicial (como v1alpha18 §3). El fichero
**es** la función: no hay `:<nombre>`, porque lo que se publica es su exportación por defecto.

La forma mal escrita es `OOS1004`. Bien escrita, y:

| | código |
|---|---|
| el fichero no existe en el paquete | `OOS2042` |
| el fichero no tiene `export default function` | `OOS2042` |

## 3. Qué es una función

**Un fichero `.ts` del paquete con un directorio `functions` en su ruta, cuya exportación por
defecto es una declaración de función.** El directorio puede tener subdirectorios
(`functions/billing/quoteOrder.ts`).

- **La exportación** es `export default function <nombre>(…) {…}` o `export default async function
  <nombre>(…) {…}`, en el nivel superior. `<nombre>` es un identificador de OOS
  (`^[a-zA-Z][a-zA-Z0-9_]*$`) y es **el nombre del fichero** sin `.ts`. Uno distinto, una función sin
  nombre, una flecha, una clase o un valor exportados por defecto, o
  `export { f as default }`: `OOS2043`. Un fichero de `functions/` **sin** `export default` no es una
  función: es un módulo de ayuda, como cualquier otro.
- **No son funciones** los `.d.ts`, ni los ficheros de prueba `*.test.ts` y `*.spec.ts`, ni un `.ts`
  fuera de un directorio `functions`, ni otra extensión (`.js`, `.mts`, `.tsx`).
- Una función de TypeScript y una de Python se llaman igual en el catálogo, `<paquete>.<nombre>`:
  dos con el mismo nombre en un paquete son dos documentos con la misma identidad (`OOS2035`).

## 4. `config`

`export const config = { … }` en el nivel superior del mismo fichero, **opcional**. Es un objeto
**literal** con las claves del decorador de Python (v1alpha18 §4.2), y los mismos valores: una
cadena o una lista de cadenas, literales.

| clave | en el documento |
|---|---|
| `over: "<vista>"` | `spec.over` |
| `reads: ["<vista>", …]` | `spec.reads` |
| `models: ["<referencia>", …]` | `spec.models`, cada una como `modelo/<referencia>` (sin repetir el prefijo) |
| `timeout: "<duración>"` | `spec.limits.timeout` |

Valen las formas que TypeScript borra sin cambiar el valor: `{ … } as const` y
`{ … } satisfies Config` (con `Config` de §6.3). Una clave que no es una de estas, un valor que no es
literal (una variable, una plantilla con `${}`, una llamada, un *spread*), un `config` que no es
`const` o que no se exporta en su declaración: `OOS2043`.

## 5. El documento

| campo | de dónde |
|---|---|
| `apiVersion` | `oos.dev/v1alpha23`; con `owner`, también (v1alpha21 `01` §4 vale tal cual) |
| `metadata.name` | el nombre de la función, que es el del fichero |
| `metadata.namespace` | el nombre del paquete |
| `metadata.description` | la primera línea no vacía del comentario JSDoc (`/** … */`) **inmediatamente** anterior a `export default`, sin los `*` de margen ni las etiquetas `@…`; sin él, no está |
| `spec.runtime` | `node` |
| `spec.entrypoint` | `<ruta del fichero desde la carpeta del paquete>` |
| `spec.over`, `reads`, `models`, `limits.timeout` | §4 |
| `spec.input` | §6.1 |
| `spec.output` | §6.2 |

Una función de TypeScript declara siempre `v1alpha23`: es la primera versión con `runtime: node`.

### 5.1 · Los parámetros

- **Con `over`**, el primero es **la fila**: sin valor por defecto ni `?`; su nombre es libre, su
  anotación no se lee y no entra en `input`. Sin él, `OOS2043`.
- **Los demás llevan anotación de tipo** (§6). Sin ella, `OOS2043`.
- **Opcional** es tener valor por defecto, llevar `?` (`moneda?: string`) o anotarse `T | null` /
  `T | undefined`.
- Ni el resto (`...args`) ni la desestructuración (`{ a, b }: Pedido`): un parámetro sin nombre no es
  superficie (`OOS2043`). Tampoco `this`.

### 5.2 · Lo que devuelve

La anotación de retorno es **obligatoria**: TypeScript la infiere, y una inferencia no se lee sin
el compilador (§8). Con `async`, es `Promise<T>` y lo que se lee es `T`. Sin ella, o `void`,
`undefined`, `null`, `never` o `Promise<void>`: `OOS2043`.

- **un tipo de §6** → `output: { type: T }`, un valor (v1alpha18 §4.7);
- **un objeto** (§6.4) → `output` como el mapa de sus campos, `required: true` en los que no son
  opcionales. Es la `@dataclass` de Python.

## 6. Los tipos

### 6.1 · La tabla

| TypeScript | OOS |
|---|---|
| `string` | `String` |
| `boolean` | `Boolean` |
| `number` | `Float` |
| `Integer`, `bigint` | `Integer` |
| `Decimal` · `Decimal<p, s>` | `Decimal` · `Decimal<p, s>` |
| `Money<"EUR", 2>` · `Quantity<"km", 1>` | `Money<EUR, 2>` · `Quantity<km, 1>` |
| `LocalDate` | `Date` |
| `LocalTime` | `Time` |
| `LocalDateTime` | `DateTime` |
| `Date` | `DateTimeTz` |
| `Uint8Array` | `Opaque` |
| `Media<"base.schema.coleccion">` | `Media<base.schema.coleccion>` |
| un objeto de §6.4 | `Struct<campo: T, …>` |
| `T[]`, `Array<T>`, `readonly T[]`, `ReadonlyArray<T>` | `list<T>`, sin listas dentro (v1alpha18 §4.6) |
| `T \| null`, `T \| undefined` | `T`, y el parámetro o el campo es opcional |

`Integer`, `Decimal`, `Money`, `Quantity`, `LocalDate`, `LocalTime`, `LocalDateTime`, `Media` y
`Config` son los del SDK, el módulo **`ore`** (§6.3). Los demás son los del lenguaje.

Cualquier otro —`any`, `unknown`, `object`, `Record<…>`, `Map`, `Set`, una tupla, un `enum`, una
clase, una unión que no es de un tipo con `null`/`undefined` (también una de literales,
`"a" | "b"`), un tipo de otra biblioteca o de otro fichero— es `OOS2043`.

### 6.2 · Por qué estos nombres

- **Un número de JavaScript es un `double`.** `number` es `Float`, y un entero lo dice: `Integer`
  es un `number` que el contrato exige **entero y exacto** (`Number.isSafeInteger`, ±2⁵³−1), y
  `bigint` es el entero de 64 bits entero. Sin esa distinción, un identificador por encima de 2⁵³
  cambia de valor en silencio en la frontera.
- **Un decimal nunca es un `number`.** `Decimal`, `Money` y `Quantity` viajan como una **cadena con
  sus cifras** (`"41.31"`): el valor es exacto y la aritmética, de la biblioteca que se elija.
- **Una fecha sin zona no es un `Date`.** Un `Date` de JavaScript es un **instante**, y por eso es
  `DateTimeTz`. Una fecha, una hora o una fecha y hora **de calendario**, sin zona, son cadenas ISO:
  `LocalDate` (`"2026-10-03"`), `LocalTime` (`"08:30:15"`), `LocalDateTime`
  (`"2026-10-03T08:30:00"`). Convertir una de ellas a un `Date` es suponer una zona, y eso lo decide
  el código, no la frontera.

### 6.3 · El SDK

Los nombres de §6.1 son **alias** de tipos que el lenguaje ya tiene —`Integer` es `number`;
`Decimal`, `Money`, `Quantity` y los `Local…` son `string`; `Media` es la referencia a un ítem
(v1alpha20 `01` §5)—: escribir `const d: LocalDate = "2026-10-03"` no pide conversión. La
derivación los lee **por su nombre y su origen**; quien comprueba los valores es el contrato (§7).

Se leen **por lo que son**, como en v1alpha18 §4.1: `import type { Money } from "ore"`,
`import { Money } from "ore"`, con alias (`{ Money as M }`) o como espacio de nombres
(`import type * as ore from "ore"` y `ore.Money`). Un `Money` que el fichero declara, importa de otro
sitio o tapa no es el de `ore`. Y los del lenguaje (`string`, `Date`, `Uint8Array`, `Array`,
`Promise`) son los globales salvo que el fichero declare o importe uno con ese nombre.

Los argumentos de `Decimal<p, s>`, `Money<u, s>`, `Quantity<u, s>` y `Media<c>` son **literales**:
`p` y `s` enteros, con `1 ≤ p ≤ 38` y `0 ≤ s ≤ p`; la unidad y la colección, cadenas. Fuera de rango,
o no literales: `OOS2043`. Una colección que no está: `OOS2018`.

### 6.4 · Los objetos

Un objeto es, **en el mismo fichero**:

- un `interface` del nivel superior: sus propiedades en orden; `extends` de otro `interface` del
  fichero pone las de él delante, y una que se redefine cambia en su sitio;
- un `type X = { … }` del nivel superior;
- un literal de objeto en la anotación (`: { total: Money<"EUR", 2>; nota?: string }`).

Cada propiedad lleva un tipo de §6.1; `campo?: T` o `T | null` es opcional. Un método, una firma de
índice (`[k: string]: T`), una propiedad calculada, un `extends` de algo que no es un `interface`
del fichero, un genérico o un objeto que se contiene a sí mismo: `OOS2043`.

Un objeto **como parámetro** o dentro de otro es `Struct<…>` (v1alpha20 `01` §4); **como vuelta**, el
mapa de `output` (§5.2). `readonly` no cambia nada.

## 7. Los valores al invocar

Lo que la invocación lleva en JSON, y lo que la función recibe y devuelve:

| OOS | JSON | TypeScript |
|---|---|---|
| `String`, `Boolean` | cadena, booleano | `string`, `boolean` |
| `Float` | número | `number` |
| `Integer` | número entero, o cadena con sus cifras | `number` exacto con `Integer`; `bigint` con `bigint` |
| `Decimal…`, `Money…`, `Quantity…` | número o cadena, con como mucho los decimales de su precisión | `string` con sus cifras |
| `Date`, `Time`, `DateTime` | ISO 8601 sin zona: `"2026-10-03"`, `"08:30:15"`, `"2026-10-03T08:30:00"` | `string`, tal cual |
| `DateTimeTz` | ISO 8601 **con** zona | `Date` |
| `Opaque` | base64 | `Uint8Array` |
| `Struct<…>`, `list<…>` | objeto con esos campos y ninguno más, lista | objeto, `Array` |
| `Media<c>` | la referencia (`uri`, `collection`, `path`, `version`, …) | el objeto de la referencia |

Un opcional que no llega es `undefined` con `?` o con valor por defecto, y `null` con `T | null`.
En lo que devuelve, `undefined` y `null` son lo mismo: sin valor. Un `Integer` que devuelve un
`number` no exacto, un decimal con más cifras de las de su precisión o un `Date` inválido no cumplen
`output`.

## 8. Leer, nunca ejecutar · y qué TypeScript

La derivación es **estática** (v1alpha18 §4.9): sale del texto del fichero, sin importarlo, sin
ejecutarlo y **sin el compilador de TypeScript**: no se infiere nada, se lee lo escrito. Por eso la
firma es explícita.

El runtime `node` de esta versión es **Node.js 24**, que ejecuta TypeScript **borrando los tipos**,
sin compilarlo. La gramática es la de **TypeScript 5.8 con solo sintaxis borrable**
(`--erasableSyntaxOnly`): un `enum`, un `namespace` con valores, las propiedades de parámetro de un
constructor, `import x = require(…)` o `export =` no se borran, se compilan, y el runtime no los
ejecuta. Un fichero de una función con cualquiera de ellos, que no se analiza, o con sintaxis
posterior: `OOS2043`, una vez por fichero. Subir la versión es una versión de OOS.

## 9. La coherencia

Para cada fichero de función (§3) y cada documento `runtime: node`, lo de v1alpha18 §4.8 tal cual:
un fichero sin documento cuyo `entrypoint` lo nombre, un documento cuyo `entrypoint` nombra un
fichero que no es una función, o uno que no es el que el código da, campo a campo, `OOS2013`; lo que
no se deriva, `OOS2043`. La misma precedencia: `OOS2042` antes que `OOS2043` antes que `OOS2013`. Y
el mismo paquete que no puede tener documentos no los exige.

La herramienta (no normativo) los escribe donde los de Python: `functions/<nombre>.yaml` del
paquete, con su línea de procedencia.

## 10. `models` y «una función toca algo»

`models` es de `runtime: python` **y de `node`**, con todo lo de v1alpha18 §5; y con `node`, `input`
cuenta como superficie igual que con `python`. Lo de v1alpha18 §6 —la superficie en tiempo de
ejecución: solo lo declarado, la red cerrada salvo los modelos, los parámetros por su nombre y
validados, el plazo, lo devuelto contra `output`— vale para `node` palabra por palabra (L2).

## 11. Las reglas

| | código | |
|---|---|---|
| `runtime` fuera de `wasm`, `model`, `python`, `node` | `OOS1004` | |
| `runtime: node` sin `entrypoint`, o con uno que no es `<ruta>.ts` | `OOS1004` | §2 |
| `runtime: node` en una versión anterior | `OOS1004` | |
| `model` o `prompt` con `runtime: node` | `OOS1004` | de v1alpha9 |
| el fichero del `entrypoint` no está, o no exporta por defecto una función | `OOS2042` | §2 |
| una función que no se puede derivar, o un fichero que no es TypeScript del runtime | `OOS2043` | §3–§8 |
| una función sin documento, un documento sin función, o uno que no es el que se deriva | `OOS2013` | §9 |
| dos funciones del paquete con el mismo nombre | `OOS2035` | §3 |
| lo demás | lo de v1alpha18 `01` §8 | |

## 12. Lo que la gramática no decide

- **Las dependencias.** Lo que el código importa de npm es del entorno del paquete
  (`package.json`), como `pyproject.toml` para Python: no es firma.
- **Las importaciones entre ficheros.** Node las resuelve con su extensión (`./util.ts`); cómo es
  del runtime. Lo que la firma usa vive en el fichero de la función (§6.4).
- **Cómo llegan las filas, los modelos y los datos al código**: el SDK. Es del runtime.
- **Dónde corre**: bajo demanda, residente o en un *isolate* es despliegue, no gramática.
