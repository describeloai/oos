# v1alpha8 / valid / a-reference-across-packages-without-an-export

**Regla:** [`01-la-visibilidad` 2](../../../../spec/v1alpha28/01-la-visibilidad.md#2) · **Nivel:** L0 · **Espera:** `accept`

---

El mismo árbol que `a-package-exports-what-others-may-use`, sin la lista. Hasta v1alpha27 era `OOS2028`; desde v1alpha28 un árbol es un catálogo y la referencia que cruza compila.

Hasta v1alpha27 este caso estaba en `invalid/a-reference-across-packages-needs-an-export` y esperaba `OOS2028`. v1alpha28
([`01-la-visibilidad`](../../../../spec/v1alpha28/01-la-visibilidad.md) §6) quitó la frontera
entre las bases de un árbol para **todo** árbol: como la regla sólo quita errores, ningún árbol
deja de compilar, y el caso pasa a `valid/` en su propia versión.
