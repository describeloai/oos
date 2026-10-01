# OOS v1alpha18 — alcance

**Estado:** borrador de alcance. Gobierna los documentos que declaran su `apiVersion`, y es
**alpha**: sin garantías de compatibilidad.

| | |
|---|---|
| `00-scope` | **este documento** — qué entra, qué no, y por qué el código de un repositorio se promueve a una función |
| [`01-la-funcion-de-codigo`](01-la-funcion-de-codigo.md) | `runtime: python`: el `entrypoint` nombra un `def`, su cabecera es la firma, y `models` declara los modelos que el código usa |

Esta versión **cambia un `kind`** —`Function`—: abre un runtime, `python`, y una clave, `models`.
**Aclara** dos cosas que valían para todas las versiones y nadie había escrito: qué vale `required`
cuando no se dice, y cómo se clasifica en `ore diff` el cambio de **un** parámetro. Añade dos
códigos, `OOS2042` y `OOS2043`. Los demás `kind` no cambian.

---

## 1. La tesis

| versión | verbo | la regla |
|---|---|---|
| v1alpha9 | **razonar** | un modelo que se usa es un documento del árbol |
| v1alpha10 | **actuar** | una función es lógica encapsulada sobre la copia: lee lo que declara, devuelve su `output`, propone sus `effects` |
| **v1alpha18** | **promover** | **el código de un repositorio pasa a ser una función cuando un documento lo nombra: el documento es el contrato, y el código lo cumple o no compila** |

v1alpha10 dejó la función con una sola forma de traer código, `runtime: wasm`, porque su sandbox no
tenía red: lo que una función puede leer es la unión de lo que declara, y fuera no hay canal. Era
la garantía correcta y una forma demasiado estrecha. El código que de verdad se escribe sobre
datos —Python, sobre todo— no se compila a wasm, y lo que lo ejecuta ya existe: un entorno de
trabajo con la red cerrada, del que solo sale lo que una política con nombre abre.

La garantía no cambia de sitio: **la superficie se lee en el documento**. Lo que cambia es quién
la hace cumplir en tiempo de ejecución: con `wasm`, la falta de sockets; con `python`, la red
cerrada más lo declarado. Al compilar, las dos son lo mismo: `over`, `reads`, `effects` y ahora
`models`.

## 2. Qué entra

- **`runtime: python`**, con `entrypoint: <ruta>.py:<def>` dentro del paquete (`01` §3).
- **La cabecera del `def` es la firma**, y se coteja con `input` sin ejecutar nada (`01` §4).
- **`models`**: los modelos que el código puede llamar (`01` §5). `model` sigue siendo lo que es
  desde v1alpha9: *el modelo es lo que se ejecuta*.
- **`limits.timeout`** es el plazo de una invocación (`01` §6). Estaba en la gramática sin decir
  de qué.
- **Dos aclaraciones para todas las versiones**: `required` ausente es `false` (`01` §4.3), y el
  cambio de un parámetro se clasifica como el de una propiedad (`01` §7).

## 3. Qué no entra

- **`node` y `jvm`.** Entran por la misma regla cuando haya quien los ejecute como función; hasta
  entonces la gramática no promete lo que nadie cumple.
- **La escritura desde código.** Una función `python` con `effects` es válida en la gramática
  —la superficie de efecto es la de v1alpha10, entera—, pero cómo el código **propone** es del
  runtime y tiene su propia especificación. Un ejecutor que no la implemente rechaza invocarla y lo
  dice.
- **Cómo llegan las filas al código.** Como en v1alpha10 §7: la gramática dice **qué** puede entrar,
  el runtime dice **cómo**.
- **El contenedor del cliente.** `runtime: python` lo ejecuta una imagen del motor, no una del
  cliente; un contenedor propio sería otro runtime y otra garantía.

## 4. Los códigos

| código | qué | dónde |
|---|---|---|
| `OOS2042` | el `entrypoint` de una función de código no está: el fichero no existe en el paquete, o no define el `def` en su nivel superior | `01` §3 |
| `OOS2043` | la cabecera del `def` no es la firma del documento: sobra o falta un parámetro, la fila falta o sobra, lo obligatorio tiene valor por defecto o lo opcional no, o la superficie no es cerrada (`*args`, `**kwargs`) | `01` §4 |
