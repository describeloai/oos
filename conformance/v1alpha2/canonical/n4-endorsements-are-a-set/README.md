# v1alpha2 / canonical / n4-endorsements-are-a-set

**Regla:** [`90-canonical-form.md` §N4](../../../../spec/v1alpha1/90-canonical-form.md) · **Afirmación:** mismas formas canónicas · **Nivel:** L0

---

Los mismos dos endosos, en dos ordenes. **Convergen.**

Este caso existe porque el hueco de N4 **no era de v1alpha3**: la lista de conjuntos no habia
crecido desde v1alpha1, y v1alpha2 anadio `effects`, `endorsements`, `preconditions`,
`sources` y `weights` sin clasificar ninguno. Reordenar los endosos de una funcion daba otro
digest.

Que los cinco sean conjuntos no es una eleccion: `endosada()` los recorre con `any`, las
precondiciones se exigen todas, los efectos se comprueban todos. **Ninguno gana sobre otro**,
asi que su orden no significa nada — y lo que no significa nada no puede entrar en la
identidad del artefacto.
