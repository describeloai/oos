# `row-scope-narrows-a-policy`

Cedar gobierna **propiedades**: el recurso se posiciona por pertenencia y no lleva
atributos, porque describirlo con atributos obligaria al motor a **leer el recurso para
autorizarlo**. Asi que *«compensacion de mi departamento»* no cabe en una politica.

Cabe en un **ambito**, que la politica **nombra** — la misma figura que `@oosMask`, y por
la misma razon: la definicion vive en un solo sitio, con dueno.

Lo que este caso fija es que las dos piezas encajan: el ambito resuelve, su `property`
existe, y `matches` nombra un atributo de una entidad `principal: true`.
