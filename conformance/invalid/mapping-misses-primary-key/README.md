# invalid / mapping-misses-primary-key

**Regla:** [`03-binding.md` §2.1](../../../spec/v1alpha1/03-binding.md) · **Código:** `OOS2011` · **Nivel:** L0

---

El binding mapea `email` y no `employeeId`.

Es una comprobación cruzada pura: la clave está declarada en la **entidad** y el mapeo vive
en el **binding**. Ninguno de los dos documentos, por separado, contiene el error.

Y las consecuencias de dejarlo pasar son tres, no una: sin clave no se puede construir el
índice de topología, no se puede identificar un recurso en una política Cedar, y no se
puede responder a una solicitud de acceso de un interesado. **Un binding sin clave produce
filas, no instancias.**

Una entidad puede tener varios bindings cubriendo subconjuntos distintos de propiedades —
`lifetimeValue` desde Snowflake y `supportTier` desde Salesforce— pero **cada uno debe
traer la clave**: es lo único que permite volver a unirlos.
