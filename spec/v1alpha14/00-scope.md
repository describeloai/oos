# OOS v1alpha14 — alcance

**Estado:** borrador de alcance. Gobierna los documentos que declaran su `apiVersion`, y es
**alpha**: sin garantías de compatibilidad.

| | |
|---|---|
| `00-scope` | **este documento** — qué entra, qué no, y por qué una vista es SQL |
| [`01-la-vista-es-sql`](01-la-vista-es-sql.md) | la vista: su cuerpo SQL, su dialecto, el contrato que se deriva de él, lo que lee, su linaje, el canal lateral sobre el linaje, y la migración |

Esta versión **cambia un `kind`** —`View`—: su cuerpo deja de ser una forma estructurada
(`from` · `fields` · `where` · `groupBy` · `having`) y pasa a ser **una consulta SQL**, con su
dialecto y el contrato de columnas que se deriva de ella. Añade tres códigos: `OOS2038`,
`OOS2039` y `OOS4016`. Los demás `kind` no cambian.

---

## 1. La tesis

| versión | verbo | la regla |
|---|---|---|
| v1alpha7 | **preguntar** | la vista es la pregunta y compone |
| v1alpha8 | **apuntar** | lo físico se registra una vez, con dos caras |
| v1alpha9 | **razonar** | un modelo que se usa es un documento del árbol, y nombra un perfil medido |
| v1alpha10 | **actuar** | lo que una función toca se lee en su documento, en los dos sentidos |
| v1alpha11 | **publicar** | lo que el código produce y no es una tabla entra en el árbol como un documento que nombra sus bytes |
| v1alpha12 | **tener** | lo que un inquilino tiene es un documento de su paquete, y uno solo, se llene como se llene |
| v1alpha13 | **ordenar** | lo que se tiene se ordena en schemas, y el schema es parte del nombre |
| **v1alpha14** | **escribir** | **una vista se escribe en SQL; lo que se gobierna de ella se deriva de lo escrito** |

Desde v1alpha7 la vista era **la pregunta**, y la pregunta se escribía en una forma cerrada: una
fuente, campos que renombran, un filtro de igualdad, pertenencia o ausencia, y —desde v1alpha8—
agrupar y agregar. Esa forma se eligió porque cada operación tenía un precio en la regla de
flujo y se decidía antes de admitirla (v1alpha7 `01-view` §4, §8), y porque sin un motor de SQL
era lo único que un compilador podía analizar entero.

Medido contra lo que se escribe (ORE, `medida-la-vista-sql.py`): de 24 consultas típicas de un
`CREATE VIEW` —las de Databricks, Snowflake o un modelo de dbt—, **6** caben en la forma. Las
otras 18 no: expresiones, joins, filtros de rango, ventanas, `with`, `union`. Y lo que la forma
aseguraba **se puede derivar de la consulta**: su esquema de salida (24 de 24, sin datos) y su
linaje por columna (21 de 23). La forma no se ganaba lo que costaba.

## 2. Por qué SQL, y no una forma más grande

Porque la industria ya separó las dos capas, y las dos existen aquí:

- **La vista relacional es texto SQL, con lo gobernado al lado.** Así la registra Unity Catalog
  (el SQL, y el linaje y las etiquetas los calcula el catálogo), así Snowflake, y así la
  especificación de vistas de Iceberg (versiones de la consulta, cada una en su dialecto, más su
  esquema). dbt escribe el SQL y declara al lado el contrato de columnas que se comprueba contra
  él.
- **La capa semántica es estructurada** —dimensiones, medidas, relaciones— y no es una consulta:
  LookML, MetricFlow, las *metric views* de Databricks, las *semantic views* de Snowflake. En OOS
  esa capa ya existe: es la **`Entity`**, con sus propiedades, su clave, sus relaciones y su
  `backedBy`.

