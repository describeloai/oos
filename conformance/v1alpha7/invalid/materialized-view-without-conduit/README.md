# v1alpha7 / invalid / materialized-view-without-conduit

**Regla:** [`01-view.md` §5.2](../../../../spec/v1alpha7/01-view.md#52) · **Código:** `OOS4011` · **Nivel:** L0

---

Omitir un conducto no es dejarlo abierto: es cerrarlo (P4). La vista copia datos y nadie dijo qué
puede fluir por la copia. Es el `OOS4011` del eje `payload` del binding, con el mismo conducto.
