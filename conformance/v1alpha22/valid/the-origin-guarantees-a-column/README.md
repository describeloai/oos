# v1alpha22 / valid / the-origin-guarantees-a-column

**Regla:** [`01-nunca-nula.md` §2](../../../../spec/v1alpha22/01-nunca-nula.md#2) · **Espera:** `accept` · **Nivel:** L0

---

Una tabla de v1alpha22 dice qué columnas garantiza el origen (`required: true`), una lo niega en explícito (`false`) y otra no dice nada (nulable). La vista SQL que la lee no lo declara: se deriva.
