# OOS v1alpha17 — alcance

**Estado:** borrador de alcance. Gobierna los documentos que declaran su `apiVersion`, y es
**alpha**: sin garantías de compatibilidad.

| | |
|---|---|
| `00-scope` | **este documento** — qué entra, qué no, y por qué lo que se saca de un fichero es una fila anclada |
| [`01-los-tipos`](01-los-tipos.md) | `Struct<…>`, `list<Struct<…>>` y `Vector<n>`; el valor de `Media<c>` pasa a ser una **referencia** entera |
| [`02-el-ancla`](02-el-ancla.md) | el tipo `Anchor`: a qué parte de un medio se refiere un resultado |
| [`03-la-tabla-anclada`](03-la-tabla-anclada.md) | un `Dataset` con `anchoredTo`: la forma de todo resultado sacado de una colección |
| [`04-la-coleccion-como-listado`](04-la-coleccion-como-listado.md) | una `MediaCollection` se lee en SQL como **su listado**, nunca como sus bytes |

Esta versión **añade tres tipos** —`Struct<…>`, `Vector<n>` y `Anchor`—, **cambia el valor** de
`Media<c>` —de la huella a la referencia entera—, **abre una clave** en `Dataset` —`anchoredTo`—
y **abre una puerta** que v1alpha16 cerraba: nombrar una colección en un `FROM`. Añade dos
códigos, `OOS2041` y `OOS3007`.

---

## 1. La tesis

| versión | verbo | la regla |
|---|---|---|
| v1alpha11 | **publicar** | lo que el código produce y no es una tabla entra en el árbol como un documento que nombra sus bytes |
| v1alpha16 | **guardar** | un fichero es un objeto, no una fila: se apunta como objeto, se tiene en una colección de su tipo, y una entidad lo referencia sin copiarlo |
| **v1alpha17** | **anclar** | **lo que se saca de un fichero es una fila anclada a una parte de él: el ítem, dónde, qué, y de qué función salió** |

v1alpha16 dejó los ficheros bien guardados y sin nada que hacer con ellos: una colección no se
leía con SQL (`OOS2018`), y lo que una función sacara de un PDF —su texto, sus tablas, sus
cajas— no tenía más forma que la de cualquier `Dataset`, con el anclaje en una columna `String`
que cada cual escribía a su manera. El estado del arte (ORE 0049) coincide en lo contrario: el
resultado de leer un medio **es de una forma**, y es la de una anotación —una fuente, un
selector, un cuerpo, y quién lo generó— (W3C Web Annotation).

## 2. Las tres capas, y cuál es de la gramática

Leer un medio tiene tres capas: la **referencia** (qué ítem, en qué versión), el **handle** (cómo
abrirlo) y los **bytes**. Solo la primera es un valor que viaja por una tabla, y por eso es la
única que la gramática tipa. El handle y los bytes son del motor (ORE 0049, nivel 2).

| capa | dónde vive | en esta versión |
|---|---|---|
| referencia | en una fila | el valor de `Media<c>` ([01](01-los-tipos.md) §3) |
| la parte del medio | en una fila | `Anchor` ([02](02-el-ancla.md)) |
| handle, rangos, URL firmada | en el motor | fuera de la gramática |
| bytes | en el lago o en el origen | fuera de la gramática |

## 3. Lo que no entra

- **Las operaciones** —listar, abrir, leer un rango, firmar, escribir— son del motor. Esta
  versión fija lo que esas operaciones devuelven cuando lo devuelven **en una fila**.
- **Qué función** saca qué (qué OCR, qué modelo): la gramática exige que la fila **diga** qué
  función y qué modelo la produjeron ([03](03-la-tabla-anclada.md) §3), no cuál.
- **La URL firmada** no es un valor de ninguna columna, nunca: caduca y es al portador.
- **`Vector` de otra cosa que `Float32`**: la primera forma es la de los modelos de hoy; otra
  precisión es otra versión.
- **Permisos por ítem**: son del motor de acceso (ORE 0047); el listado ya se filtra por fila.

## 4. Compatibilidad

Una entidad de v1alpha16 con `Media<c>` se lee igual: la propiedad sigue siendo una referencia a
un ítem de `c`. Lo que cambia es la **columna que la respalda**: en v1alpha16 era `String` (la
huella); en v1alpha17 es la referencia entera. Un árbol que declara `apiVersion: oos.dev/v1alpha16`
sigue compilando con las reglas de v1alpha16; subirlo es cambiar la columna.
