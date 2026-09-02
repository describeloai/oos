# v1alpha8 / invalid / stream-view-not-materialized

**Regla:** [`02-view.md` §5.1](../../../../spec/v1alpha8/02-view.md#51) · **Código:** `OOS2020` · **Nivel:** L0

---

**Uno de los dos que valen dinero.**

`bus.orders` declara `reads: none`: no responde consultas, solo emite cambios. `pedidos` es
virtual, asi que promete un sitio donde preguntar que **no existe**.

Databricks lo descubre cuando `readStream` no existe sobre una *foreign table* — en tiempo de
ejecucion, con el plan ya escrito. Aqui no compila.

La regla es la de la version leida al reves: `Table = I(changes)`, y **sin `I` no hay lectura**.
El arreglo cabe en dos lineas: `materialized`, que es la unica forma de que haya donde
preguntar.
