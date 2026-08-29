# v1alpha2 / invalid / target-without-integrity

**Regla:** [`01-efectos.md` §4.1](../../../../spec/v1alpha2/01-efectos.md#4.1) · **Código:** `OOS7005` · **Nivel:** L0

---

`status` no declara integridad, y la tentacion es tratarlo como *sin requisitos*.

Es el mismo razonamiento que `OOS4011` rechaza en el otro eje: un conducto sin autorizacion
declarada no se autoriza solo. **P4 no es «asume lo peor», es «declara o falla»** — asumir
el maximo paralizaria cualquier ontologia real, y asumir el minimo concederia escritura en
silencio, que es el fallo que este regimen existe para impedir.

No se obtiene una escritura sin decir que integridad exige el destino.
