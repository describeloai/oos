# v1alpha2 / invalid / lattice-join-contradicts-axis

**Regla:** [`01-efectos.md` §3.1](../../../../spec/v1alpha2/01-efectos.md#3.1) · **Código:** `OOS7007` · **Nivel:** L0

---

`axis: integrity` implica combinar por `meet` —minimo—, y el documento declara `join: max`.

El campo es un resto de v1alpha1, donde no habia ejes y todo reticulo combinaba por
maximo. Ahora el combinador **se deriva del eje**, luego es un campo derivable, luego **P2**
dice que no es declarable.

Se admite por compatibilidad y se exige que coincida. Aceptarlo en silencio dejaria un
documento que dice una cosa y un compilador que hace otra — y en un reticulo de integridad
eso es la diferencia entre propagar confianza y lavarla.
