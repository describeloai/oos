# invalid / unsupported-apiversion

**Regla:** [`00-overview.md` §6](../../../spec/v1alpha1/00-overview.md) · **Código:** `OOS1002` · **Nivel:** L0

---

`oos.dev/v1beta1` es una versión futura que este validador no implementa.

`OOS1002` es un fallo de **despacho**, no de validación: hay un esquema JSON por
`apiVersion`, así que sin resolver la versión no hay contra qué validar. Por eso ocurre
antes que `OOS1004` y no puede sustituirlo.

Y es la razón por la que `apiVersion` se declara con `const` y no con `enum` en los
esquemas: el valor no es una opción entre varias, **es el discriminante que elige el
esquema**.
