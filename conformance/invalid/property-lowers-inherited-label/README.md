# invalid / property-lowers-inherited-label

**Regla:** [`02-entity.md` §4.1](../../../spec/v1alpha1/02-entity.md) · **Código:** `OOS4012` · **Nivel:** L0

---

La entidad declara `gdpr.sensitivity: high` para todo el conjunto. Dos propiedades la
modifican y **solo una es legítima**:

| Propiedad | Etiqueta | Veredicto |
|---|---|---|
| `nationalId` | `critical` | **eleva** — legítimo |
| `workEmail` | `low` | **rebaja** — `OOS4012` |

La asimetría es deliberada y es la misma que gobierna todo el sistema: **restringir siempre
se puede; relajar es una decisión que exige tomarse donde se declaró la restricción**, no
en una propiedad suelta.

El caso incluye la variante legítima a propósito: una suite que solo enseñara el fallo no
demostraría que la elevación pasa.
