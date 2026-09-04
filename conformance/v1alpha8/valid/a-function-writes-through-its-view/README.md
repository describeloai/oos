# Una función escribe, y la vista sostiene la escritura

El gemelo en verde de los dos inválidos de al lado, y lo que hace que la regla sea una pieza y no
una prohibición.

La vista declara `materialized` —tiene dónde sostener la edición— y la tabla de su raíz declara
`changes.key` —hay con qué identificar la fila—. La entidad la nombra con `backedBy` y la función
escribe `hr.Employee.estado` **sin decir dónde cae**, porque el camino ya lo dice.

**Y fíjate en lo que la tabla NO dice:** nada sobre escrituras. No hace falta, y es la afirmación
entera de este caso — el puntero es de solo lectura y la escritura aterriza en la copia. Una
versión anterior de esta especificación le daba a la tabla una tercera cara para declarar qué
aceptaba; se retiró cuando se decidió que nunca se le iba a pedir nada.