La `View` estaba en medio: una forma de capa semántica para un contenido que es una consulta
relacional recortada. Esta versión la pone en su capa. **Lo que se escribe es SQL; lo que se
gobierna —el contrato, lo que lee, el linaje, las etiquetas, el canal lateral— se deriva de él.**
Lo estructurado se queda donde aporta: en la semántica.

## 3. Por qué el gobierno no se pierde

Porque nunca estuvo en la forma: estaba en lo que la forma dejaba saber.

- **Lo que lee** lo dice la consulta: sus nombres del árbol (§3 de `01`).
- **Lo que expone** lo dice el contrato, `columns`, que se deriva de la consulta y tiene que
  cuadrar con ella (§4).
- **Por dónde viaja una etiqueta** lo dice el linaje por columna, que también se deriva: cada
  columna de salida sale de unas columnas de sus fuentes, y cada columna que un predicado, un
  join o una agrupación mira deja una arista INDIRECT, como hacía el `where` (§5).
- **El canal lateral** —«un predicado no filtra, LEE» (v1alpha7 `01-view` §7)— sigue siendo la
  regla, y ahora se comprueba **sobre el linaje** y no sobre la gramática: un predicado que
  ordena (un rango, un patrón, una función) sobre una columna cuya raíz lleva una etiqueta se
  niega (`OOS4016`); sobre una columna sin etiqueta, se permite. Es la misma frontera, trazada
  donde importa (§6).

## 4. Qué entra

- `View.spec.sql` —una consulta `SELECT`, cualquiera—, `View.spec.dialect` y `View.spec.columns`,
  el contrato derivado. [`01-la-vista-es-sql` §2–§4](01-la-vista-es-sql.md).
- Lo que lee la vista, derivado de la consulta, con la regla de nombres de siempre. §3.
- El linaje por columna y la regla de flujo sobre él. §5.
- El canal lateral sobre el linaje, `OOS4016`. §6.
- `OOS2038` (la consulta no es un `SELECT` que lee por nombre) y `OOS2039` (el contrato no es lo
  que la consulta proyecta). §8.

## 5. Qué no entra, y por qué

- **La forma estructurada en v1alpha14.** Una vista es una sola cosa: SQL. `from`, `fields`,
  `where`, `groupBy` y `having` en un documento v1alpha14 son `OOS1005`. Los documentos de
  versiones anteriores siguen siendo lo que eran (§7 de `01`).
- **Otros dialectos servidos desde el mismo cuerpo.** Una vista declara el dialecto en que está
  escrita (`duckdb` en esta versión). Servirla a un motor de otro dialecto —traducirla, o llevar
  varias versiones como hace Iceberg— es de una versión posterior, cuando haya un segundo motor
  que lo pida.
- **Escribir a través de una vista.** Una vista SQL no es un camino de escritura: `OOS7013`
  sigue reservado y ninguna vista SQL es invertible.
- **Mantenimiento incremental de una vista.** Qué parte de una consulta se puede refrescar sin
  recalcularla entera es del motor que la mantiene, no de esta gramática. Una copia de una
  vista (`Dataset` con `from: { view }`) se rehace entera mientras el motor no diga otra cosa.
- **Comprobar los tipos en el compilador.** El contrato lleva tipos, y los deriva quien
  resuelve la consulta —un motor que la describe sobre las columnas de sus fuentes—. Un
  compilador sin motor comprueba los **nombres** (§4 de `01`); los tipos los comprueba el motor
  al resolverla.

## 6. Compatibilidad y migración

Ningún documento de v1alpha1 a v1alpha13 cambia de resultado: una vista v1alpha8–v1alpha13
sigue teniendo su forma, y todo lo que la nombra —una entidad con `backedBy`, un dataset con
`from: { view }`, otra vista— la sigue leyendo igual. La migración es **mecánica** y no pierde
nada: la forma estructurada **es** una consulta —las implementaciones ya la escriben en SQL para
servirla— y sus campos son su contrato. [`01-la-vista-es-sql` §7](01-la-vista-es-sql.md).
