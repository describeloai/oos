# OOS v1alpha22 · 01 — nunca nula

**Normativo.** Las palabras DEBE, NO DEBE, DEBERÍA y PUEDE se interpretan como en RFC 2119.

## 1. Lo que cambia

La columna de una `Table` gana una clave:

```yaml
apiVersion: oos.dev/v1alpha22
kind: Table
metadata: { name: pedidos_t, namespace: ventas, schema: public }
spec:
  datasource: erp
  object: "public.pedidos"
  columns:
    id: { type: Integer, physicalType: bigint, required: true }
    cliente: { type: String, physicalType: text, required: true }
    nota: { type: String, physicalType: text }
  reads: {}
  changes: { mode: none, witness: none, key: [id] }
```

Todo lo demás de `Table` es lo de v1alpha16.

## 2. La forma

`columns.<c>.required` es **opcional** y, si está, DEBE ser un booleano. Un valor que no lo es es
`OOS1004`. Sin la clave, la columna es nulable: lo mismo que `required: false`, y lo mismo que
significaba una columna en v1alpha21.

Las claves de una columna de `Table` son, desde v1alpha22, `type`, `physicalType`, `description` y
`required`, más las de extensión (`x-<proveedor>-`). Cualquier otra es `OOS1005`: también
`labels`, que el esquema de ninguna versión admitía en una columna y que algún árbol lleva. La
clasificación de un dato la declara la entidad (v1alpha12 `00` §5); una tabla que la lleve en sus
columnas sigue en su versión hasta quitarla.

En un documento que declara una versión **anterior** a v1alpha22, `required` en una columna de
`Table` es una clave desconocida: `OOS1005`. La versión dice qué gramática se habla.

## 3. Lo que significa

`required: true` dice que **el origen garantiza que la columna nunca es nula**. Es un hecho físico,
del objeto, como `physicalType`, y por eso vive en la tabla y no en la vista ni en la entidad.

- **Sólo una garantía.** DEBE venir de lo que el propio origen declara y hace cumplir: un
  `NOT NULL`, un `mode: REQUIRED`, un campo `required` de Parquet o de Iceberg, un `nullable: false`
  de Arrow.
- **Una observación NO DEBE escribirse como `required`.** Que todas las filas vistas tuvieran valor
  —en un JSONL, en un CSV, en una muestra— no dice nada de la siguiente. Su sitio es una aserción de
  un `Ruleset`, que se comprueba, o ninguno.
- **Una herramienta que descubre** el objeto DEBERÍA escribirlo desde el catálogo del origen, igual
  que escribe `physicalType`.
- **No es la semántica.** `Entity.properties.<p>.required` dice que el concepto exige el valor; esto
  dice que el origen lo garantiza. Pueden discrepar, y una herramienta PUEDE avisar de una propiedad
  `required` cuya columna no lo es: la semántica pide lo que la física no garantiza, y lo que lo
  comprueba es un `Ruleset`.

## 4. Se deriva, no se declara

Una `View` y un `Dataset` **no** declaran `required` en sus `columns`: en cualquier versión es
`OOS1005`, como ya lo era.

Lo que expone una vista se calcula de lo que lee. Una implementación PUEDE derivar qué columnas de
una vista o de un dataset nunca son nulas —una columna leída tal cual de una columna `required`, el
lado que conserva sus filas de un `JOIN`, un `COUNT`—, y si lo hace, la derivación DEBE ser
conservadora: **ante la duda, nulable**. Decir «nunca nula» de lo que puede serlo es peor que no
decir nada, porque los motores se apoyan en ello.

## 5. Evolución

- **Aflojar sigue al origen.** Si el origen deja de garantizar el valor, la herramienta que
  descubre DEBE quitar `required` de la columna. Que la tabla diga una garantía que el origen ya no
  da es una deriva.
- **Endurecer lo materializado exige verificar.** Una implementación que materializa datos NO DEBE
  marcar como obligatoria, en el sitio, una columna de datos que ya existen sin comprobar todas sus
  filas, o reescribirlas. Los formatos lo permiten —Iceberg acepta el cambio sin mirar los datos—, y
  un motor que se fía de la marca da entonces cifras falsas sin error: un `COUNT(x)` que no cuenta el
  nulo que hay.

## 6. La versión del documento

Un documento `Table` con `required` en alguna columna declara **v1alpha22**. Uno sin él PUEDE seguir
declarando la versión que tenía: la más baja que lo describe.
