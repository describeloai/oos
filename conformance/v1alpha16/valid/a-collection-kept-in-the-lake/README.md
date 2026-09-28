# v1alpha16 / valid / a-collection-kept-in-the-lake

**Regla:** [`02-media-collection.md` §4](../../../../spec/v1alpha16/02-media-collection.md#4) · **Espera:** `accept` · **Nivel:** L0

---

`legal.archivo.contratos` sale de `s3_ventas.docs.contratos` (tres partes: otro paquete, otro
schema, exportado). La fuente es `low`; la colección declara `high` —un contrato lleva datos
personales aunque el bucket no lo diga— y eso **eleva**. Copiar instancia
`materialization.payload`, que admite `high`.
