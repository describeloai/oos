# v1alpha3 / invalid / target-on-integrity-lattice

**Regla:** [`02-ruleset.md` §9](../../../../spec/v1alpha3/02-ruleset.md#9) · **Código:** `OOS8006` · **Nivel:** L0

---

El objetivo apunta a `acme.assurance`, que declara `axis: integrity`.

La seleccion en si es coherente —*«todo lo que sea `reviewed` o mas fiable»*— y por eso el
caso no es obvio. Lo que no encaja es el **gobierno**: en confidencialidad se gobierna hacia
arriba —mas sensible, mas gobierno— y en integridad se gobernaria hacia abajo —menos fiable,
mas gobierno—. El unico operador que existe, `atLeast`, corre en la direccion inutil.

Anadir `atMost` seria la salida evidente y no se hace todavia, porque hay una sospecha antes:
**el remedio natural de la baja integridad es un endoso**, y un endoso es asunto de
`Function`, no de un `Ruleset`. Resolverlo con un operador nuevo antes de contestar eso seria
inventar vocabulario para no pensar.

Hasta entonces, error explicito en vez de comportamiento sin definir.

La otra causa que este codigo tuvo en el borrador —`requiresGovernance` en un reticulo de eje
`integrity`— **es estructural**: cabe en el esquema del reticulo, y por tanto es `OOS1005`.
`OOS8006` se queda con la que cruza dos documentos, que es la que ningun esquema puede ver.
