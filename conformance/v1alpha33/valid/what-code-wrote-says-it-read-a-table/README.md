# v1alpha33 / valid / what-code-wrote-says-it-read-a-table

**Regla:** [`03-lo-escrito-lee-una-tabla.md` §2](../../../../spec/v1alpha33/03-lo-escrito-lee-una-tabla.md#2) · **Nivel:** L0

---

`resumen` es un dataset escrito (sin `from`) y dice `derivedFrom: [hr.employees]`, una `Table`. Antes de
v1alpha33 §3 era `OOS2018`; ahora resuelve, lleva `high` (la etiqueta del `datasource` de la tabla) en
sus dos columnas, y `resumenCopia` copia por un conducto que admite `high`. Compila. El documento sigue
en v1alpha12: la regla no tiene puerta de versión.
