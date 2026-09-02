# v1alpha8 / valid / stream-table-materialized

**Regla:** [`02-view.md` §5.1](../../../../spec/v1alpha8/02-view.md#51) · **Nivel:** L0

---

`bus.orders` es un tema de Kafka: **se escribe, no se pregunta**. Su cara de lectura es `none` y
su cara de cambio es `upsert` con clave, que es lo que un tema compactado emite — un *tombstone*
retira la fila que lleva su clave.

No hay `kind: Stream` y no hace falta: un stream es el nombre corriente de una tabla sin cara de
lectura.

La vista lo hace consultable poniendo `materialized`, que es la unica forma de que exista un sitio
donde preguntar. Es el gemelo positivo de `invalid/stream-view-not-materialized`, y compila **por
la razon correcta**: no porque nadie mirara la cara de lectura, sino porque se miro y la copia la
suple.
