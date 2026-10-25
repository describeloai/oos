# OOS v1alpha34 — alcance

**Estado:** borrador de alcance, **alpha**: sin garantías de compatibilidad. La gramática es **del
documento** que declara v1alpha34.

| | |
|---|---|
| `00-scope` | **este documento** — qué entra, qué no, y por qué |
| [`01-artifact`](01-artifact.md) | **el artefacto**: un paquete de software (Maven, PyPI) traído de fuera, como activo del catálogo |

Esta versión **añade un `kind`** —`Artifact`— y **un código**: `OOS2055` (dos artefactos con la
misma coordenada). Los demás `kind` no cambian.

---

## 1. La tesis

El código de un transform no vive solo: importa librerías. Las públicas las resuelve la
plataforma desde Maven Central o PyPI; las de la organización —un parser de su sector, el motor de
reglas de hace diez años— viven en su servidor privado y no son alcanzables desde donde se
construye. Hasta aquí el árbol no tenía forma de decir **«esta librería es nuestra y está aquí»**.

Esta versión se la da, con las tres decisiones de siempre:

- **Es contenido gobernado.** Un `Artifact` vive en un paquete y un schema (v1alpha13), tiene dueño
  (v1alpha21) y se nombra `<paquete>.<schema>.<nombre>` como todo lo que se tiene.
- **El documento declara; no contiene.** Dice qué paquete de software es —formato y coordenada—. Sus
  versiones y sus ficheros son **dato**, como las filas de un `Dataset`: los guarda la plataforma, no
  el árbol. Publicar una versión no es cambiar el árbol.
- **Una coordenada, un dueño.** La coordenada es el nombre con el que las herramientas (Maven, pip,
  uv) piden el paquete; dos documentos con la misma serían dos respuestas a la misma petición.

## 2. Qué entra

- El `kind` `Artifact`, su forma y su coordenada (`01` §1–§3).
- Una coordenada única en el árbol (`01` §4).

## 3. Qué no entra

- **Las versiones, los ficheros, sus sumas, publicar y retirar**: dato y operación de la
  plataforma (`01` §5).
- **Que el formato y la coordenada no cambien** una vez publicado algo: lo comprueba quien guarda
  las versiones, que es quien sabe si hay alguna; un árbol solo no puede saberlo.
- **npm, Conda, imágenes de contenedor**: otro formato es una versión aparte.
- **Quién consume un artefacto**: lo sabe quien resuelve las dependencias de un repositorio, no la
  gramática.
