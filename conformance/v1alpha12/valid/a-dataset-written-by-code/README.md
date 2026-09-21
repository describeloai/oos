# v1alpha12 / valid / a-dataset-written-by-code

**Regla:** [`01-dataset.md` 3.2](../../../../spec/v1alpha12/01-dataset.md#3.2) · **Nivel:** L0

---

`hr.resumen` es lo que hasta v1alpha11 era una `Table` con `datasource: lago`: lo que un transform escribe. No tiene `from` —su linaje está en el puntero, por snapshot— y sí `columns` (las de la tabla Iceberg) y `changes: { mode: upsert, key: [pais] }`, que no es la cara `D` de una tabla sino **qué escrituras admite**: una que no funda por `pais` se niega. Sin `datasource`, sin `object`, sin `reads`: es nuestro, y sus caras se saben.
