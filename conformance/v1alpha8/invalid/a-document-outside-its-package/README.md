# v1alpha8 / invalid / a-document-outside-its-package

**Regla:** [`01-package.md` §3.5](../../../../spec/v1alpha1/01-package.md) · **Código:** `OOS2030` · **Nivel:** L0

---

La tabla vive en `packages/…` gobernado por un manifiesto que se llama `hr`, y declara
`namespace: erp`. **La pertenencia la dice el directorio** —§3.3 no lista los documentos porque
*«eso ya lo dice el directorio»*— y la identidad la dice `metadata.namespace`, que es con lo que
`backedBy`, `from` y `exports` se refieren a todo.

Hasta aquí nada ataba las dos, y las dos mitades de la pinza se ven juntas: el documento
compilaba limpio, y ese mismo paquete declarando `exports: [hr.employees]` fallaba con
`OOS2027` porque el documento se llama otra cosa.

La consecuencia práctica era que *«mover un documento a otro paquete»* no tenía un significado
único: eran dos cosas —el fichero y el nombre— que se movían por separado sin que nada
protestara. De los cinco pasos que exige un movimiento, este era el único que no cazaba nadie.

El vocabulario compartido —retículos, reglas, políticas— no cae bajo la regla porque **no vive
dentro de un paquete**: cuelga de la raíz del *workspace*. Y un paquete que sea dueño de su
vocabulario se llama como él, y casa.
