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

**Y por qué su tabla fecha por `log`.** El testigo de este caso no es lo que afirma: lo que afirma
es de `mode`. Fechaba por `ocurrio_en` —una columna— y esa pareja con `append` pasa a estar
prohibida por [`OOS2023`](../../../../spec/v1alpha8/02-view.md#54), que es otra regla y otro caso.
Se le pone `witness: log`, que es ademas lo que un topico de eventos declara de verdad, y la
afirmacion no se mueve ni una coma.
