# v1alpha12 / valid / a-view-over-a-dataset

**Regla:** [`02-la-vista-y-la-entidad.md` 1](../../../../spec/v1alpha12/02-la-vista-y-la-entidad.md#1) · **Nivel:** L0

---

`hr.grandes` es la pregunta —dos países, dos campos— sobre `hr.resumen`, un dataset escrito: `from: { dataset }` es la tercera forma de `from`, y `fields` y `where` se resuelven contra **lo que el dataset expone** (sus `columns`). `hr.Resumen` se respalda en el dataset sin vista en medio: expone la `primaryKey` y un campo por propiedad, y como `changes.mode: upsert` sí puede sostener una entidad mutable. La raíz de lectura de las dos es el dataset: siempre se deja leer.
