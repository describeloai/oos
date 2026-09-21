# v1alpha12 / valid / a-copy-with-its-plan

**Regla:** [`01-dataset.md` 3.1](../../../../spec/v1alpha12/01-dataset.md#3.1) · **Nivel:** L0

---

`hr.empleados` es lo que hasta v1alpha11 era una `View` con `materialized`: la copia de `hr.employees` sin los borrados, con tres campos renombrados, que se cumple cada 15 minutos y guarda 30 días de snapshots. Es **un documento**, del paquete, con dueño; la costura del gobierno es la de siempre —el plan instancia `materialization.payload`, y el conducto lo admite—. Ninguna vista hace falta para tenerla.
