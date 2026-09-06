# invalid / a-traversal-carries-a-label-the-conduit-refuses

**Regla:** [`04-flow.md` §4.2](../../../spec/v1alpha1/04-flow.md) · **Debe:** `OOS4002` · **Nivel:** L0

---

Aqui `employeeId` —**la clave**— lleva `gdpr.sensitivity: high`, y
`materialization.topology` solo admite `low`.

Es el reverso exacto del caso valido, y por eso van juntos: alli la etiqueta estaba en
`nationalId`, que **no** viaja, y compilaba; aqui esta en la clave, que **si** viaja, y no.
El sello no mira la entidad: mira las dos columnas que se copian.
