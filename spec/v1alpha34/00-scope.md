# OOS v1alpha34 — alcance

**Estado:** borrador de alcance, **alpha**: sin garantías de compatibilidad. La gramática es **del
documento** que declara v1alpha34.

| | |
|---|---|
| `00-scope` | **este documento** — qué entra, qué no, y por qué |
| [`01-artifact-registry`](01-artifact-registry.md) | **el registro de artefactos**: donde una organización guarda los paquetes de software (Maven, PyPI) que su código importa |

Esta versión **añade un `kind`** —`ArtifactRegistry`— y **ningún código**: usa `OOS1003`,
`OOS1004`, `OOS1005`, `OOS2003` y los del contenido gobernado. Los demás `kind` no cambian.

---

## 1. La tesis

El código de un transform no vive solo: importa librerías. Las públicas las resuelve la
plataforma desde Maven Central o PyPI; las de la organización —un parser de su sector, el motor de
reglas de hace diez años— viven en su servidor privado y no son alcanzables desde donde se
construye. Hasta aquí el árbol no tenía forma de decir **«aquí guardamos nuestras librerías»**.

Esta versión se la da, con tres decisiones:

- **El activo es el registro, no la librería.** Un `ArtifactRegistry` vive en un paquete y un schema
  (v1alpha13), tiene dueño (v1alpha21) y se nombra `<paquete>.<schema>.<nombre>`. Contiene muchas
  librerías, y cada una muchas versiones.
- **El documento declara; no contiene.** Dice qué formatos admite. Las librerías, sus versiones y sus
  ficheros son **dato**, como las filas de un `Dataset`: nacen al publicar, sin cambiar el árbol. Una
  librería nueva no espera a una revisión del árbol: la publica el CI de quien la escribe.
- **La coordenada no es de la gramática.** El nombre con el que Maven o pip piden una librería
  (`com.banco:motor-riesgo`) lo reclama el primer registro que la publica; eso lo decide la
  plataforma, que es quien recibe lo publicado.

## 2. Qué entra

- El `kind` `ArtifactRegistry` y su forma (`01` §1–§3).

## 3. Qué no entra

- **Las librerías, sus versiones y sus ficheros; publicar, retirar y a qué registro pertenece una
  coordenada**: dato y operación de la plataforma (`01` §4).
- **npm, Conda, imágenes de contenedor**: otro formato es una versión aparte.
- **Quién consume una librería**: lo sabe quien resuelve las dependencias de un repositorio, no la
  gramática.
