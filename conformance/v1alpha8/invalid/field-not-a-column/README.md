# v1alpha8 / invalid / field-not-a-column

**Regla:** [`02-view.md` §4](../../../../spec/v1alpha8/02-view.md#4) · **Código:** `OOS2018` · **Nivel:** L0

---

**La comprobacion que la tabla hace posible.** `empleados` pide `nif`, y `erp.employees` tiene
`national_id`.

En v1alpha7 esto compilaba. No por indulgencia: porque **ningun documento decia que columnas
tenia la tabla**, asi que no habia contra que comprobar. Se verificaba el eslabon vista→vista y
el ultimo tramo —el que toca el mundo— se creia.

Con `columns`, `OOS2018` llega hasta el suelo. Este es el caso que mide ese peldano.
