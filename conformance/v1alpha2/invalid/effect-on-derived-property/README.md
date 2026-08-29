# v1alpha2 / invalid / effect-on-derived-property

**Regla:** [`02-function.md` §5.3](../../../../spec/v1alpha2/02-function.md#5.3) · **Código:** `OOS7006` · **Nivel:** L0

---

`totalWithTax` se computa de `total` y `taxRate`. La funcion pretende ademas escribirlo.

Son dos origenes para el mismo valor y el compilador no puede saber cual gana: si el efecto
escribe 121 y la derivacion computa 118, el paquete afirma las dos cosas. Peor aun, la
proxima compilacion recomputaria y borraria la escritura sin decir nada.

Es el dual exacto de `OOS4008`: **lo derivado no se declara, y tampoco se escribe.**
