# Las tres caras, y una función que entra por ellas

El gemelo en verde de los tres casos inválidos de al lado, y lo que hace que la cara `W` sea una
pieza y no una prohibición.

La tabla declara las tres: qué se le puede pedir, qué cambios emite y **qué acepta**. Como acepta
`update` y `delete`, declara también `changes.key` —`OOS2024`—, que es lo que dice qué fila se
toca. La vista recorta y renombra; la entidad la nombra con `backedBy`; la función escribe
`hr.Employee.estado` **sin decir dónde cae**, porque el camino ya lo dice.

Lo que este caso afirma, y que ningún otro afirma: que quitar `datasourceRef` no dejó a `OOS7008`
sin fuente. La sigue teniendo, derivada.
