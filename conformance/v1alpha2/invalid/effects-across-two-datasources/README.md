# v1alpha2 / invalid / effects-across-two-datasources

**Regla:** [`02-function.md` §5.2](../../../../spec/v1alpha2/02-function.md#5.2) · **Código:** `OOS7008` · **Nivel:** L0

---

La funcion escribe el estado en PostgreSQL y la marca de auditoria en el almacen.

Se lee como algo perfectamente razonable, y es exactamente lo que no se puede prometer:
**no hay transaccion que abarque las dos**. Una implementacion que lo aceptara fallaria a
medias en produccion —estado aprobado, auditoria ausente— y el paquete habria compilado.

Un regimen que promete lo que no cumple no gobierna nada. La regla convierte esa honestidad
en algo que falla al compilar, y sustituye `transaction.scope` como campo declarado: **mejor
un error que un campo**.
