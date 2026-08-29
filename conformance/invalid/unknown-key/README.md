# invalid / unknown-key

**Regla:** [`00-overview.md` §5](../../../spec/v1alpha1/00-overview.md) · **Código:** `OOS1005` · **Nivel:** L0

---

`acmeOwner` es una extensión de proveedor escrita sin prefijo. Con `x-acme-owner` sería
válida y viajaría intacta en la ida y vuelta.

La estrictez es deliberada. Con `additionalProperties: true` una errata como `propertis:`
se aceptaría en silencio y el campo real quedaría sin declarar; con
`additionalProperties: false` **una errata es un error y una extensión deliberada lleva
prefijo.**

Es el mismo mecanismo por el que OOS emite sus propias extensiones a Ossie y a ODCS como
`x-oos-`: si exigimos prefijo a los demás, lo usamos nosotros.
