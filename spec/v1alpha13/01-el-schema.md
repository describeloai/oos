# OOS v1alpha13 · 01 — el schema

**Estado:** borrador. [`00-scope`](00-scope.md) dice por qué; este documento dice qué.

---

## 1. Naturaleza

Un **schema** es el segundo nivel del nombre de lo que un paquete tiene: el paquete lo
contiene, y él contiene tablas, vistas, datasets, entidades, funciones, acciones y modelos
entrenados. Ordena —es la carpeta donde viven— y **nombra**: `ventas.espana.pedidos` y
`ventas.francia.pedidos` son dos documentos.

Todo paquete tiene un schema **`default`** que no se declara: es donde está lo que no dice
otro, y lo que había antes de esta versión.

## 2. El documento `Schema`

```yaml
apiVersion: oos.dev/v1alpha13
kind: Schema
metadata:
  name: espana
  namespace: ventas
  description: Lo que se vende en España.   # opcional
spec:
  owner: team:ventas-es                      # opcional: sin él, el del paquete
```

| clave | | |
|---|---|---|
| `metadata.name` | `identifier` | el nombre del schema. **No** puede ser `default` —existe sin declararse— ni `information_schema` —reservado, como en SQL— (`OOS1004`) |
| `metadata.namespace` | `identifier` | el paquete, como en todo contenido gobernado (`OOS2030`) |
| `metadata.description` | texto | opcional |
| `spec.owner` | `team:` o `user:` | opcional; sin él responde el dueño del paquete (`OOS2009` si no lo es) |

Un `Schema` **vive en su carpeta**: el documento está directamente en
`<paquete>/<name>/` —la carpeta del paquete es la de su `package.yaml`—, y esa carpeta **es**
el schema (`OOS2036`). El nombre del fichero no es normativo; `schema.yaml` es la costumbre,
como `package.yaml`.

Su identidad es `Schema:<paquete>.<name>` —dos partes: un schema no está en un schema—. Dos
documentos `Schema` con el mismo nombre en el mismo paquete son `OOS2035`.

## 3. `metadata.schema`

El contenido gobernado —`Entity`, `View`, `Table`, `Dataset`, `Function`, `Action`,
`TrainedModel`— admite `metadata.schema`: un `identifier` que nombra un schema de **su**
paquete. Si falta, es `default`.

```yaml
apiVersion: oos.dev/v1alpha13
kind: Dataset
metadata: { name: pedidos, namespace: ventas, schema: espana }
spec: { owner: team:ventas-es, columns: { id: { type: Integer } }, changes: { mode: append } }
```

- Nombra un schema **declarado** en el paquete, o `default` (`OOS2037` si no).
- El documento vive **dentro de la carpeta de ese schema** —a cualquier profundidad: las
  carpetas de debajo (`datasets/`, `views/`, la de un repositorio…) ordenan ficheros y no
  nombran nada—; y uno en `default` vive **fuera** de toda carpeta de schema (`OOS2036`).

El vocabulario compartido —`Lattice`, `Ruleset`, `Concept`, `Interface`, las políticas— **no**
la admite (`OOS1005`): se nombra por su vocabulario ([`00-scope` §5](00-scope.md)). Tampoco
`Resolution`, que es contenido del paquete pero no del catálogo —es de la entidad cuya
identidad resuelve—: está en `default`, y nombra a la entidad en una, dos o tres partes como
cualquier referencia.

## 4. El nombre

El nombre cualificado del contenido gobernado es

```
<paquete>.<schema>.<nombre>          ventas.espana.pedidos · ventas.default.clientes
```

y su identidad, la de siempre —`kind` + nombre cualificado—: `Dataset:ventas.espana.pedidos`.
**Es único por schema**: dos `pedidos` en `espana` y en `francia` son dos documentos; dos en
`espana`, `OOS2035`.

