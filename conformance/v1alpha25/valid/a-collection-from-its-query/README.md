# v1alpha25 / valid / a-collection-from-its-query

**Regla:** [`01-transform.md` §5.2](../../../../spec/v1alpha25/01-transform.md#5) · **Nivel:** L0

---

La sentencia 1 crea una colección vacía y no es un transform. La 2 —`create or replace media
collection … as select`— da una colección por su consulta: es un `Transform` con `entrypoint:
<ruta>.sql:2`, la salida es la colección (escrita, por nacer) y la entrada, la colección que lee.
