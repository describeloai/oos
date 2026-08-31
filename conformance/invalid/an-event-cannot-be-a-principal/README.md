# invalid / an-event-cannot-be-a-principal

**Regla:** [`02-entity.md` §2.2](../../../spec/v1alpha1/02-entity.md) · **Código:** `OOS1004` · **Nivel:** L0

---

Un `nature: event` que se declara principal.

`02-entity` §1 ya lo dice de la naturaleza: un `event` es *append-only* y ordenado en el
tiempo, **sin identidad estable por registro** — «no identifica un sujeto, sitúa un hecho».
Un principal es alguien, así que las dos declaraciones se contradicen.

Es una comprobación de forma y no necesita código propio: el documento se contradice consigo
mismo, y eso ya tiene un código.
