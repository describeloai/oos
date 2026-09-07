# v1alpha8 / valid / a-view-that-sets-its-own-k-threshold

**Regla:** [`02-view.md` §5.8](../../../../spec/v1alpha8/02-view.md) · **Nivel:** L0

---

`having: { n: ">= 8" }` es, palabra por palabra, el `minGroupSize` que `OOS4007` exige al
desclasificador `aggregate` desde v1alpha3 — *«agregar quita la etiqueta si el grupo es bastante
grande»*—. Hasta v1alpha8 ese umbral solo podia vivir en una politica y comprobarse en ejecucion;
aqui entra en el PLAN, que es la diferencia entre una promesa y una consulta.

Sin el, `groupBy` con un `count()` puede devolver grupos de uno, y un grupo de uno no es una
estadistica: es una reidentificacion.

El comparador va delante a proposito. Sin el, `n: 8` seria una igualdad, y el umbral `>= 8` se
escribiria igual que su caso degenerado.
