# OOS v1alpha34 · 01 — el registro de artefactos

## 1. Qué es

Un **`ArtifactRegistry`** es donde una organización guarda los paquetes de software que trae de fuera
para que su código los importe: jars de Maven, distribuciones de Python. Es contenido gobernado: vive
en un paquete y un schema, tiene dueño y se nombra `<paquete>.<schema>.<nombre>`.

Contiene **librerías** (un paquete del ecosistema: `com.banco:motor-riesgo`, `banco-riesgo`), y cada
librería **versiones** con sus ficheros. Ninguna de las dos está en el documento (§4). Es a las
librerías lo que un paquete del árbol a sus datasets: el sitio con nombre, dueño y permisos; lo de
dentro llega por otro camino.

## 2. La forma

```yaml
apiVersion: oos.dev/v1alpha34
kind: ArtifactRegistry
metadata:
  name: libs                           # único en su schema
  namespace: banco                     # el paquete (OOS2030)
  schema: riesgo                       # opcional: sin él, `default`
  description: …                       # opcional
spec:
  owner: team:riesgo                   # opcional, como en v1alpha21
  formats: [maven, pypi]               # opcional: sin ella, todos
```

- `metadata` admite `name`, `namespace`, `schema` y `description`. **Sin `labels`**: un registro no
  porta datos; lo que el código que importa sus librerías produzca se clasifica por lo que lee.
- `spec` admite exactamente `owner` y `formats`. **Ni librerías, ni versiones, ni coordenadas**: son
  dato (§4). Una clave más es `OOS1005`.
- La carpeta `registries/` es la costumbre, como `views/`: ordena y no nombra.

## 3. Los formatos

`formats` es **opcional**. **Sin ella, el registro admite todos los formatos** que la plataforma
sirve: un registro guarda a la vez librerías de Maven y de Python, y el formato de cada una lo dice
cómo se publica, no el documento. Un formato que la plataforma añada después cabe sin tocarlo.

Con ella, **restringe**: una lista **no vacía** de un vocabulario cerrado, `maven` y `pypi`, y el
registro sólo recibe librerías de esos formatos (publicar un jar en uno que sólo dice `pypi` lo
rechaza la plataforma). Vacía, o con una palabra fuera del vocabulario, es `OOS1004`. Un formato
repetido es `OOS2003` (un conjunto no repite).

## 4. Lo que no es del documento

- **Las librerías, sus versiones y sus ficheros.** Se publican a la plataforma con las herramientas
  del formato (`mvn deploy`, `uv publish`), sin tocar el árbol. Un fichero publicado es
  **inmutable**: no se reescribe ni se borra; una versión se retira.
- **A qué registro pertenece una coordenada.** La reclama el primero que la publica, y otro registro
  de la misma plataforma no puede publicarla. Lo decide quien recibe lo publicado.
- **Restringir los formatos** de un registro que ya tiene librerías de un formato que deja fuera:
  lo rechaza la plataforma, que es quien sabe si las hay.
- **Quién puede publicar o leer**: del control de acceso de la plataforma, sobre el registro.

## 5. Las reglas

| código | la regla | sección |
|---|---|---|
| `OOS1003` | un `ArtifactRegistry` que declara una versión anterior a v1alpha34 | §1 |
| `OOS1004` | `formats` vacía o con un formato fuera del vocabulario | §3 |
| `OOS1005` | una clave de `metadata` o `spec` que no está en §2 | §2 |
| `OOS2003` | un formato repetido en `formats` | §3 |
| `OOS2030` · `OOS2036` · `OOS2037` | su paquete y su schema, como todo contenido gobernado | §1 |
| `OOS2035` | dos `ArtifactRegistry` con el mismo nombre en el mismo schema | §1 |
