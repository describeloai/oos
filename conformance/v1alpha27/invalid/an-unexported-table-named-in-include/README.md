# v1alpha27 / invalid / an-unexported-table-named-in-include

**Regla:** [`01-la-base-foranea` 3](../../../../spec/v1alpha27/01-la-base-foranea.md#3) · **Nivel:** L0 · **Espera:** `OOS2028`

---

`include` nombra `ventas.pedidos`, que su paquete no exporta: exponerla sería cruzar a lo que no es público.
