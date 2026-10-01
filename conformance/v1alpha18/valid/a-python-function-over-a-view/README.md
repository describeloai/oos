# v1alpha18 / valid / a-python-function-over-a-view

**Regla:** [`01-la-funcion-de-codigo.md` §4](../../../../spec/v1alpha18/01-la-funcion-de-codigo.md#4) · **Nivel:** L0

---

`riesgo` trabaja una fila de `ventas.clientes` y puede leer `ventas.pedidos`. Su cabecera es `(cliente, umbral, moneda="EUR")`: la fila primero, con el nombre que quiera; `umbral`, obligatorio y sin valor por defecto; `moneda`, sin `required` —opcional, §4.3— y con uno.
