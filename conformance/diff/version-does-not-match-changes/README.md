# diff / version-does-not-match-changes

**Regla:** [`91-versioning.md` §6](../../../spec/v1alpha1/91-versioning.md) · **Eje:** `PACKAGE` · **Código:** `OOS5021`

---

Se elimina `nickname` de una entidad `STABLE` y se publica como `1.4.1`. Un parche.

**Este es el caso que separa a OOS de npm y de Cargo.**

En cualquier ecosistema de paquetes, la versión es *una afirmación humana que puede ser
falsa*: alguien sube un parche, rompe a medio mundo y se entera por los issues. Nadie puede
comprobarlo porque nadie sabe qué significa un cambio en código arbitrario.

Aquí la ontología es declarativa y sus consumidores están declarados, así que **el carácter
rompedor se computa**. `ore diff` detecta `OOS5001`, deduce que exige un salto mayor,
compara con lo declarado y falla.

> La versión deja de ser una promesa y pasa a ser **un hecho comprobado**.

Es exactamente lo que Buf hace con Protobuf desde hace años, aplicado a la semántica de
negocio. Y es la razón por la que `version` se restringe a semver estricto aunque ODCS no lo
exija: sin orden no hay nada que comparar.
