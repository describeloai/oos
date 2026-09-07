# v1alpha8 / invalid / an-aggregate-without-a-group

**Regla:** [`02-view.md` §5.8](../../../../spec/v1alpha8/02-view.md) · **Codigo:** `OOS2033` ·
**Nivel:** L0

---

**Este caso rechaza algo que SQL acepta**, y conviene decir por que. `SELECT count(*) FROM t` es
legal en cualquier motor; aqui no.

Se midio: el linaje de un agregado global sale **vacio** —no viene de ninguna columna raiz— asi
que la comprobacion de flujo no tiene nada que mirar, y el numero de filas de la tabla se
publicaria sin gobierno. Saber cuantos empleados hay en una tabla de nominas no es una pregunta
sin etiqueta.

Con `groupBy`, el mismo `count()` gana una arista **INDIRECT** por cada clave, y entonces si hay
algo que comprobar. No es una limitacion del motor: es la consecuencia de gobernar por linaje.
