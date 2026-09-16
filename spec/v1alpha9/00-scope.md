# OOS v1alpha9 — alcance

**Estado:** borrador de alcance. Gobierna los documentos que declaran su `apiVersion`, y es
**alpha**: sin garantías de compatibilidad.

| | |
|---|---|
| `00-scope` | **este documento** — qué entra, qué no, y por qué el modelo es un documento |
| [`01-model`](01-model.md) | el modelo: naturaleza, la forma, las reglas, y la función que lo invoca |

Esta versión **añade un `kind`** —`Model`— y **le da a `Function` un segundo `runtime`**:
`model`, con dos claves propias, `model` y `prompt`. No añade códigos de error: lo que rechaza
lo rechaza con los de siempre —`OOS1004` la forma, `OOS1005` una clave que no es de aquí,
`OOS2005` un modelo que no está—.

---

## 1. La tesis

Cada versión gobierna un verbo, y aporta **una** regla:

| versión | verbo | la regla |
|---|---|---|
| v1alpha7 | **preguntar** | la vista es la pregunta y compone |
| v1alpha8 | **apuntar** | lo físico se registra una vez, con dos caras |
| **v1alpha9** | **razonar** | **un modelo que se usa es un documento del árbol, y nombra un perfil medido** |

Lo que esta versión afirma: *qué razona sobre eso* es la cuarta pregunta, después de *qué hay
ahí fuera* (`Table`), *qué se pregunta* (`View`) y *qué es una fila* (`Entity`). Y la
respuesta no es un servicio al lado de los datos: es **un operador dentro del grafo**, que se
nombra como un nodo (`modelo/<nombre>`), se versiona con un commit y se gobierna porque está
en el mismo árbol que lo que lee y lo que escribe.

## 2. Por qué un documento y no un recurso

Porque todo lo que el árbol ya regala a un documento le hace falta a un modelo:

- **direccionable**: una `Function` que lo invoca nombra un nodo, no una URL;
- **versionado**: cambiar `profile` o `digest` es un commit, volver es un `revert`, y quién lo
  pidió está dentro;
- **gobernado**: la gobernanza ve qué vistas lo alimentan y qué propiedad escribe, porque la
  función que lo invoca declara sus `effects` como cualquier otra.

Y porque lo que **no** debe estar en el árbol queda fuera con la misma regla: ni `runtime`, ni
`resources`, ni `weights.repo`. Todo eso es **del perfil**, y el perfil lo certifica quien lo
mide. El árbol no puede pedir una configuración que nadie ha medido — *un perfil sin número
no existe*.

## 3. Qué entra

- `kind: Model` — [`01-model`](01-model.md).
- `Function.spec.runtime: model`, con `model: modelo/<nombre>` y `prompt`. Es el mismo
  documento de v1alpha2 con un segundo runtime: los `effects` siguen siendo la superficie, los
  endosos siguen decidiendo la integridad, y **una función no aplica: propone**.

## 4. Qué no entra, y por qué

- **La lista de perfiles.** Qué perfiles existen y con qué números es un hecho **del sustrato**,
  cambia cuando alguien mide, y no se declara en el árbol: se coteja contra él al escribir el
  documento (es el `422` de quien escribe, no un código de la gramática).
- **El tier dedicado como despliegue.** `tier: dedicated` es vocabulario desde ya; lo que
  deriva de él es de quien lo aplica.
- **Endosos por defecto.** Un modelo no lleva `labels` ni se endosa a sí mismo: **la salida de
  un modelo sin endoso es el mínimo del retículo**, y `OOS7002` lo cobra sobre la función que
  lo invoca. Es lo que una clasificación sin revisar es, y el árbol lo dice en vez de callarlo.

## 5. Compatibilidad

Ningún documento de v1alpha1 a v1alpha8 cambia de resultado. `runtime` sigue siendo libre para
lo que ya existía; `model` y `prompt` son claves de v1alpha9 y en una versión anterior son
`OOS1005`, como siempre lo fueron.
