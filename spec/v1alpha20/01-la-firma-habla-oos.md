# La firma habla OOS

**Versión:** v1alpha20 · amplía v1alpha18 `01` §4.6 (la tabla de los tipos). Todo lo demás de
v1alpha18 `01` §4 —qué es una función, cómo se resuelven los nombres, cuándo se evalúa una
anotación, la coherencia, leer sin ejecutar— sigue igual y vale para lo de aquí.

## 1. La tabla

Además de la de v1alpha18 §4.6:

| Python | OOS |
|---|---|
| `time`, `datetime.time` | `Time` |
| `bytes` | `Opaque` |
| `ore.tipos.DateTimeTz` | `DateTimeTz` |
| `Annotated[Decimal, ore.tipos.Precision(p, s)]` | `Decimal<p, s>` |
| `ore.tipos.Money["EUR", 2]` | `Money<EUR, 2>` |
| `ore.tipos.Quantity["km", 1]` | `Quantity<km, 1>` |
| una `@dataclass` del nivel superior del fichero | `Struct<campo: T, …>` |
| `list[D]`, con `D` una `@dataclass` del fichero | `list<Struct<…>>` |
| `ore.tipos.Media["base.schema.coleccion"]` | `Media<base.schema.coleccion>` |

Los nombres de `ore.tipos` se leen **por lo que son** (v1alpha18 §4.1): `from ore.tipos import
Money`, `import ore.tipos as t` y `t.Money`, con alias o sin él. Un `Money` que el módulo define o
tapa no es `ore.tipos.Money`.

## 2. Escalares

- `time` es `datetime.time`, como `date` es `datetime.date`.
- `bytes` es el del lenguaje salvo que el módulo lo tape. Su valor es lo que OOS no modela: un blob.
- **`DateTimeTz`**: un `datetime` de Python no dice en su tipo si lleva zona, así que la anotación
  lo dice con un nombre propio, `ore.tipos.DateTimeTz`. `datetime` a secas sigue siendo `DateTime`.

## 3. La precisión y la unidad

- **`Decimal<p, s>`**: `Annotated[Decimal, Precision(p, s)]`, con `Precision` de `ore.tipos` y `p`
  y `s` **enteros literales**, `1 ≤ p ≤ 38` y `0 ≤ s ≤ p` (como v1alpha1 `02` §3.2). Cualquier otra
  cosa en el `Annotated` se ignora, como en v1alpha18. Fuera de rango, o no literales: `OOS2043`.
- **`Money` y `Quantity`**: `Money["EUR", 2]` —la unidad, una **cadena literal**; la precisión, un
  **entero literal**—. La unidad es parte del tipo: `Money<EUR, 2>` y `Money<USD, 2>` son dos tipos.
  Sin los dos argumentos, o no literales: `OOS2043`.

## 4. Las estructuras

- **Una `@dataclass` del fichero** que no es la vuelta de la función —un parámetro, un campo de otra
  `@dataclass`, un elemento de una lista— es `Struct<…>`: sus campos (v1alpha18 §4.5), **en su
  orden**, cada uno con su tipo de esta tabla. Un campo opcional es un campo que puede ser nulo:
  `Struct` no lo distingue en su tipo.
- La **vuelta** de la función sigue siendo lo que era: una `@dataclass` es el **mapa** de `output`
  (v1alpha18 §4.5); `-> list[D]` es un valor, `output: { type: list<Struct<…>> }` (v1alpha18 §4.7).
- Una `@dataclass` que se contiene a sí misma, directa o indirectamente, no tiene tipo finito:
  `OOS2043`.
- `list<T>` sigue sin listas dentro (v1alpha18 §4.6); una estructura dentro de una lista puede
  llevar listas en sus campos.

## 5. La referencia a un ítem

`ore.tipos.Media["legal.archivo.contratos"]` es `Media<legal.archivo.contratos>` (v1alpha16 `03`
§2): el valor es la referencia a un ítem de esa colección —dónde está y qué versión—, no sus bytes.
La colección se nombra con una **cadena literal**, y se resuelve como cualquier `Media<…>`: una que
no está es `OOS2018`.

## 6. La versión del documento

El documento que se deriva declara **la versión más baja cuya tabla deriva su firma**:
`oos.dev/v1alpha18` si solo usa lo de v1alpha18 §4.6, `oos.dev/v1alpha20` si usa algo de este
documento. Así un árbol que no usa nada de aquí no cambia ni un byte.

Y en la coherencia (v1alpha18 §4.8): un documento que declara v1alpha18 para una firma que usa algo
de aquí **no es el que el código da** (`OOS2013`), aunque sus tipos coincidan: la regla que lo
deriva es la de una versión que no declara.

## 7. Los valores al invocar

Lo que la invocación lleva en JSON para cada tipo (el arnés lo convierte al tipo de Python antes de
llamar al `def`):

| OOS | JSON | Python |
|---|---|---|
| `Time` | `"08:30"`, `"08:30:15"` | `datetime.time` |
| `Opaque` | una cadena en base64 | `bytes` |
| `DateTimeTz` | ISO 8601 **con** zona (`Z` o `+02:00`); sin ella no es un instante | `datetime` con `tzinfo` |
| `Decimal<p, s>` | un número con como mucho `s` decimales y `p` cifras | `Decimal` |
| `Money<…>`, `Quantity<…>` | un número con como mucho los decimales de su precisión | `Decimal` |
| `Struct<…>` | un objeto con esos campos y ninguno más | la `@dataclass` |
| `list<Struct<…>>` | una lista de objetos | `list` de la `@dataclass` |
| `Media<c>` | el objeto de la referencia (`uri`, `collection`, `path`, `version`, …) de un ítem de `c` | `ore.medios.MediaRef` |
