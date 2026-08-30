# v1alpha3 / diff / relax-requirement

**Regla:** [`91-versioning.md` §4.1](../../../../spec/v1alpha1/91-versioning.md) · **Código:** `OOS5024` · **Nivel:** L0

---

El reticulo exigia `constraint` **y** `authorization` desde `high`. Ahora solo exige lo
primero.

Nada mas cambia: la entidad es la misma, la politica sigue ahi, el `Ruleset` sigue ahi. Lo
que cambia es **lo que la clasificacion pide**, y por eso es el caso que mas se parece a un
ataque real:

> Una linea en un reticulo importado **desgobierna un paquete entero sin tocarlo.**

Es la razon de que `requiresGovernance` viva en el reticulo y no en la regla —importar la
clasificacion importa su exigencia— y tambien la razon de que retirarla tenga que verse. Con
`OOS5023` no bastaba: alli se compara lo que las propiedades TIENEN, y aqui no han perdido
nada. Lo que ha bajado es el liston.

Y la simetria con el resto de la familia es exacta: `OOS5012` marca elevar la autorizacion de
un conducto y `OOS5011` marca rebajar una etiqueta. Las dos direcciones se registran cuando
las dos rompen a alguien; aqui solo rompe una.
