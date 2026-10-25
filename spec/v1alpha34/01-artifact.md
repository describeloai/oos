# OOS v1alpha34 · 01 — el artefacto

## 1. Qué es

Un **`Artifact`** es un paquete de software que una organización trae de fuera para que su código
lo importe: un jar de Maven o una distribución de Python. Es contenido gobernado: vive en un paquete
y un schema, tiene dueño y se nombra `<paquete>.<schema>.<nombre>`.

No es código del árbol ni se compila desde él. Es a las librerías lo que el `Dataset` escrito a las
tablas: el documento dice qué es, y el contenido llega por otro camino.

## 2. La forma

```yaml
apiVersion: oos.dev/v1alpha34
kind: Artifact
metadata:
  name: motor_riesgo                   # único en su schema
  namespace: banco                     # el paquete (OOS2030)
  schema: riesgo                       # opcional: sin él, `default`
  description: …                       # opcional
spec:
  owner: user:ana                      # opcional, como en v1alpha21
  format: maven                        # maven | pypi
  coordinate: com.banco:motor-riesgo   # el nombre con el que las herramientas lo piden
```

- `metadata` admite `name`, `namespace`, `schema` y `description`. **Sin `labels`**: un artefacto
  no porta datos; lo que su código produzca se clasifica por lo que lee.
- `spec` admite exactamente `owner`, `format` y `coordinate`. **Ni versiones ni sumas**: son dato
  (§5). Una clave más es `OOS1005`.
- La carpeta `artifacts/` es la costumbre, como `views/`: ordena y no nombra.

## 3. La coordenada

`format` es **obligatorio** y su vocabulario es cerrado: `maven` o `pypi`. Fuera de él, o ausente,
es `OOS1004`. `coordinate` es **obligatoria** y su forma la pone el formato; mal formada, o
ausente, es `OOS1004`:

| `format` | `coordinate` | ejemplo |
|---|---|---|
| `maven` | `<groupId>:<artifactId>`, cada parte de letras, dígitos, `.`, `_` y `-`, sin vacías | `com.banco:motor-riesgo` |
| `pypi` | el nombre del proyecto según PEP 508: letras y dígitos al principio y al final, y en medio además `.`, `_` y `-` | `banco-riesgo` |

- **Sin versión.** Una coordenada nombra el paquete con todas sus versiones; `com.banco:x:1.0.0` es
  `OOS1004`.
- Las herramientas comparan los nombres de PyPI **normalizados** (PEP 503: minúsculas, y cada
  tramo de `.`, `_` y `-` vale un `-`): `Banco_Riesgo` y `banco-riesgo` son el mismo proyecto. La
  gramática compara igual (§4). Las coordenadas de Maven se comparan tal cual.

## 4. Una coordenada, un artefacto

Dos `Artifact` del árbol con el mismo `format` y la misma coordenada —normalizada, en `pypi`— son
**`OOS2055`**, en cada uno de los dos, estén en el mismo paquete o en dos.

Una coordenada es lo que la herramienta pide, y la plataforma tiene que saber a qué documento
corresponde para decidir quién puede leerlo y de dónde se sirve. Con dos, la respuesta dependería
del orden de lectura. Que tengan nombres distintos en el catálogo no lo arregla: el nombre del
catálogo es de la plataforma; la coordenada, del ecosistema.

## 5. Lo que no es del documento

- **Las versiones y sus ficheros.** Se publican a la plataforma con las herramientas del formato
  (`mvn deploy`, `uv publish`), sin tocar el árbol. Una versión publicada es **inmutable**: no se
  reescribe ni se borra; se retira.
- **Que `format` y `coordinate` no cambien** después de publicar: lo comprueba quien guarda las
  versiones.
- **Quién puede publicar o leer**: del control de acceso de la plataforma, sobre el activo.

## 6. Las reglas

| código | la regla | sección |
|---|---|---|
| `OOS1003` | un `Artifact` que declara una versión anterior a v1alpha34 | §1 |
| `OOS1004` | `format` fuera del vocabulario o ausente; `coordinate` ausente o mal formada para su formato | §3 |
| `OOS1005` | una clave de `metadata` o `spec` que no está en §2 | §2 |
| `OOS2030` · `OOS2036` · `OOS2037` | su paquete y su schema, como todo contenido gobernado | §1 |
| `OOS2035` | dos `Artifact` con el mismo nombre en el mismo schema | §1 |
| `OOS2055` | dos `Artifact` con el mismo formato y la misma coordenada | §4 |
