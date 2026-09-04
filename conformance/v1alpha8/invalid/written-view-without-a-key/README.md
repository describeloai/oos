# Una vista escribible cuya raíz no dice cómo se identifica una fila

La compañera de `OOS2025`, y con un remedio distinto — por eso son dos códigos y no uno: aquélla se
arregla **en la vista**, añadiendo `materialized`; ésta **en la tabla**, añadiendo `changes.key`.

Un edit dice *«la propiedad `estado` de la fila tal»*. Sin clave, «la fila tal» no nombra ninguna:
es un `UPDATE` sin `WHERE`.

La clave es `changes.key` y **no una propia de la escritura**: es la identidad de la fila, y no
depende de por qué se pregunte. La leen tres —el *tombstone* de un upsert, la fusión de un
incremento y esto— y en v1alpha8 es legal con cualquier modo por ese motivo.
