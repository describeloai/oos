# v1alpha10 / valid / an-action-that-calls-a-function

**Regla:** [`02-action.md` 2](../../../../spec/v1alpha10/02-action.md#2) · **Nivel:** L0

---

`editarCliente` es la puerta de `ventas.editar`: pide `segmento`, que la funcion declara `required`, y no dice nada de efectos porque los efectos son de la funcion. Hereda su integridad y podria anadir la suya.
