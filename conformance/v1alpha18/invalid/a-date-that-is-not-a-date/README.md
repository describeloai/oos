# v1alpha18 / invalid / a-date-that-is-not-a-date

**Regla:** [`01-la-funcion-de-codigo.md` §4.6](../../../../spec/v1alpha18/01-la-funcion-de-codigo.md#4.6) · **Espera:** `OOS2043` · **Nivel:** L0

---

`from datetime import date` liga `date`, y `class date:` lo vuelve a ligar antes del `def`. En la firma, `date` es esa clase, que no tiene tipo en OOS.
