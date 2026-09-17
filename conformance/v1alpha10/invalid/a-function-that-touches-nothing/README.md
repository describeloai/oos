# v1alpha10 / invalid / a-function-that-touches-nothing

**Regla:** [`01-function.md` 5.1](../../../../spec/v1alpha10/01-function.md#51) · **Nivel:** L0

---

`effects` es opcional en v1alpha10 porque leer y devolver es legitimo. Lo que no es legitimo es no declarar nada: una funcion lee, edita o infiere, y las tres cosas se declaran.
