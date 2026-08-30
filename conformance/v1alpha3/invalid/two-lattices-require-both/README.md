# v1alpha3 / invalid / two-lattices-require-both

**Regla:** [`01-gobierno.md` §6.1](../../../../spec/v1alpha3/01-gobierno.md#6.1) · **Código:** `OOS8001` · **Nivel:** L0

---

La propiedad lleva dos etiquetas y los dos reticulos exigen gobierno:

| Reticulo | Exige | ¿Lo tiene? |
|---|---|---|
| `gdpr.sensitivity: high` | `constraint` | si — la asercion |
| `acme.residency: eu_only` | `transformation` | **no** |

Y falla, porque **las exigencias se combinan por conjuncion, nunca por eleccion.**

No es una preferencia de diseno: es lo unico que no se puede atacar. Si bastara satisfacer
una, **importar un paquete laxo seria la forma de escapar de uno estricto** — y como los
paquetes de clasificacion se importan, eso convertiria el mecanismo en su contrario. Es el
mismo razonamiento por el que `join = max` no admite rebajas: una restriccion no se diluye al
juntarse con otra.
