# Suite de conformidad — v1alpha14

**Borrador, todavía sin casos.** Certificará lo que cambia en [`spec/v1alpha14/`](../../spec/v1alpha14/):
la vista con cuerpo SQL, su contrato derivado (`OOS2039`), lo que lee por nombre (`OOS2038`) y el
canal lateral sobre el linaje (`OOS4016`).

Como en v1alpha13, los `expects` se miden contra la implementación de referencia (ORE) **antes**
de escribirse: los casos llegan con la implementación, no antes. La afirmación que esta versión
tiene que sostener es que ningún resultado de v1alpha1 a v1alpha13 cambia —una vista con la
forma estructurada sigue siendo lo que era en su versión—.

Lo que cubrirá:

| | |
|---|---|
| **la vista SQL** | una proyección, un join, un agregado con `having`, una ventana, un `with` — válidas |
| **el contrato** | una columna de más, una de menos (`OOS2039`); un `*` contra la fuente |
| **lo que lee** | un nombre que no resuelve (`OOS2018`), dos sentencias, un `insert`, `read_parquet` (`OOS2038`) |
| **el canal lateral** | un rango sobre una columna con etiqueta (`OOS4016`); el mismo sobre una sin etiqueta (válido); `having count(*) >= 8` (válido) |
| **lo de otra versión** | `from`/`fields` en v1alpha14 (`OOS1005`); `sql` en v1alpha13 (`OOS1005`) |
| **la migración** | la misma vista en v1alpha13 (forma) y v1alpha14 (SQL): mismo contrato, mismo linaje |
