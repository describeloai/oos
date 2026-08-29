# invalid / money-without-precision

**Regla:** [`02-entity.md` §3.2](../../../spec/v1alpha1/02-entity.md) · **Código:** `OOS3002` · **Nivel:** L0

---

`Money<EUR>` declara la divisa y no el redondeo.

Los tipos paramétricos existen porque **ni Ossie ni ODCS pueden expresar «euros con dos
decimales»**: el `datatype` de Ossie es un enum plano y el `logicalTypeOptions` de ODCS
tiene `minimum`, `maximum` y `multipleOf` pero ni `precision` ni `scale`.

Admitir `Money<EUR>` reintroduciría exactamente el problema que la extensión resuelve. La
precisión sin divisa y la divisa sin precisión son la misma clase de error: **no falla,
solo produce cifras incorrectas.**
