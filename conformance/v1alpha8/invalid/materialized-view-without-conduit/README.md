# v1alpha8 / invalid / materialized-view-without-conduit

**Regla:** [`02-view.md` §6](../../../../spec/v1alpha8/02-view.md#6) · **Código:** `OOS4011` · **Nivel:** L0

---

Omitir un conducto no es dejarlo abierto: **es cerrarlo** (P4). La vista copia
datos y nadie dijo qué puede fluir por la copia.

Es el `OOS4011` del eje `payload` del binding, con el mismo conducto y con una tabla debajo. La
tabla no cambia quién autoriza: `reads` y `changes` dicen qué se puede hacer con el objeto, y el
conducto dice qué puede salir de él. Son dos preguntas distintas y siguen teniendo dos dueños
distintos.
