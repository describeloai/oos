# OOS v1alpha14 · 01 — la vista es SQL

**Estado:** borrador. [`00-scope`](00-scope.md) dice por qué; este documento dice qué.
**Sustituye**, para los documentos v1alpha14, al cuerpo de la vista de
[`v1alpha8/02-view`](../v1alpha8/02-view.md) y [`v1alpha12/02-la-vista-y-la-entidad`](../v1alpha12/02-la-vista-y-la-entidad.md) §1:
`from`, `fields`, `where`, `groupBy` y `having`. Lo demás de la vista —su dueño, su nombre, su
sitio, su versión, `moved` y `reserved`— sigue como estaba.

---

## 1. Naturaleza

Una **vista** es una consulta SQL con nombre, gobernada: un documento del árbol, con dueño y
versión, que otros nombran —una entidad la respalda (`backedBy`), un dataset la copia
(`from: { view }`), otra vista la lee—. Nace del lado del código —un `CREATE VIEW` en una
sesión, un `.sql`— y se promociona como cualquier documento: **sigue siendo SQL** después de
promocionarse. Lo que se gobierna de ella no se escribe dos veces: **se deriva de la consulta**.

## 2. El documento

```yaml
apiVersion: oos.dev/v1alpha14
kind: View
metadata: { name: gasto_por_cliente, namespace: ventas, schema: espana }
spec:
  owner: team:ventas-es
  dialect: duckdb
  sql: |
    SELECT c.id, c.nombre, count(p.id) AS pedidos, sum(p.total) AS gastado
    FROM ventas.espana.clientes c
    LEFT JOIN ventas.espana.pedidos p ON p.cliente_id = c.id
    GROUP BY c.id, c.nombre
  columns:                       # el contrato: lo deriva quien declara la vista (§4)
    id: { type: Integer }
    nombre: { type: String }
    pedidos: { type: Integer }
    gastado: { type: Decimal }
```

| clave | | |
|---|---|---|
| `spec.owner` | `team:` o `user:` | quien responde de la vista, como siempre (`OOS2009`) |
| `spec.sql` | texto | **una** consulta: un `SELECT` —con `WITH`, `UNION`, joins, expresiones, agregados, ventanas…—, en el dialecto de `dialect`. Nada que escriba y una sola sentencia (`OOS2038`) |
| `spec.dialect` | `duckdb` | el dialecto en que `sql` está escrito. En esta versión, `duckdb`: el motor de referencia de la sesión (§8) |
| `spec.columns` | mapa | **el contrato**: lo que la vista expone, columna a columna, con su tipo en el vocabulario de OOS. Derivado de `sql` (§4) |
| `spec.moved`, `spec.reserved` | | como en v1alpha8, sobre los nombres de `columns` |
| `metadata.description` | texto | opcional, como en todo documento |

`from`, `fields`, `where`, `groupBy`, `having`, `materialized` y `freshness` en un documento
v1alpha14 son `OOS1005`.

**Forma canónica.** `sql` es un texto y entra en la forma canónica tal cual, byte a byte: dos
vistas que sólo difieren en un espacio son dos versiones. Quien escribe una vista decide su
texto; normalizarlo sería reescribir lo que alguien escribió.

## 3. Lo que lee

Lo que una vista lee son los **nombres del árbol** que aparecen en su consulta como fuente —tras
un `FROM` o un `JOIN`, dentro de un `WITH`, de una subconsulta o de un lado de un `UNION`—. Se
escriben en una, dos o tres partes y se resuelven con la regla de siempre
([`v1alpha13/01-el-schema` §5](../v1alpha13/01-el-schema.md)): cada uno **DEBE** resolver a una
`Table`, una `View` o un `Dataset` (`OOS2018`), y la cadena no puede volver sobre sí misma
(`OOS2019`). Un nombre del `WITH` de la propia consulta no es un nombre del árbol.

