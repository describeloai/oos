# `scope-matches-an-undeclared-attribute`

El lado derecho de un ambito es el **nombre** de un atributo del principal. Si ninguna
entidad `principal: true` lo declara, no hay contra que comparar.

Y el modo de fallo es el de siempre:

> **Un ambito que no recorta tiene exactamente el mismo aspecto que uno que recorta.**

La consulta se sirve, todo sale verde, y devuelve **todas** las filas — que es la
direccion insegura. Por eso es un error de compilacion y no un aviso.
