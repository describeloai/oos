# v1alpha16 / valid / a-table-over-parquet-files

**Regla:** [`03-lo-tabular-y-la-referencia.md` §1](../../../../spec/v1alpha16/03-lo-tabular-y-la-referencia.md#1) · **Espera:** `accept` · **Nivel:** L0

---

`s3_ventas.ventas.pedidos` lee `Nueva carpeta/ventas/pedidos/**/*.parquet` y expone la partición
`fecha` como columna. `legal.pedidos` la copia con `from: { table }`: sobre una tabla con
`format` compone todo lo de siempre sin cambiar una regla.
