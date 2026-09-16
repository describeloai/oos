# v1alpha9 / invalid / a-prompt-without-a-model

**Regla:** [`01-model.md` 4](../../../../spec/v1alpha9/01-model.md#4) · **Nivel:** L0

---

Un modulo wasm no lee un prompt. Aceptar la clave dejaria un campo que nadie lee, y un campo que nadie lee es peor que uno que no existe: promete algo.
