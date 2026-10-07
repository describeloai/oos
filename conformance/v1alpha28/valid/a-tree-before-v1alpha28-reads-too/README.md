# v1alpha28 / valid / a-tree-before-v1alpha28-reads-too

**Regla:** [`01-la-visibilidad` 2](../../../../spec/v1alpha28/01-la-visibilidad.md#2) · **Nivel:** L0 · **Espera:** `accept`

---

El mismo cruce en un árbol cuyo `OntologyConfig` es v1alpha27: compila igual. La regla sólo quita errores, así que vale para todo árbol, sin puerta de versión.

Hasta v1alpha27 este caso estaba en `invalid/a-tree-before-v1alpha28-keeps-the-export` y esperaba `OOS2028`. v1alpha28
([`01-la-visibilidad`](../../../../spec/v1alpha28/01-la-visibilidad.md) §6) quitó la frontera
entre las bases de un árbol para **todo** árbol: como la regla sólo quita errores, ningún árbol
deja de compilar, y el caso pasa a `valid/` en su propia versión.
