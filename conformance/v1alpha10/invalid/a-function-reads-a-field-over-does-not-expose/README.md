# v1alpha10 / invalid / a-function-reads-a-field-over-does-not-expose

**Regla:** [`01-function.md` 5.3](../../../../spec/v1alpha10/01-function.md#53) · **Nivel:** L0

---

`target` es una fila de `ventas.clientes`, que expone `clienteId`, `actividad` y `segmento`. `nombre` no esta en la superficie, luego no existe para la funcion: no fluye ni arrastra, y por eso es un error y no una omision.
