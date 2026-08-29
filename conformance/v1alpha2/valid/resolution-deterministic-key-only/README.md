# v1alpha2 / valid / resolution-deterministic-key-only

**Regla:** [`03-resolution.md` §2](../../../../spec/v1alpha2/03-resolution.md#2) · **Código:** `—` · **Nivel:** L0

---

Un `join` sobre el NIF. Lee **la clave y nada mas**.

Y por eso no aparece ningun conducto en el paquete: no hay nada que autorizar, porque no
fluye nada. Es la fila que hace que la distincion de §2 no sea de precision sino de que se
lee — la misma resolucion escrita como probabilistica exigiria un conducto autorizado a
`medium`, y esta no.

La entidad declara `attested`, el maximo del reticulo, y es legitimo: **un NIF que coincide
no es una conjetura.**
