# v1alpha2 / invalid / propagated-integrity-below-target

**Regla:** [`01-efectos.md` §4.2](../../../../spec/v1alpha2/01-efectos.md#4.2) · **Código:** `OOS7001` · **Nivel:** L0

---

**El error que justifica que exista un compilador**, escrito para el eje de integridad.

La funcion esta atestada, luego alcanza `attested`. Su precondicion lee `supplierScore`,
que es `untrusted` porque viene de un proveedor externo. El valor que la funcion causa no
es mas fiable que su entrada menos fiable — `meet`, no `join` — asi que la integridad
efectiva del efecto es `untrusted`, y el destino exige `reviewed`.

Nadie escribio `untrusted` en la funcion ni en `status`. Lo computo el compilador
propagando por lo que la funcion lee, y es exactamente el dual de `OOS4001`: un linter no
lo encuentra, y un revisor tampoco, porque la etiqueta esta a dos saltos.

Un promedio no limpia una entrada sucia. Elevar esto exige un endoso, que es la unica forma
declarada de decir *me hago responsable*.
