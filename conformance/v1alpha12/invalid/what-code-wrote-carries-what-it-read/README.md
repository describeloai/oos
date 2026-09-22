# v1alpha12 / invalid / what-code-wrote-carries-what-it-read

**Regla:** [`01-dataset.md` 5](../../../../spec/v1alpha12/01-dataset.md#5) · **Nivel:** L0

---

El caso que cerraba el hueco medido en ORE (0031 «Lo medido para W3.7 gobierno» §5): la etiqueta **moría en `write()`**. `Employee.dni` es `high` y baja por `iberia` (`dni: national_id`). Un transform lee `iberia` y escribe `resumen` (`pais`, `n`): ninguna columna se llama `dni`, y sin `derivedFrom` nadie sabría de dónde salió `n`. Con `derivedFrom: [hr.iberia]`, **cada** columna de `resumen` lleva el join de lo que `iberia` expone —`high`—, porque el código no declara qué columna salió de cuál y quedarse corto no produce ningún síntoma (P4). `resumenCopia` copia `resumen` por un conducto que admite `low`: `OOS4002`, con `resumenCopia.pais` y `resumenCopia.n` llevando `gdpr.sensitivity:high` heredado.

La máscara de siempre sigue valiendo: si el transform hubiera leído una vista sin `dni`, `derivedFrom` la nombraría y `resumen` no llevaría nada.
