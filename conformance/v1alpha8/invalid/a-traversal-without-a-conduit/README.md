# invalid / a-traversal-without-a-conduit

**Regla:** [`04-flow.md` §4.2](../../../spec/v1alpha1/04-flow.md) · **Debe:** `OOS4011` · **Nivel:** L0

---

El mismo paquete que el caso valido, **sin politica de conductos**.

Recorrer una relacion es una busqueda por clave sobre una copia de la clave y el enlace:
se materializa aunque no lo declare nadie. Y omitir un conducto no es dejarlo abierto, es
cerrarlo (P4), asi que la copia no tiene por donde pasar.

Lo que este caso afirma es que **la ausencia se nota**. Sin el, un repositorio que
atraviesa copiaria aristas por un conducto sin autorizacion y compilaria: exactamente lo
que pasaba mientras el sujeto de la regla era `Binding` y la travesia habia dejado de
llegar por ahi.
