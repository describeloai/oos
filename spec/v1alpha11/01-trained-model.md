# 01 · TrainedModel — el modelo entrenado

**Estado:** borrador. Parte de OOS v1alpha11.
**Anfitrión:** ninguno. Es gramática propia. `framework` y `task` son texto: el nombre con el
que el código lo carga y lo que hace, y ninguno de los dos tiene un vocabulario que valga la
pena cerrar todavía.

---

## 1. Naturaleza

> **Un modelo entrenado es un documento de un paquete que nombra unos ficheros del lago por
> su prefijo y su digest, dice con qué se cargan y qué versión son, y de qué vistas salieron.**

Es **un asset del registro**, como una `Table` que `write()` deja: tiene dueño, está en un
paquete, se lista, se gobierna y tiene linaje. No es un operador dentro del grafo —eso es el
`Model` de v1alpha9, que se invoca—: es lo que una sesión de código produjo y publicó, y lo
que otro código carga.

## 2. Qué **no** es

- **No es el `Model` de v1alpha9.** Aquél nombra un perfil servido; éste nombra pesos. Ver
  `00-scope` §2.
- **No lleva `labels`.** Lo que un modelo produce llega al retículo por los endosos de la
  función que lo use; una etiqueta que el modelo se ponga a sí mismo sería la afirmación sobre
  uno mismo que `Function` tampoco puede hacer. Su clasificación de **entrada** ya está en las
  vistas de `trainedFrom`.
- **No lleva métricas ni hiperparámetros.** No hay vocabulario que los haga comparables, y
  `description` es texto (`00-scope` §5).
- **No es una versión de otro documento.** `version` es un entero y cada versión publicada
  es un commit del mismo documento; la historia es la del árbol.

## 3. La forma

```yaml
apiVersion: oos.dev/v1alpha11
kind: TrainedModel
metadata:
  name: prevision
  namespace: ventas
  description: …                          # opcional
spec:
  owner: team:ventas                       # quién responde por él
  framework: sklearn                       # con qué se carga: texto
  task: forecast                           # opcional: qué hace, texto
  version: 3                               # entero ≥ 1
  artifacts: models/ventas_prevision/v3    # el prefijo del lago donde están sus ficheros
  digest: sha256:…                         # el digest del manifiesto de esos ficheros
  trainedFrom: [ventas.ventas]             # opcional: de qué vistas salió; cada una tiene que resolver
```

| clave | | |
|---|---|---|
| `owner` | **obligatoria** | `team:<n>` o `user:<n>`, como en `View`. `OOS2009` si no lo es |
| `framework` | **obligatoria** | texto no vacío: `sklearn`, `xgboost`, `torch`, `statsmodels`… lo que el código importa para cargarlo |
| `task` | opcional | texto no vacío: `forecast`, `classify`, `embed`… |
| `version` | **obligatoria** | entero **≥ 1**. Publicar otra versión es cambiar este número, `artifacts` y `digest` en el mismo commit |
| `artifacts` | **obligatoria** | el prefijo, relativo a la raíz del lago del inquilino, bajo el que están los ficheros: minúsculas, dígitos, `_`, `-`, `.` y `/`; sin barra inicial ni final |
| `digest` | **obligatoria** | `sha256:<64 hex>`: el digest del **manifiesto** de los artefactos (la lista de ficheros con su tamaño y su digest, en forma canónica). Lo que se carga es esto, o no se carga |
| `trainedFrom` | opcional | nombres cualificados de **vistas** del árbol (`<ns>.<vista>`), un conjunto: el orden no significa nada y la forma canónica lo ordena. Es el linaje: por aquí baja la gobernanza |

## 4. Las reglas

| | código | |
|---|---|---|
| sin `owner`, `framework`, `version`, `artifacts` o `digest` | `OOS1004` | la forma mínima |
| `version` que no es un entero ≥ 1 | `OOS1004` | |
| `artifacts` con la forma mal | `OOS1004` | |
| `digest` que no es `sha256:<64 hex>` | `OOS1004` | |
| `framework` o `task` vacíos | `OOS1004` | |
| `owner` que no es `team:` ni `user:` | `OOS2009` | como en `View` |
| una clave que no es de aquí (`metrics`, `hyperparameters`, `runtime`, `profile`…) | `OOS1005` | |
| `labels` en `metadata` | `OOS1005` | no se etiqueta a sí mismo |
| sin `metadata.namespace` | `OOS1004` | vive en un paquete |
| un `trainedFrom` que no resuelve a una vista | `OOS2005` | como `from` en una vista, o `reads` en una función (`OOS7014` es de la función; aquí no hay sandbox que acotar, y basta con que exista) |
| `kind: TrainedModel` en v1alpha10 o antes | `OOS1003` | es un documento de v1alpha11 |

## 5. Lo que la gramática no decide

**Que los artefactos estén y que el digest sea el suyo.** Eso es un hecho del bucket y lo
coteja quien escribe el documento en el árbol —en ORE, el verbo que publica desde la sesión,
que sube los ficheros, calcula el manifiesto y escribe el documento en el mismo acto—. La
gramática admite un `digest` bien formado de unos ficheros que no están, y es a propósito: un
árbol tiene que poder leerse sin el bucket, y un documento no caduca porque un bucket se
vacíe. Lo que sí cambia es lo que el catálogo enseña de él, y eso lo dice el puntero, no el
documento.

**El puntero.** Qué versión es la vigente, cuándo se publicó y quién: lo que `write()` deja
para una tabla en su puntero lo deja el verbo que publica para un modelo (`models/<ns>_<n>.json`
en ORE). No es de la gramática.
