# OOS v1alpha22 — alcance

**Estado:** borrador de alcance. Gobierna los documentos que declaran su `apiVersion`, y es
**alpha**: sin garantías de compatibilidad.

| | |
|---|---|
| `00-scope` | **este documento** — qué entra, qué no, y por qué |
| [`01-nunca-nula`](01-nunca-nula.md) | una columna de `Table` dice que **el origen garantiza que nunca es nula**: `columns.<c>.required`. Una vista y un dataset no lo declaran: se deriva |

Esta versión **añade una clave** —`required`, opcional— a la columna de una `Table` y **no añade
códigos**: en una versión anterior es `OOS1005`, y un valor que no es un booleano es `OOS1004`.

---

## 1. La tesis

| capa | ¿dice que una columna nunca es nula? |
|---|---|
| semántica · `Entity.properties.<p>.required` | sí, desde v1alpha1: **el concepto exige el valor** |
| calidad · una aserción de un `Ruleset` | sí: **se comprueba** que no hay nulos |
| física · `Table.columns.<c>` | **no hasta v1alpha22** |

Todo origen tabular lleva la marca: el `mode: REQUIRED` de BigQuery, `NOT NULL` en PostgreSQL,
`required` en Parquet e Iceberg, el `nullable` de Arrow. El conector la lee al descubrir el objeto,
y la gramática no tenía dónde escribirla: la tabla, que es el hecho del origen, la perdía. Sin ella,
todo consumidor ve cualquier columna como posible nulo —los identificadores incluidos— y un
contrato no puede afirmar lo que el origen ya garantiza.

La pidió la plataforma que implementa OOS (ORE 0051, «ORE Null Contract», 2026-10-02): el origen
**declara**, las vistas **derivan** y lo materializado **impone**.

## 2. Qué entra

- **`required`** en la columna de una `Table`: opcional, booleano. `true` dice que el origen
  garantiza que la columna nunca es nula; sin la clave, o con `false`, puede serlo (`01` §2, §3).
- **Sólo una garantía.** Lo que se ha visto en una muestra no es `required` (`01` §3).
- **Vistas y datasets no lo declaran**: se deriva (`01` §4).
- **Una regla de evolución**: aflojar sigue al origen; endurecer lo materializado exige verificar
  (`01` §5).
- **Lo que se expone sale del árbol**: un campo de GraphQL es `T!` sólo si su columna nunca es nula,
  y el `required` de una propiedad no lo pone (`01` §7); de esa discrepancia se avisa (`01` §8).

## 3. Qué no entra

- **Cambiar lo que ya existe.** Una columna sin `required` significa lo mismo que en v1alpha21:
  puede ser nula. Ningún árbol cambia de significado al subir de versión.
- **`required` en `View` y `Dataset`.** Lo que expone una consulta se calcula; escrito a mano, miente
  el día que alguien cambia un `JOIN`.
- **Claves primarias o únicas impuestas.** Son otra decisión, y en la industria son informativas.
  `changes.key` ya dice qué identifica una fila, con su propio papel.
- **Imponer en la gramática.** Qué hace un motor con la marca —rechazar una escritura, optimizar una
  lectura— es de quien lo implementa; aquí se dice qué significa y cuándo NO DEBE escribirse.
