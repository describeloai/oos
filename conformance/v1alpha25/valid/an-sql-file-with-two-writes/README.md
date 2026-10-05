# v1alpha25 / valid / an-sql-file-with-two-writes

**Regla:** [`01-transform.md` §5](../../../../spec/v1alpha25/01-transform.md#5) · **Nivel:** L0

---

La sentencia 1 lee y no escribe. La 2 y la 3 escriben, y cada una es un `Transform` con `entrypoint: <ruta>.sql:<n>`; sus entradas, en el orden en que aparecen.
