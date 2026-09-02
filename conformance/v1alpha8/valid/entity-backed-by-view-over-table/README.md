# v1alpha8 / valid / entity-backed-by-view-over-table

**Regla:** [`02-view.md` §4](../../../../spec/v1alpha8/02-view.md#4) · **Nivel:** L0

---

Las tres capas, cada una sabiendo solo lo suyo: la entidad sabe de significado, la vista sabe de
nombres y filas, la tabla sabe del objeto. `backedBy: empleados` va en corto y se resuelve con N1.

`backedBy` sigue nombrando **una vista, nunca una tabla**. Si nombrara la tabla, `Employee`
tendria que llamar `national_id` a su propiedad, y lo semantico volveria a saber de lo fisico —
que es de lo que v1alpha7 vino a sacarnos.

`dni` lleva `high` y aqui no pasa nada, porque **nada se copia**: la vista es virtual y cada
lectura va al origen. La etiqueta espera a que alguien materialice.
