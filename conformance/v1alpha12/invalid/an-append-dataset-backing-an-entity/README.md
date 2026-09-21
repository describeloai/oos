# v1alpha12 / invalid / an-append-dataset-backing-an-entity

**Regla:** [`01-dataset.md` 5](../../../../spec/v1alpha12/01-dataset.md#5) · **Nivel:** L0

---

El mismo caso que `v1alpha8/invalid/append-changes-back-a-mutable-entity`, leído sobre un dataset **escrito**: `hr.clics` admite sólo `append`, y `Perfil` es `nature: entity`, una cosa que cambia y sigue siendo la misma. Lo que se tiene copiando altas no es el estado presente, es el histórico con las filas viejas dentro. En un mantenido la regla mira `changes.mode` de la raíz; en un escrito, el suyo. Mismo código.
