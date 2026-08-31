# invalid / replica-has-no-column

**Regla:** [`03-binding.md` §2.1](../../../spec/v1alpha1/03-binding.md) · **Código:** `OOS2011` · **Nivel:** L0

---

`payload.properties: [salary]` y el mapeo cubre `employeeId` y `departmentId`. **La réplica no
tiene de dónde copiar.**

`OOS2011` empezó cubriendo solo la `primaryKey`, luego las propiedades `via`, y ahora lo que
se replica. Las tres son el mismo defecto dicho tres veces: **el mapeo no cubre algo que
necesita una columna física.** Ese es el nombre correcto de la regla, y haberla escrito
estrecha es lo que dejó pasar los otros dos casos.

Salió al cerrar la caché, no leyendo: un `payload` que nombraba una propiedad inexistente en
la entidad también validaba limpio.
