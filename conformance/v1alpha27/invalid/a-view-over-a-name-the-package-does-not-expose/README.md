# v1alpha27 / invalid / a-view-over-a-name-the-package-does-not-expose

**Regla:** [`01-la-base-foranea` 3](../../../../spec/v1alpha27/01-la-base-foranea.md#3) · **Nivel:** L0 · **Espera:** `OOS2018`

---

La base expone sólo `ventas.clientes`; una vista suya lee `ventas_vivo.ventas.pedidos`, que no expone: es un nombre que no existe.
