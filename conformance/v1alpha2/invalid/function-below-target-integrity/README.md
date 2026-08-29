# v1alpha2 / invalid / function-below-target-integrity

**Regla:** [`01-efectos.md` §4.1](../../../../spec/v1alpha2/01-efectos.md#4.1) · **Código:** `OOS7002` · **Nivel:** L0

---

Un binario WASM sin atestacion pretende escribir el estado de un pedido.

Su integridad no es baja por castigo: **no hay nada que la eleve**. La integridad de una
funcion se computa de sus endosos, y sin endosos es el minimo del reticulo. Un binario del
que nadie ha demostrado la procedencia no deberia poder cambiar el estado de nada.

La salida no es firmarlo todo desde el principio: es `humanApproval`. Una funcion sin
atestar puede operar igual, con un humano firmando cada vez. **Atestar el bundle convierte
la aprobacion humana de requisito en opcion.**
