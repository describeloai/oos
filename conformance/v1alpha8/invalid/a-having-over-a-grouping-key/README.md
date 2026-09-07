# v1alpha8 / invalid / a-having-over-a-grouping-key

**Regla:** [`02-view.md` §5.8](../../../../spec/v1alpha8/02-view.md) · **Codigo:** `OOS2034` ·
**Nivel:** L0

---

**Este caso rechaza algo que SQL acepta.** `HAVING country = 'ES'` es legal en cualquier motor y
devuelve lo mismo que el `WHERE` equivalente.

Devuelve lo mismo y **no cuesta lo mismo**. Un `where` se cumple fila a fila, asi que baja al
origen y el planificador lo empuja; un `having` se aplica encima del grupo, asi que obliga a leer
la tabla entera y agrupar para tirar casi todo despues.

Que las dos formas den el mismo resultado es justo lo que hace que el error sea silencioso: nada
falla, solo se paga. Por eso el sujeto de `having` DEBE ser un agregado, y el diagnostico dice a
donde mover el predicado.