**Un nombre, una cosa.** En SQL un nombre no dice su `kind`: `FROM ventas.clientes` no puede
elegir entre una tabla y una vista que se llamen así. Por eso, desde esta versión, una `Table`,
una `View` y un `Dataset` **comparten el espacio de nombres de su schema**, como en Unity
Catalog: dos con el mismo nombre son la misma identidad, `OOS2035`, en cuanto uno de ellos es de
v1alpha14. Hasta v1alpha13 podían convivir —`from.table` y `from.view` decían cuál— y siguen
pudiendo; pero una consulta que nombra una pareja así no dice cuál lee, y es `OOS2018`. Una vista
sobre la tabla del mismo nombre se llama como lo que pregunta.

Se lee **por nombre, nunca por función**: una consulta que lee bytes que el árbol no nombra
—`read_parquet('s3://…')`, `iceberg_scan(…)`, una URL— no tiene linaje ni conducto, y es
`OOS2038`. Las funciones que generan filas sin leer nada (`range`, `generate_series`, `unnest`)
se admiten.

Lo que se lee **DEBE** ser algo que se deja leer, con las reglas de v1alpha12: un dataset; una
vista; una tabla de un origen, que se lee donde está (una vista sobre una `Table` es la vista de
una base *foreign*). Si esa lectura necesita una copia, lo dice `OOS2020` como hasta ahora.

## 4. El contrato: `columns`

`columns` es **lo que la vista expone**: es lo que una entidad con `backedBy` nombra
(`OOS2011`, `OOS2022`), lo que un dataset que la copia recibe, lo que otra vista lee y lo que
una propiedad de una función ve (`OOS7014`). Es el `fields` de antes, con su tipo.

**No se inventa: se deriva.** Lo escribe la herramienta que declara la vista —la sesión que
corre un `CREATE VIEW`, la migración— resolviendo la consulta contra las columnas de sus fuentes
(un motor la *describe* sin leer una fila) y traduciendo cada tipo al vocabulario de OOS. Una
persona puede añadir `description` a una columna; no puede cambiar su nombre ni su tipo sin
cambiar la consulta.

Lo que se comprueba:

1. **Los nombres de `columns` son exactamente los que la consulta proyecta** —cada alias, cada
   columna sin alias por su nombre, y un `*` por las columnas que expone su fuente—: ni uno de
   más, ni uno de menos (`OOS2039`). El orden no significa nada, como no lo significaba en
   `fields`. Un compilador sin motor lo comprueba con la sintaxis de la consulta y los
   contratos de sus fuentes.
2. **Cada columna que la consulta nombra existe en su fuente**: en `columns` de la tabla, en el
   contrato de la vista, en lo que el dataset expone (`OOS2018`).
3. **Los tipos** son los que el motor da al resolver la consulta. Un compilador sin motor no los
   comprueba; el motor que la corre, sí: si la consulta ya no da esos tipos —porque una fuente
   cambió—, la vista ha cambiado y su contrato también (§9).

## 5. El linaje

De la consulta se deriva, para cada columna de `columns`, **de qué columnas de sus fuentes
sale**:

- **directa**: la columna de la fuente tal cual, con otro nombre o sin él (`c.nombre`,
  `total AS importe`);
- **derivada**: una expresión o un agregado sobre ellas (`total * 1.21`, `sum(p.total)`,
  `upper(nombre)`), con todas las que lee.

Y además, **INDIRECT**, como hacía el `where` desde v1alpha7: cada columna que la consulta
**mira sin devolverla** —en un `WHERE`, en la condición de un `JOIN`, un `QUALIFY`, la
partición o el orden de una ventana, o una subconsulta que decide filas— deja una arista hacia
**todas** las columnas de salida: qué filas salen depende de ella.

La agrupación, como desde v1alpha8 (§5.8 de `02-view`):

- una clave de `GROUP BY` que la consulta **proyecta** deja su arista INDIRECT hacia las
  columnas que **no** son claves —los agregados, cuyo valor depende de cómo se juntan las
  filas—; hacia sí misma ya es directa;
- una clave que **no** se proyecta decide filas que no se ven, y deja su arista hacia todas;
- un `HAVING` mira lo que nombra **y las claves de grupo**, porque recorta por un agregado
  que sale de ellas: arista hacia todas.

