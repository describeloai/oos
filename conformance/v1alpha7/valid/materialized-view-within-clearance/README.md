# v1alpha7 / valid / materialized-view-within-clearance

**Regla:** [`01-view.md` §5.2](../../../../spec/v1alpha7/01-view.md#52) · **Nivel:** L0

---

El gemelo de `invalid/materialized-view-leaks-entity-label`, con la autorización puesta.

`empleados` se copia a `lago`. `Employee` está respaldada por `iberia`, dos eslabones más arriba,
y declara `dni: high`. `dni` es `nationalId` en `empleados`, así que la copia lleva `high` — y
`materialization.payload` admite `high`. Compila, y **por la razón correcta**: no porque la etiqueta
no llegara, sino porque llegó y cabe.
