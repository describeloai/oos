# v1alpha2 / diff / function-requires-more

**Regla:** [`91-versioning.md` §4.1](../../../../spec/v1alpha1/91-versioning.md#41) · **Codigo:** `OOS5025` · **Nivel:** L0

---

La funcion gana `p2`. Quien la invocaba cumpliendo `p1` puede no cumplir `p2`, y **la llamada
que era legal deja de serlo**.

`OOS5025` nacio en v1alpha4 para *«una forma exige mas conceptos que antes»*, porque no habia
nada en v1alpha1 que significara **«un contrato existente pasa a exigir mas»**. Una
precondicion nueva es literalmente eso, asi que el codigo se reutiliza y su descripcion se
ensancha a lo que siempre significo.

Que un codigo escrito para v1alpha4 sirva sin cambios para v1alpha2 es la senal de que estaba
bien nombrado: **se nombro el sintoma y no el documento donde ocurria.**

## Y las precondiciones son del contrato, no del codigo

`02-function` §4.2 lo dice: una precondicion es parte de lo que la funcion promete, no un
detalle de su implementacion. Por eso anadir una es un cambio de contrato y no una mejora
interna — y por eso tiene que verse en el diff.