La **regla de flujo** ([`v1alpha1/04-flow`](../v1alpha1/04-flow.md) §2) corre sobre estas
aristas exactamente como corría sobre las de la forma: la etiqueta de una raíz sube por las
directas, las derivadas y las indirectas, y un conducto por debajo de ella es `OOS4001` u
`OOS4002`.

**Si una implementación no puede derivar el linaje de una columna**, lo toma todo: esa columna
sale de todas las columnas que la consulta lee. Es conservador —lleva todas las etiquetas— y
nunca deja una sin llevar.

## 6. El canal lateral, sobre el linaje

La razón por la que el `where` de v1alpha7 era cerrado sigue en pie: **un predicado no filtra,
LEE**. Qué filas aparecen es observable, y un rango sobre una columna clasificada ordena en vez
de particionar: `WHERE salario > 90000` dice de cada fila que sale algo que su etiqueta prohíbe
decir. La igualdad, la pertenencia y la ausencia sólo revelan pertenencia a una clase, que es lo
que la vista ya afirma.

Por eso, en v1alpha14 la frontera se traza **sobre el linaje**, no sobre la gramática:

- Un predicado sobre una columna cuya **raíz lleva una etiqueta por encima de ⊥** en un eje de
  confidencialidad —por su datasource, o por la entidad que la cubre ([`v1alpha1/02-entity`](../v1alpha1/02-entity.md) §4.1)—
  **DEBE** ser de igualdad a un valor, pertenencia a una lista de valores o ausencia (`IS NULL`,
  `IS NOT NULL`), combinados con `AND` u `OR`. Cualquier otro —un rango, `BETWEEN`, un patrón
  (`LIKE`, una expresión regular), o una función aplicada a la columna antes de compararla— es
  **`OOS4016`**. Vale en `WHERE`, en la condición de un `JOIN` que no sea una igualdad entre
  columnas, y en `QUALIFY`.
- Sobre una columna **sin etiqueta**, cualquier predicado.
- Un `HAVING` sobre un **agregado** admite rangos, como desde v1alpha8 (§5.8 de `02-view`):
  `count(*) >= 8` es un umbral de k-anonimidad, no un canal lateral, y la clave de grupo deja su
  arista INDIRECT.

Si el linaje de un predicado no se puede derivar, se toma como si mirara todas las columnas que
lee: un rango ahí, con una sola raíz etiquetada, es `OOS4016`.

## 7. Compatibilidad y migración

Una vista v1alpha8–v1alpha13 **sigue siendo lo que era**: su forma compila con las reglas de su
versión, y todo lo que la nombra la sigue leyendo igual. Un árbol puede tener vistas de las dos
formas mientras migra.

**Una excepción, y es de seguridad.** Desde esta versión la regla de flujo corre sobre el linaje
por columna —con sus aristas INDIRECT (§5)— para **toda** vista, también las de antes: una
implementación gobierna una sola clase de vista. Una copia de v1alpha7 a v1alpha13 que expone
`id` y recorta por una columna etiquetada —`where: { nationalId: [...] }`— revela quién tiene ese
valor, y hasta ahora la regla de flujo sólo miraba lo que se copia: compilaba. Ahora es `OOS4001`
u `OOS4002`, como la misma vista escrita en SQL. Es el flujo implícito que v1alpha7 ya describía
(«un predicado no filtra, LEE») y que ninguna versión anterior comprobaba al compilar; no
cambia ningún resultado que no fuera una fuga.

La migración es **mecánica**, porque la forma estructurada **es** una consulta:

| antes (v1alpha13) | después (v1alpha14) |
|---|---|
| `from: { table: pedidos_t }` · `from: { view: v }` · `from: { dataset: d }` | `FROM <el nombre de la fuente>` |
| `fields: { importe: total, pais: pais }` | `SELECT total AS importe, pais` |
| `fields: { n: "count()", s: "sum(total)" }` + `groupBy: [pais]` | `SELECT pais, count(*) AS n, sum(total) AS s … GROUP BY pais` |
| `where: { pais: ES, estado: [pagado, enviado], baja: [] }` | `WHERE pais = 'ES' AND estado IN ('pagado', 'enviado') AND baja IS NULL` |
| `having: { n: ">= 8" }` | `HAVING count(*) >= 8` |
| los campos que expone | `columns`, con el tipo que la fuente da a cada uno |
| `moved`, `reserved` | igual |