Un documento de una versión anterior está en `default`: se llama `<paquete>.default.<nombre>`
donde se compara identidad (§6 para la forma canónica, que no cambia).

## 5. Las referencias

Una referencia a contenido gobernado —`from`, `backedBy`, `over`, `reads`, `targetEntity`,
`trainedFrom`, `exports`, `derivedFrom`, `effects`…— se lee por su número de partes:

| partes | se lee | ejemplo, desde un documento de `ventas.espana` |
|---|---|---|
| **una** | el mismo paquete y **el mismo schema** | `pedidos` → `ventas.espana.pedidos` |
| **dos** | `<paquete>.<nombre>` en el schema **`default`** de ese paquete | `hr.empleados` → `hr.default.empleados` |
| **tres** | el nombre completo | `ventas.francia.pedidos` |

Dos partes es **la forma de antes**, y significa lo que significaba: lo escrito hasta hoy sigue
nombrando lo mismo. Para nombrar otro schema —del mismo paquete o de otro— se escriben las tres.
Que una referencia de dos partes haya que reescribirla algún día es de las herramientas, que
pueden avisar; la gramática la lee.

**Una referencia a una propiedad** (`hr.Employee.baseSalary`) sigue siendo lo que era: el campo
dice que nombra una propiedad, la propiedad es **el último segmento**, y lo de delante es una
referencia a la entidad que se lee con esta tabla: `Employee.baseSalary` (una parte),
`hr.Employee.baseSalary` (dos: `hr.default.Employee`), `hr.rrhh.Employee.baseSalary` (tres).
Nunca se adivina por el número de puntos.

Las referencias al vocabulario compartido no cambian.

## 6. La forma canónica y el digest

En un documento de v1alpha13:

- **N1** expande toda referencia a contenido gobernado a sus **tres** partes (`pedidos` →
  `ventas.espana.pedidos`, `hr.empleados` → `hr.default.empleados`).
- **N2** escribe `metadata.schema` aunque sea `default`: la forma canónica no tiene valores
  implícitos.
- El `docId` de §5.2 es `kind:<paquete>.<schema>.<nombre>`; el de un `Schema`,
  `Schema:<paquete>.<name>`.

Un documento de una versión anterior **no cambia**: su forma canónica no lleva la clave, sus
referencias se expanden a dos partes como siempre, y su `docId` es el de dos partes. Un paquete
que no toca ningún documento no cambia de digest.

## 7. Las reglas

| código | la regla | desde |
|---|---|---|
| `OOS2036` | un documento con schema vive en la carpeta de ese schema, y uno en `default`, fuera de toda carpeta de schema; un `Schema`, directamente en la carpeta que nombra | v1alpha13 |
| `OOS2037` | `metadata.schema` nombra un schema que el paquete no declara (y no es `default`) | v1alpha13 |
| `OOS2005` · `OOS2018` | una referencia de una, dos o tres partes que no resuelve, con el nombre al que se expandió | como siempre |
| `OOS2035` | dos documentos con la misma identidad: ahora, en el mismo schema | como siempre |
| `OOS1003` · `OOS1005` | `kind: Schema` o `metadata.schema` en una versión anterior | v1alpha13 |

`OOS2036` es a la carpeta del schema lo que `OOS2030` es a la del paquete, y por la misma
razón: el nombre lo dice el documento, la ruta no nombra nada, y las dos tienen que estar de
acuerdo para que *«mover un fichero»* signifique una sola cosa.

## 8. Lo que la gramática no decide

- **Cómo se escribe el nombre en SQL**, en qué motor, y qué hace uno con las dos partes: de
  quien ejecuta la consulta.
- **Quién puede qué en un schema**: del plano de control.
- **Cómo se mueve un documento de schema** (y se reescriben quienes lo nombran): de las
  herramientas.
- **Qué hay en una carpeta que no es de schema** bajo un paquete —un repositorio, las carpetas
  del `kind`—: no nombra nada, y la gramática no la mira.
