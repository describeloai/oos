# v1alpha27 / valid / an-unexported-table-named-in-include

**Regla:** [`01-la-visibilidad` 4](../../../../spec/v1alpha28/01-la-visibilidad.md#4) · **Nivel:** L0 · **Espera:** `accept`

---

`include` nombra `ventas.pedidos`, que su paquete no exporta. Hasta v1alpha27 era `OOS2028`; desde v1alpha28 la base foránea expone lo que su `include` alcanza.

Hasta v1alpha27 este caso estaba en `invalid/an-unexported-table-named-in-include` y esperaba `OOS2028`. v1alpha28
([`01-la-visibilidad`](../../../../spec/v1alpha28/01-la-visibilidad.md) §6) quitó la frontera
entre las bases de un árbol para **todo** árbol: como la regla sólo quita errores, ningún árbol
deja de compilar, y el caso pasa a `valid/` en su propia versión.
