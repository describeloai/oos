# v1alpha4 / valid / mapping-may-raise

**Regla:** [`01-significado.md` §4.2](../../../../spec/v1alpha4/01-significado.md#42) · **Nivel:** L0

---

`gdpr.personalEmail` dice `high`. Aqui es el correo de un menor, y la entidad lo sube a
`critical`.

**Este caso existe porque la primera redaccion de §4.2 lo hacia imposible sin darse cuenta.**
Prohibia declarar `type` y `labels` junto a `is`, y dos parrafos despues permitia elevar la
clasificacion heredada — que solo se puede hacer **escribiendola**. Las dos frases no podian
ser ciertas a la vez, y la contradiccion aparecio al escribir esta suite.

La asimetria que la resuelve no es un parche:

| | Que es | Que pasa al redeclararlo |
|---|---|---|
| `type` | una **igualdad** | coincide o contradice, y **no hay nada a lo que apelar** |
| `labels` | un **orden** | significa *elevar*, y su error —*rebajar*— ya tiene codigo |

Por eso `OOS4012` «sube un nivel sin cambiar una letra»: porque aqui no hizo falta ninguna.
