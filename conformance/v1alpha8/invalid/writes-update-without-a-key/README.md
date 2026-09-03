# `writes` que actualiza, sin clave con la que identificar la fila

`insert` no necesita clave: no señala a nada que ya esté. `update` y `delete` sí, y sin ella
*«actualiza esta fila»* no nombra ninguna.

La clave es `changes.key` y **no una propia de `writes`**: un segundo sitio diciendo lo mismo es
exactamente el defecto que `kind: Table` vino a corregir, y es además la misma clave que hace
fundible un incremento.

Se rechaza con `OOS2024`, y la salida son las dos: declarar la clave, o dejar en `writes` solo
`insert`.
