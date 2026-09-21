# v1alpha12 / invalid / a-chain-that-comes-back

**Regla:** [`01-dataset.md` 7](../../../../spec/v1alpha12/01-dataset.md#7) · **Nivel:** L0

---

`hr.bucle` tiene `from: { view: hr.eco }` y `hr.eco` tiene `from: { dataset: hr.bucle }`. Bajar por `from` no toca suelo nunca. Es `OOS2019` como lo era entre vistas: la operación que baja la cadena es una, y ahora pasa por datasets mantenidos igual que por vistas.
