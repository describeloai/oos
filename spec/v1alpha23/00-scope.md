# OOS v1alpha23 — alcance

**Estado:** borrador de alcance. Gobierna los documentos que declaran su `apiVersion`, y es
**alpha**: sin garantías de compatibilidad.

| | |
|---|---|
| `00-scope` | **este documento** — qué entra, qué no, y por qué |
| [`01-la-funcion-de-typescript`](01-la-funcion-de-typescript.md) | `runtime: node`: un fichero `.ts` de `functions/` que **exporta por defecto** una función, con su `config` al lado, y su documento `Function` **derivado** del código y cotejado con él |

Esta versión **cambia un `kind`** —`Function`—: abre un runtime, `node`. **No añade códigos**: el
fichero o la exportación que no están son `OOS2042`, lo que no se deriva es `OOS2043`, el documento
que no es el que el código da es `OOS2013` —los tres de v1alpha18, ahora también de TypeScript— y dos
funciones con el mismo nombre son `OOS2035`. Los demás `kind` no cambian.

---

## 1. La tesis

| versión | la función de código |
|---|---|
| v1alpha18 | **Python**: un `def` marcado con `@function`; el documento se deriva de su firma |
| v1alpha20 | la firma de Python habla todos los tipos de OOS con valor |
| **v1alpha23** | **TypeScript, por la misma regla**: la exportación por defecto de un fichero de `functions/`; el documento se deriva de su firma |

v1alpha18 lo dejó escrito: `node` y `jvm` «entran por esta misma regla —una función exportada
marcada, su firma como documento derivado— cuando haya quien los ejecute». Ya lo hay: la plataforma
que implementa OOS ejecuta TypeScript en Node.js 24, que borra los tipos sin compilar (ORE 0050 R3).

Dos decisiones dan forma a la versión, y las dos vienen del lenguaje:

- **La marca es la del estándar, no la de Python.** TypeScript no decora funciones sueltas; lo que
  la industria usa para funciones de TypeScript es un fichero por función, su `export default` y un
  `export const config` al lado. Se lee sin ejecutar igual que un decorador, y no obliga a nadie a
  aprender una forma nuestra.
- **Un número de JavaScript no es un entero ni un decimal.** La firma lo dice con nombres del SDK
  (`Integer`, `Decimal<p, s>`, `Money<…>`, `LocalDate`…), que son alias de `number` y `string`: no
  piden conversión al escribir, y el contrato comprueba el valor en la frontera. Los almacenes que
  pasan un entero de 64 bits o un decimal como `number` pierden cifras en silencio por encima de 2⁵³;
  esta firma no.

## 2. Qué entra

- **`runtime: node`**, con `entrypoint: <ruta>.ts` (`01` §2).
- **Qué es una función** (`01` §3): el `export default function <nombre>` —también `async`— de un
  `.ts` con `functions` en su ruta, que se llama como el fichero.
- **`config`** (`01` §4): `over`, `reads`, `models` y `timeout`, como el decorador de Python.
- **La firma** (`01` §5–§6): los parámetros con su anotación, la vuelta obligatoria (`Promise<T>` es
  `T`), y la tabla de los tipos, con las mismas formas que v1alpha20 da a Python: escalares,
  precisión y unidad, objetos como `Struct` y como mapa de `output`, listas y `Media`.
- **Los valores al invocar** (`01` §7): un decimal es una cadena con sus cifras; un instante, un
  `Date`; una fecha de calendario, una cadena ISO.
- **Qué TypeScript** (`01` §8): el 5.8 con solo sintaxis borrable, la que Node 24 ejecuta.

## 3. Qué no entra

- **Tipos de otro fichero.** Una firma que usa un `interface` importado de `./tipos.ts` necesita
  resolver el árbol de módulos, y la derivación de esta versión es una función de **un** fichero,
  como la de Python. Es la siguiente, si se pide.
- **Uniones de literales como enumerado** (`"alta" | "baja"`): OOS no tiene un tipo enumerado en la
  firma, y en Python tampoco entra `Literal`.
- **`Map`, `Set`, `Record`, tuplas, `any`/`unknown`**: lo mismo que v1alpha20 dejó fuera en Python, y
  por lo mismo.
- **Un cliente de la ontología como parámetro**, las ediciones y las fuentes externas (`sources`):
  son de la `Entity` como parámetro y de la escritura, que tienen su propia especificación.
- **`jvm`**: entra por esta misma regla cuando se decida su marca.
