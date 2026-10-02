# OOS v1alpha21 — alcance

**Estado:** borrador de alcance. Gobierna los documentos que declaran su `apiVersion`, y es
**alpha**: sin garantías de compatibilidad.

| | |
|---|---|
| `00-scope` | **este documento** — qué entra, qué no, y por qué |
| [`01-el-dueno`](01-el-dueno.md) | `Entity`, `Function`, `ObjectTable` y `Model` dicen **quién responde** de ellos: `spec.owner`, el mismo handle que ya llevaban el paquete, el schema, la vista, el dataset, la colección y el modelo entrenado |

Esta versión **añade una clave** —`spec.owner`, opcional— a cuatro `kind` y **no añade códigos**: un
`owner` que no es un handle sigue siendo `OOS2009`, y en una versión anterior la clave sigue siendo
`OOS1005`.

---

## 1. La tesis

| `kind` | ¿dice quién responde? |
|---|---|
| `Package`, `Schema`, `View`, `Dataset`, `MediaCollection`, `TrainedModel` | sí, desde que existen: `spec.owner` |
| `Entity`, `Function`, `ObjectTable`, `Model` | **no hasta v1alpha21**: solo su paquete |

Cuatro de los activos que una persona crea no tenían dónde decir de quién son. Una función es código
que corre y escribe; una tabla de objetos apunta a un bucket; un modelo es una suscripción con
coste; una entidad es lo que la ontología afirma. Que respondiera de ellos «su paquete» era heredar
del contenedor, y el contenedor no lo creó: una función que Ana escribe en el proyecto de Bea es
de Ana. La plataforma que implementa OOS (ORE 0049, «el dueño», 2026-10-02) decidió que **lo que se
crea es de quien lo crea**, y la gramática tenía que poder escribirlo.

## 2. Qué entra

- **`spec.owner`** en `Entity`, `Function`, `ObjectTable` y `Model`: opcional, con la forma de
  siempre (`team:<handle>` o `user:<handle>`; `OOS2009` si no lo es) (`01` §2).
- **Su significado** es el de los demás `kind`: quién responde, no quién puede. No concede ni niega
  nada, y no se hereda (`01` §3).
- **En una función de código** no forma parte de la firma: el documento derivado lo conserva al
  regenerarse y `OOS2013` no lo compara (`01` §4).

## 3. Qué no entra

- **Hacerlo obligatorio.** Un `owner` ausente sigue siendo válido en los cuatro: lo que ya existe no
  deja de compilar, y quien no lo escribe responde por su paquete, como hasta ahora.
- **`Action`, `Concept`, `Interface`, `Table`.** Una acción es parte de su entidad; un concepto y
  una interfaz son vocabulario; una tabla es un hecho del origen. Ninguno se «crea» en el sentido de
  esta versión.
- **Resolver el handle.** Que `user:ana` sea alguien es del plano de control de quien implementa OOS
  (como `CODEOWNERS` lo es de la forja), no de la gramática.
