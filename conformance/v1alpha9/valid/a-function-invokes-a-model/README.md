# v1alpha9 / valid / a-function-invokes-a-model

**Regla:** [`01-model.md` 4](../../../../spec/v1alpha9/01-model.md#4) · **Nivel:** L0

---

El eco entero: la funcion invoca `modelo/v2-lite`, declara su efecto sobre `ventas.Cliente.segmento`, y la propiedad y el conducto son `untrusted` — **es lo que la salida de un modelo sin endoso es en el reticulo**, y el arbol lo dice en vez de callarlo. Con la propiedad en `inferred` esto seria `OOS7002` sobre la funcion, y ese caso ya vive en v1alpha2.
