# invalid / invalid-semver

**Regla:** [`01-package.md` §2.1](../../../spec/v1alpha1/01-package.md) · **Código:** `OOS2007` · **Nivel:** L0

---

`1.0` no es semver 2.0.0.

ODCS no restringe el formato de `version`. El perfil sí, y es una restricción con
consecuencia: sin semver no se puede escribir `^2.1` en una dependencia, no se puede
ordenar, y `ore diff` no puede comprobar que la versión declarada corresponde a los cambios
detectados.
