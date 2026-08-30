# v1alpha3 / invalid / duty-without-function

**Regla:** [`02-ruleset.md` §5](../../../../spec/v1alpha3/02-ruleset.md#5) · **Código:** `OOS2001` · **Nivel:** L0

---

> **Un deber DEBE nombrar una `Function`.**

XACML murio de lo contrario. La critica documentada es que *«contiene funcionalidades, como
las obligaciones, que no se corresponden limpiamente con ningun sistema de control de acceso
conocido»*: nombraban deberes que ningun runtime sabia ejecutar. Una referencia a una funcion
declarada trae su integridad computada, sus precondiciones, su endoso y su destino
comprobado; un deber en prosa no trae nada.

**El codigo no es propio, y ahi esta lo interesante.** El borrador le dio `OOS8004`. Al
escribir los casos quedo claro que `OOS2001` lleva reservado desde v1alpha1 para
exactamente esto:

> *«Se reserva porque `Function`, `Resolution` y `Test` introducen tipos de referencia
> nuevos.»*

Activar una reserva es mejor que inflar una familia, asi que **`OOS8004` queda retirado antes
de implementarse** — tercera vez, tras `OOS7010` y tras la mitad de `OOS8003` que el esquema
absorbio.

El reticulo no declara `requiresGovernance`: un deber no cuenta para la cobertura, asi que si
lo declarara saltaria `OOS8001` y el caso no probaria lo que dice probar.
