# v1alpha8 / valid / append-changes-back-an-event

**Regla:** [`02-view.md` §5.2](../../../../spec/v1alpha8/02-view.md#52) · **Nivel:** L0

---

El gemelo positivo de `invalid/append-changes-back-a-mutable-entity`, y la mitad de `OOS2021`
que **no** falla.

`app.clicks` solo sabe de altas: `mode: append`, con `ocurrio_en` de marca de agua. Copiar eso da
exactamente lo que hay — un hecho ocurrido no se retira, asi que **no hace falta poder quitar**.

La regla no dice *«append no se materializa»*: dice *«append no sostiene lo mutable»*. Un evento
no es mutable, y por eso este caso compila. Que la regla distinga entre `nature: entity` y
`nature: event` es lo que la hace util en vez de molesta.
