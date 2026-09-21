# v1alpha12 / invalid / a-copy-without-a-conduit

**Regla:** [`01-dataset.md` 5](../../../../spec/v1alpha12/01-dataset.md#5) · **Nivel:** L0

---

El mismo caso que `v1alpha8/invalid/materialized-view-without-conduit`, con un `Dataset` donde había una `View` con `materialized`, y **el mismo código**. Un dataset mantenido instancia el conducto porque copia datos; sin `ConduitPolicy` que lo declare, el conducto es ⊥ y no admite nada. Que el código no cambie es la afirmación de esta versión: la costura cuelga del plan, y el plan se movió con ella.