Ejemplo:

```yaml
# v1alpha13
apiVersion: oos.dev/v1alpha13
kind: View
metadata: { name: grandes, namespace: hr }
spec:
  owner: team:hr
  from: { dataset: hr.resumen }
  fields: { empleados: n, pais: pais }
  where: { pais: [ES, PT] }
```

```yaml
# v1alpha14
apiVersion: oos.dev/v1alpha14
kind: View
metadata: { name: grandes, namespace: hr }
spec:
  owner: team:hr
  dialect: duckdb
  sql: |
    SELECT n AS empleados, pais
    FROM hr.resumen
    WHERE pais IN ('ES', 'PT')
  columns:
    empleados: { type: Integer }
    pais: { type: String }
```

La consulta migrada lee lo mismo, expone lo mismo y tiene el mismo linaje; y una vista que la
forma dejaba escribir cumple `OOS4016` por construcción, porque su `where` sólo tenía igualdad,
pertenencia y ausencia.

## 8. El dialecto

`dialect` dice en qué SQL está escrita la consulta. En esta versión hay uno, **`duckdb`**: el
motor de la sesión de referencia, donde nace un `CREATE VIEW`. Una implementación **DEBE**
aceptarlo. Servir una vista a un motor de otro dialecto —un catálogo Iceberg REST que la sirve
a Spark— es de una versión posterior: podrá traducirla o llevar una consulta por dialecto, como
las *representations* de una vista de Iceberg. Mientras, una implementación **PUEDE** no servir
a otro motor una vista que no sabe escribir en su dialecto, y lo dice.

## 9. Lo que es un cambio

Una vista cambia cuando cambia su consulta **o su contrato**. Para quien la consume, lo que
importa es el contrato:

- quitar una columna de `columns`, renombrarla sin `moved`, o cambiar su tipo, **rompe** a quien
  la lee (una entidad, una función, otra vista);
- añadir una columna, no;
- cambiar la consulta sin cambiar el contrato ni el linaje —otro orden, otro alias interno—, no
  rompe, pero es otra versión (su texto es otro, §2).

Y como en v1alpha8, **cambiar qué filas salen** —un filtro, un join, una agrupación— es un cambio
para quien la consume aunque las columnas sean las mismas: se dice en la versión.

## 10. Códigos

| Código | Condición |
|---|---|
| `OOS2038` | `sql` no es **una** consulta `SELECT` que lee por nombre: varias sentencias, una que escribe o crea, o una fuente leída por función (`read_parquet`, una URL) |
| `OOS2039` | `columns` no es exactamente lo que la consulta proyecta: sobra o falta una columna |
| `OOS4016` | un predicado que ordena (rango, `BETWEEN`, patrón, función) sobre una columna cuya raíz lleva una etiqueta de confidencialidad por encima de ⊥ |

Siguen valiendo, sobre la vista SQL: `OOS2009` (dueño), `OOS2011` y `OOS2022` (la entidad y su
vista, contra `columns`), `OOS2018` (un nombre que no resuelve, una columna que la fuente no
tiene), `OOS2019` (ciclo), `OOS2020` (una raíz que exige copia), `OOS2035`–`OOS2037` (nombre y
schema; y desde esta versión, una tabla, una vista y un dataset con el mismo nombre en el mismo
schema, §3), `OOS4001`, `OOS4002` y `OOS4011` (flujo y conducto) y `OOS7014` (lo que una función ve).
Dejan de aplicarse a una vista v1alpha14, porque la forma que comprobaban ya no está: `OOS2032`,
`OOS2033` y `OOS2034` —agrupar y agregar los comprueba el motor al resolver la consulta—.
