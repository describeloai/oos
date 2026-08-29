# invalid / schema-violation

**Regla:** [`00-overview.md` §3.1](../../../spec/v1alpha1/00-overview.md) · **Código:** `OOS1004` · **Nivel:** L0

---

`primaryKey: []` incumple `minItems: 1`. Una clave vacía no identifica nada.

Este caso existe para fijar **cuándo `OOS1004` es la respuesta correcta**: solo cuando
ningún código semántico describe mejor el fallo. Compárese con
[`entity-without-primary-key`](../entity-without-primary-key/), donde el esquema también
detecta el problema y sin embargo debe emitirse `OOS2010`, porque hay un código que sabe
*por qué importa* y puede sugerir `nature: event`.

Aquí no lo hay: el array está presente y vacío, y lo único que se puede decir es que la
forma es inválida. El genérico es entonces la respuesta honesta, no una rendición.
