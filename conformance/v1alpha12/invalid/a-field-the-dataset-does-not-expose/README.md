# v1alpha12 / invalid / a-field-the-dataset-does-not-expose

**Regla:** [`02-la-vista-y-la-entidad.md` 1](../../../../spec/v1alpha12/02-la-vista-y-la-entidad.md#1) · **Nivel:** L0

---

`hr.grandes` pide `salario`, y `hr.resumen` expone `pais`, `n` y `ultimo`. Con `from: { dataset }` la comprobación llega al suelo igual que con `{ table }`: lo que un dataset escrito expone son sus `columns`, y un nombre que no está ahí es `OOS2018`, el mismo código y el mismo remedio que sobre una tabla.
