# invalid / unknown-kind

**Regla:** [`00-overview.md` §4](../../../spec/v1alpha1/00-overview.md) · **Código:** `OOS1003` · **Nivel:** L0

---

`Ontology` no es ninguno de los cinco documentos de v1alpha1: `Package`, `Entity`,
`Binding`, `Lattice`, `ConduitPolicy`.

Segundo eslabón del despacho. El par `(apiVersion, kind)` elige el esquema, y por eso los
dos tienen código propio en lugar de caer en `OOS1004`: **no se puede fallar la validación
contra un esquema que no se ha podido seleccionar.**

Es también el motivo de que haya un esquema por `kind` y no un esquema unión con `oneOf`:
un `oneOf` reportaría que fallaron las cinco ramas sin decir cuál importaba.
