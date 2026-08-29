# diff / rebind-indexed-property

**Regla:** [`91-versioning.md` §5.3](../../../spec/v1alpha1/91-versioning.md) · **Eje:** `INDEX` · **Código:** `OOS5019`

---

El binding apunta ahora a `tb_employee_v2`. La entidad no cambia, ninguna etiqueta cambia,
ninguna política cambia.

Es el eje `INDEX` en estado puro, y el único de los cuatro que **no bloquea el merge**:
`requiredBump` es `minor`, no `major`. Lo que sí obliga es a señalar que el índice de
topología está construido sobre el origen anterior y debe reconstruirse **antes de que el
runtime sirva nada**.

Un modelo de un solo eje habría tenido que elegir: bloquear el merge por una migración de
tabla rutinaria, o dejar que el runtime sirviera aristas de una tabla que ya no es la
fuente. Ninguna de las dos es aceptable.

Es también la razón operativa de la separación entidad/binding: **migrar de tabla es
cambiar un fichero de binding**, y el diff lo refleja exactamente así.
