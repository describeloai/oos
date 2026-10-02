# OOS v1alpha20 — alcance

**Estado:** borrador de alcance. Gobierna los documentos que declaran su `apiVersion`, y es
**alpha**: sin garantías de compatibilidad.

| | |
|---|---|
| `00-scope` | **este documento** — qué entra, qué no, y por qué |
| [`01-la-firma-habla-oos`](01-la-firma-habla-oos.md) | la firma de un `@function` deriva a los tipos de OOS que ya existían y no llegaban a ella: la hora, lo opaco, el instante con zona, el decimal con su precisión, el dinero y la cantidad con su unidad, la estructura, la lista de estructuras y la referencia a un ítem de una colección |

Esta versión **no cambia ningún `kind`** ni añade tipos a OOS: **amplía la tabla de derivación** de
v1alpha18 `01` §4.6. Todo lo que un `Function` escrito a mano ya podía declarar en `input` y en
`output` —`Time`, `Opaque`, `DateTimeTz`, `Decimal<p, s>`, `Money<…>`, `Quantity<…>`,
`Struct<…>`, `list<Struct<…>>`, `Media<…>`— se puede ahora **escribir en Python** y derivar. No
añade códigos: lo que no se deriva sigue siendo `OOS2043`, el documento que no es el que el código
da sigue siendo `OOS2013`, y una colección que no está, `OOS2018`.

---

## 1. La tesis

| versión | la firma de una función de código |
|---|---|
| v1alpha18 | `int`, `float`, `str`, `bool`, `date`, `datetime`, `Decimal`, `list[T]`, `Optional[T]`; y una `@dataclass` como vuelta |
| **v1alpha20** | **todo tipo de OOS que tiene un valor que se pueda pasar a una función** |

v1alpha18 dejó la firma en los siete escalares que Python escribe sin ayuda. Pero el contrato de
una función es lo que un consumidor ve —un pipeline que le pasa columnas, una persona que la prueba
con un formulario (*Dry Run*)— y ese consumidor habla OOS: una columna `Money<EUR, 2>` llamaba a una
función que solo podía decir `Decimal`, y la moneda se perdía en la frontera. La regla de v1alpha1
P4 aplica: lo que no está en el contrato no se comprueba, y no comprobarlo no da síntomas.

## 2. Qué entra

- **Escalares**: `datetime.time` → `Time`; `bytes` → `Opaque`; `ore.tipos.DateTimeTz` →
  `DateTimeTz` (`01` §2).
- **Con su precisión o su unidad**: `Annotated[Decimal, ore.tipos.Precision(p, s)]` →
  `Decimal<p, s>`; `ore.tipos.Money["EUR", 2]` → `Money<EUR, 2>`; `ore.tipos.Quantity["km", 1]`
  → `Quantity<km, 1>` (`01` §3).
- **Compuestos**: una `@dataclass` del fichero **como parámetro** → `Struct<…>`; una lista de ellas,
  como parámetro, como campo o como vuelta, → `list<Struct<…>>` (`01` §4).
- **Ficheros**: `ore.tipos.Media["base.schema.coleccion"]` → `Media<base.schema.coleccion>` (`01` §5).
- **La versión del documento** que se deriva es la más baja cuya tabla lo deriva: v1alpha18 si la
  firma solo usa lo de v1alpha18, v1alpha20 si usa algo de aquí (`01` §6).

## 3. Qué no entra

- **Una `Entity` como parámetro** (un objeto de la ontología, no su clave): pide un tipo de
  referencia que OOS no tiene todavía. Es la siguiente.
- **`set`, `dict`, rangos y agregaciones**: OOS no los modela, y `Struct` y `list<Struct>` cubren lo
  que expresan con un esquema. Un `dict` de claves libres es justo lo que un contrato evita.
- **`Vector<n>` y `Anchor`**: tienen valor, pero su forma en Python (un array de `n` `float32`, el
  selector de un ancla) se decide con quien los consuma.
- **Identidad y marcas** (un usuario, un grupo, una clasificación como parámetro): son del plano de
  control; quien invoca ya se sabe y la clasificación la llevan los tipos, no los valores.
