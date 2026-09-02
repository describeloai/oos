# v1alpha7 / invalid / witness-field-not-exposed

**Regla:** [`01-view.md` §6](../../../../spec/v1alpha7/01-view.md#6) · **Código:** `OOS2018` · **Nivel:** L0

---

El testigo por campo ordena el avance por un campo **de la vista**, y `updatedAt` no está en
`fields`. Un testigo que nombra lo que la vista no expone no puede leerse, así que no atestigua
nada. El esquema exige `field` cuando `witness: field`; que exista es de enlazado.
