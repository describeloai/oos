# OOS v1alpha29 — alcance

**Estado:** borrador de alcance, **alpha**: sin garantías de compatibilidad.

| | |
|---|---|
| `00-scope` | **este documento** — qué entra, qué no, y por qué |
| [`01-las-familias`](01-las-familias.md) | **las familias de medios**: el vocabulario de `media` pasa de 8 a 15 palabras, un `archive` puede ser una colección y una colección puede ser `multimodal` |

Esta versión **no añade un `kind` ni un código**. Amplía un vocabulario cerrado —`media`, de
[`v1alpha16/01`](../v1alpha16/01-object-table.md) §4— y quita dos prohibiciones de
[`v1alpha16/02`](../v1alpha16/02-media-collection.md) §7.

## 1. Lo medido

En la plataforma que implementa OOS (ORE 0061 AZ5, 2026-10-12), sobre el contenedor público `mnist`
de Azure Open Datasets:

- **Una base estándar nació vacía.** Lo elegido eran cuatro `.gz`: `media: archive`, y una
  colección de `archive` es `OOS1004`. La base copia lo que entra, y no había nada que copiar.
- **`manifest.json` y sus `.sha256` son `binary`**: el vocabulario no tiene dónde poner un JSON,
  y lo que es `binary` no puede ser colección.
- **Tres vocabularios.** El de esta spec tiene 8 palabras; la galería de la consola de la misma
  plataforma, 13 familias; Foundry, 7 esquemas más uno *multimodal* (cualquier fichero en un
  mismo *media set*, con preview sólo de los tipos que conoce).

Todo lo que el vocabulario no nombra cae en `binary`, y `binary` no se guarda: un GeoJSON, un STL,
un HDF5, un DICOM-SEG, un registro.

## 2. Lo que entra

1. **Quince palabras en `media`**, cerradas como antes: las ocho de v1alpha16 y siete familias
   nuevas —`structured`, `text`, `geospatial`, `model3d`, `medical`, `scientific`, `design`—
   ([`01`](01-las-familias.md) §1).
2. **Un `archive` puede ser una colección**, guardado tal cual. Abrirlo sigue siendo una
   transformación (v1alpha16 `01` §4.3) ([`01`](01-las-familias.md) §2).
3. **`multimodal`**, sólo en una colección: la de lo que no es de una sola familia. `formats` es
   opcional en ella ([`01`](01-las-familias.md) §3).

## 3. Lo que no entra

- **Abrir un `archive`** —listar su índice, expandirlo— como transformación declarada.
- **Lo que se extrae de cada familia** (el texto de un PDF, las etiquetas de un DICOM, la geometría
  de un GeoJSON): son funciones sobre la colección, no vocabulario.
- **`model`** (pkl, onnx, safetensors) **no es una familia**: un modelo es un kind propio
  (`TrainedModel`, `Model`). Sus ficheros sueltos son `binary`.
- **Una carpeta que es un objeto** (`zarr`, un *bundle* de macOS): el catálogo la verá como muchos.

## 4. La puerta

La regla vale **por documento**: un `ObjectTable` o una `MediaCollection` con
`apiVersion: oos.dev/v1alpha29` usa el vocabulario nuevo; uno anterior, el de v1alpha16. Un árbol
que compilaba compila igual, y lo que v1alpha16 prohibía —`media: archive` en una colección de
v1alpha16— sigue prohibido en ese documento ([`01`](01-las-familias.md) §5).
