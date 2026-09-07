# v1alpha8 / diff / a-lowered-k-threshold-publishes-small-groups

**Regla:** [`91-versioning.md` §5.1](../../../../spec/v1alpha1/91-versioning.md) ·
**Codigo:** `OOS5029` · **Nivel:** L0

---

`having: { n: ">= 8" }` pasa a `">= 2"`. Es el caso que explica por que `having` reusa los dos
codigos del recorte en vez de tener uno propio: **es la misma regla sobre otra cosa**, y las dos
direcciones duelen a los mismos.

Aqui duele la POLITICA y no el consumidor, y conviene verlo: quien leia esta vista recibe ahora
MAS filas, asi que su consulta no se rompe. Lo que se rompe es la promesa — se publican grupos de
dos, y un grupo de dos casi no es una estadistica.

`CONSUMER` sale `compatible` a proposito. Un informe que dijera «rompedor» en los cuatro ejes no
diria nada; lo util es que diga cual.
