# v1alpha16 / invalid / a-collection-that-lowers-its-origin

**Regla:** [`02-media-collection.md` §6](../../../../spec/v1alpha16/02-media-collection.md#6) · **Código:** `OOS4012` · **Nivel:** L0

---

Las etiquetas de la colección se suman a las que hereda de su origen. Declarar un nivel por
debajo del heredado no baja nada —el join se queda en `high`— y por eso es un error: una
etiqueta que dice menos de lo que lleva acaba mintiendo. Es la regla de una propiedad que rebaja
la de su entidad.
