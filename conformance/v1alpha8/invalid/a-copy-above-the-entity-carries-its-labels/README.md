# invalid / a-copy-above-the-entity-carries-its-labels

**Regla:** [`04-flow.md` §2](../../../spec/v1alpha1/04-flow.md) · **Debe:** `OOS4002` · **Nivel:** L0

---

`hr.Employee` respalda a `hr.empleados` y clasifica `nationalId` como `high`. `hr.copia`
deriva de `hr.empleados`, expone `nationalId`, y se materializa por un conducto que solo
admite `low`.

La copia esta **por encima** de la vista de la entidad, y eso no cambia nada: lo que se
copia es el mismo dato. Que la cadena vaya en un sentido o en otro es una propiedad de los
documentos, no del contenido de las filas.

**Este caso existe porque durante un tiempo compilaba.** El analisis solo resolvia la cadena
hacia abajo, asi que una entidad cuya vista quedaba por debajo de la copia se saltaba
entera y en silencio — el mismo `continue` que se usa para una entidad que de verdad no
toca esta vista. Medido en `pruebas-de-fuego/medida-el-sello-no-sube.py`.
