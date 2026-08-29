# digest / filename-irrelevant

**Regla:** [`90-canonical-form.md` §5.2](../../../spec/v1alpha1/90-canonical-form.md) · **Afirmación:** mismo digest

---

La misma entidad en `entities/Employee.yaml` y en `entities/emp_v2_final.yaml`.

## Este caso obligó a corregir la especificación

§5.2 decía originalmente que el digest del paquete se computa sobre pares
`(ruta, docDigest)`. Con esa definición, **renombrar un fichero cambiaría el artefacto** sin
cambiar un solo significado: nuevo digest, firmas invalidadas, redespliegue.

Es el mismo problema que ya resolvimos en
[`package-layout-equivalence`](../../canonical/package-layout-equivalence/), y la misma
respuesta: **el nombre del fichero es incidental**, como los comentarios y la indentación
(N7). La identidad de un documento está **dentro** de él — su `kind` y su nombre
cualificado— y no en dónde alguien decidió guardarlo.

§5.2 pasa a computarse sobre `(kind + nombre cualificado, docDigest)`. Y la propiedad que
justificaba incluir la ruta —saber qué documentos cambiaron sin releerlos— **mejora**:
saberlo por identidad es más útil que por ruta, porque sobrevive a que alguien reorganice
las carpetas.
