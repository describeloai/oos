# v1alpha8 / invalid / an-aggregate-over-an-aggregate

**Regla:** [`02-view.md` §5.8](../../../../spec/v1alpha8/02-view.md#58--la-agrupación--oos2032-y-oos2033) · **Código:** `OOS2018` · **Nivel:** L0

---

`total` suma `n`, y `n` es el `count()` de `por_pais`. Un agregado se baja a **la columna de la
que sale** —es lo que le da linaje, tipo y mantenimiento incremental— y de un agregado no sale
ninguna columna: `sum(n)` no tiene qué leer en la raíz.

No es una limitación provisional. Sumar cuentas es volver a contar, y contar filas ya tiene su
forma: `count()` en la vista que agrupa por lo que haga falta. Lo que este caso cierra es que la
implementación lo diga, en vez de bajar un agregado sin columna y mantener mal en silencio.
