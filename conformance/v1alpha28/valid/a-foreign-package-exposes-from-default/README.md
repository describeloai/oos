# v1alpha28 / valid / a-foreign-package-exposes-from-default

**Regla:** [`01-la-visibilidad` 4](../../../../spec/v1alpha28/01-la-visibilidad.md#4) · **Nivel:** L0 · **Espera:** `accept`

---

La fuente `lago` cataloga un fichero suelto en el prefijo de su bucket: su `Table` no declara schema, así que está en `default`. Una base foránea lo nombra con su schema (`default.viajes`) y una vista suya lo lee por `lago_vivo.default.viajes`: el nombre resuelve a la tabla de la fuente.
