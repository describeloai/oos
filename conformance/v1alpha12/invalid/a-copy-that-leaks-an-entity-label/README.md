# v1alpha12 / invalid / a-copy-that-leaks-an-entity-label

**Regla:** [`01-dataset.md` 5](../../../../spec/v1alpha12/01-dataset.md#5) · **Nivel:** L0

---

El mismo caso que `v1alpha8/invalid/materialized-view-leaks-entity-label`, con `hr.empleados` como `Dataset` mantenido en lugar de la `View` con `materialized`, y **el mismo código**. `Employee.dni` es `high`, baja por `iberia` (`dni: nationalId`) hasta `empleados` (`nationalId: national_id`), y `empleados` copia por un conducto que admite `low`. La etiqueta llega al plan del dataset como llegaba al de la vista.
