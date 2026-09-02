# v1alpha7 / valid / entity-backed-by-view

**Regla:** [`01-view.md` §3.1](../../../../spec/v1alpha7/01-view.md#31) · **Nivel:** L0

---

La flecha invertida, con la clave cubierta: `Employee.primaryKey = [employeeId]` y la vista expone
`employeeId`. `backedBy: empleados` va en corto, y se resuelve con N1 como cualquier referencia.

La propiedad `dni` lleva `high` y aquí no pasa nada, porque **nada se copia**: la vista es virtual y
cada lectura va al origen. La etiqueta espera a que alguien materialice.
