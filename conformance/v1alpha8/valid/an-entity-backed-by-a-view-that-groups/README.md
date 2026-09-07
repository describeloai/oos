# v1alpha8 / valid / an-entity-backed-by-a-view-that-groups

**Regla:** [`02-view.md` §5.8](../../../../spec/v1alpha8/02-view.md) · **Nivel:** L0

---

`ConteoPais` sale de `por_pais`, y su propiedad `n` **no sale de ninguna columna**: sale de
`count()`. La clave de la entidad es la clave del grupo, que es la unica que la identifica — una
fila por pais.

Este caso existe porque no compilaba. `OOS2022` decia *«`hr.por_pais` no expone `n`»* sobre una
vista que si lo expone: la funcion que contesta *de que COLUMNA sale este campo* dejo de devolver
los agregados —bien, porque de un agregado la respuesta es que de ninguna— y tres sitios la usaban
para preguntar otra cosa, *que campos EXPONE esta vista*. Hasta `groupBy` las dos daban lo mismo.

Y va con su gemelo en `flow`: la etiqueta de una columna **sobrevive a sumarla**, asi que arreglar
solo esto habria abierto una fuga en vez de cerrar un hueco.
