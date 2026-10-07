# v1alpha16 / valid / a-source-that-keeps-its-objects-to-itself

**Regla:** [`01-la-visibilidad` 2](../../../../spec/v1alpha28/01-la-visibilidad.md#2) · **Nivel:** L0 · **Espera:** `accept`

---

La colección sale del ObjectTable de otro paquete, que no lo exporta. Hasta v1alpha27 era `OOS2028`; desde v1alpha28 un árbol es un catálogo y compila.

Hasta v1alpha27 este caso estaba en `invalid/a-source-that-keeps-its-objects-to-itself` y esperaba `OOS2028`. v1alpha28
([`01-la-visibilidad`](../../../../spec/v1alpha28/01-la-visibilidad.md) §6) quitó la frontera
entre las bases de un árbol para **todo** árbol: como la regla sólo quita errores, ningún árbol
deja de compilar, y el caso pasa a `valid/` en su propia versión.
