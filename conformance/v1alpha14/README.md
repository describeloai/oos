# Suite de conformidad — v1alpha14

**Borrador.** Certifica lo que añade [`spec/v1alpha14/`](../../spec/v1alpha14/): la `View` es
SQL —`spec.sql`, `spec.dialect`, `spec.columns`—, y lo que se gobierna de ella se deriva de la
consulta. El alcance sigue **abierto** y **no es normativo**.

---

## Por qué vive en su propio árbol

Por lo mismo que los demás borradores: un marcador significa *una implementación de referencia
pasa esto*. **Los árboles anteriores no se tocan**: la afirmación que esta versión tiene que
sostener es que no cambia un solo resultado de v1alpha1 a v1alpha13 —una vista de antes sigue
siendo lo que era—.

## Qué cubre

Nueve casos que aceptan y diecisiete que rechazan. Se escribieron desde la spec, antes que la
implementación: los `expects` se cotejan contra la de referencia (ORE, ADR 0040) según se
implementa, y un caso que la implementación contradiga se discute, no se ajusta en silencio.

Todos parten del mismo árbol: `hr.employees` (una `Table` de `erp`), la vista SQL
`hr.empleados` que la renombra y quita los borrados, y la entidad `Employee`, que la respalda y
etiqueta `dni` con `gdpr.sensitivity: high`.

| | Casos |
|---|---|
| **la vista es su consulta** | `a-view-in-sql` · `a-view-over-a-sql-view` · `a-join-and-a-grouping` · `rows-from-a-generator` |
| **el documento** | `the-structured-form-in-v1alpha14` (OOS1005) · `a-view-without-its-dialect` · `a-dialect-it-does-not-know` (OOS1004) |
| **lo que lee** (§3) | `reads-by-a-function` · `two-statements` · `a-view-that-writes` (OOS2038) · `a-name-that-is-not-in-the-tree` (OOS2018) · `a-chain-that-comes-back` (OOS2019) |
| **un nombre, una cosa** (§3) | `a-view-named-like-its-table` (OOS2035) · `a-name-that-names-two-things` (OOS2018) |
| **el contrato** (§4) | `a-column-the-query-does-not-project` · `a-projection-the-contract-does-not-name` (OOS2039) · `a-column-the-source-does-not-have` (OOS2018) |
| **el linaje** (§5) | `a-dataset-copies-a-sql-view` · `a-copy-that-leaks-through-a-filter` (OOS4002: la arista INDIRECT de un `WHERE`) |
| **el canal lateral** (§6) | `equality-on-a-labeled-column` · `a-range-on-a-column-without-a-label` · `a-k-threshold-on-an-aggregate` · `a-range-on-a-labeled-column` · `a-pattern-on-a-labeled-column` · `a-function-on-a-labeled-column` (OOS4016) |
| **la migración** (§7) | `a-sql-view-over-a-structured-view` |

`a-range-on-a-column-without-a-label` y `a-range-on-a-labeled-column` son el mismo predicado
sobre dos columnas: es lo que demuestra que la frontera se traza sobre el linaje y no sobre la
gramática. `a-copy-that-leaks-through-a-filter` es el flujo implícito de v1alpha7 con otra
forma: la copia sólo expone `id`, y aun así lleva la etiqueta de `dni`.

Lo que se comprueba y no tiene caso propio: que la forma canónica guarda `sql` byte a byte
(lo prueba la implementación en su suite, porque aquí se compara el resultado de validar), los
tipos del contrato (los comprueba el motor que resuelve la consulta, no un compilador; §4.3) y
servir a otro dialecto (§8).
