# 03 · La tabla anclada

**Estado:** normativo. Parte de OOS v1alpha17.

Un `Dataset` con `anchoredTo` es **la forma de todo resultado sacado de una colección**: una fila
por ancla, con el ítem, dónde, qué, de qué función salió y si salió bien. Sus columnas de sistema
son fijas; las de la carga, de quien la declara.

```yaml
apiVersion: oos.dev/v1alpha17
kind: Dataset
metadata: { name: bloques, namespace: legal }
spec:
  owner: team:legal
  anchoredTo: legal.contratos
  columns:
    etiqueta: { type: String }
    texto: { type: String }
    confianza: { type: Float }
    vector: { type: "Vector<768>" }
```

## 1. Las columnas de sistema

`anchoredTo` **añade** estas columnas; declararlas en `columns` es `OOS1004`:

| columna | tipo | qué |
|---|---|---|
| `_item` | `Media<c>` (`c` = `anchoredTo`) | el ítem |
| `_anchor` | `Anchor` | la parte del ítem ([02](02-el-ancla.md)) |
| `_anchor_id` | `String` | determinista (§2) |
| `_anchor_parent` | `String` | el `_anchor_id` del ancla que la contiene (la página de un bloque); nulo en la raíz |
| `_derivation` | `Struct<key: String, fn: String, fn_version: String, model: String, model_rev: String, params_hash: String, run: String, created: DateTimeTz>` | de qué salió (§3) |
| `_status` | `Struct<state: String, error_type: String, error_message: String, attempts: Integer>` | `state` ∈ `ok`, `error` (§4) |

## 2. La identidad de una fila

`_anchor_id` es `sha256` de la identidad del ítem ([01](01-los-tipos.md) §3.1), la forma canónica
del ancla y `_derivation.fn`, en ese orden. Dos ejecuciones de la misma función sobre el mismo
contenido dan **los mismos ids**: una fila se reemplaza, no se duplica, y otra tabla puede
apuntar a ella (como el `element_id` de Unstructured, que es un hash de lo mismo).

Por eso una tabla anclada **no declara `changes`**: se funde por `_anchor_id`, siempre.

## 3. La derivación

`_derivation.key` es `sha256(identidad del ítem, fn, fn_version, model_rev, params_hash)`. Es la
**clave de memoización** (ORE 0049, D5): mientras no cambie, el ítem no se vuelve a procesar;
si cambia cualquiera de sus partes, sí. Mover un ítem de ruta sin cambiar su contenido no la
cambia.

- `fn` es el nombre de la función; `fn_version`, la que declara quien la escribe o la que el motor
  deriva de su código.
- `model` y `model_rev` son nulos cuando no hay modelo.
- `params_hash` es `sha256` de la forma canónica de los parámetros (la de `90-canonical-form`).
- `run` es la ejecución que la escribió; `created`, cuándo.

## 4. El estado

Una fila con `state: error` es **un resultado**: el ítem se intentó y falló, y queda con
`_anchor.kind: item`, su error y sus intentos. No es una fila que falta. Es lo que hace posible
reintentar solo lo fallido y decir, de cada ítem, qué pasó con él.

## 5. Gobierno

- **Hereda de su colección** por `derivedFrom` implícito: una tabla anclada a `c` deriva de `c`,
  lleva al menos sus etiquetas, y proyectarla hacia algo menos clasificado es `OOS4002` (como
  v1alpha16 `02` §6).
- Puede declarar además `derivedFrom` de otras entradas (un diccionario, otra tabla).

## 6. Las reglas

| | código | |
|---|---|---|
| `anchoredTo` en v1alpha16 o antes | `OOS1005` | una clave que no existía |
| `anchoredTo` que no resuelve a una `MediaCollection` | `OOS2018` | |
| una columna de `columns` que empieza por `_` | `OOS1004` | las de sistema son de la gramática |
| `changes` en una tabla anclada | `OOS1004` | se funde por `_anchor_id` (§2) |
| `anchoredTo` en un dataset con `from` | `OOS1004` | la escribe código que lee una colección, no un plan |
| una columna `Media<x>` con `x` distinta de `anchoredTo` | `OOS2041` | una tabla anclada es de **una** colección; otra referencia se une por su id |
| `anchoredTo` en un `kind` que no es `Dataset` | `OOS1005` | |
