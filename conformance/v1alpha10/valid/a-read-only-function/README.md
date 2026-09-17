# v1alpha10 / valid / a-read-only-function

**Regla:** [`01-function.md` 5](../../../../spec/v1alpha10/01-function.md#5) · **Nivel:** L0

---

`contar` trabaja una fila de `ventas.clientes`, puede leer `ventas.pedidos`, y devuelve un entero. No tiene `effects`, y no le hace falta: no hay carencia de integridad que cerrar. Lo que lee esta entero en su superficie, y por eso fluye por la regla de flujo como un conducto mas.
