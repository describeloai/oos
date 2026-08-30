# v1alpha4 / invalid / implements-not-satisfied

**Regla:** [`01-significado.md` §6](../../../../spec/v1alpha4/01-significado.md#6) · **Codigo:** `OOS9001` · **Nivel:** L0

---

> `E implements I ⟹ ∀c ∈ I . ∃p ∈ E . is(p) = c`

`erp.Supplier` dice implementar `acme.Party` y no mapea `gdpr.personalEmail`. Tiene una
propiedad que se llama `email` — **y eso no cuenta**, porque la forma se comprueba en
conceptos y no en nombres. Que se llame igual que lo que falta es justamente el modo de
fallo que un chequeo por nombre no veria.

Y conviene decir lo que este codigo **no** alcanza, porque es la mitad interesante: si
`Supplier` no declarase `implements`, no habria error. Una columna que **es** un correo
personal y que nadie mapeo sigue siendo invisible — detectarla exigiria adivinar significado
desde un nombre, y `02-entity` decidio que un analisis solido no depende de parsear cadenas.

**El compilador convierte en error lo que alguien declaro que importaba.** Tercera vez que
la frontera cae en el mismo sitio, con `OOS8001` y `OOS4001`, y ya no es casualidad.
