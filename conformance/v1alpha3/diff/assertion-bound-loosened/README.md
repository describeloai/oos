# v1alpha3 / diff / assertion-bound-loosened

**Regla:** [`01-gobierno.md` §6.2](../../../../spec/v1alpha3/01-gobierno.md#62) · **Codigo:** `OOS5016` · **Nivel:** L0

---

`nullValues mustBeLessThan 5` pasa a `5000`. **La regla no desaparece: se vacia.**

Y por eso no lo veia nadie. La cobertura no cambia —sigue habiendo una asercion de la
naturaleza que la clasificacion exige—, asi que `OOS8001` sigue satisfecho y `OOS5023` calla.

Es literalmente el modo de fallo que `01-gobierno` §6.2 describe:

> *«una politica que permite todo cubre igual que una que no permite nada»*

## Lo que este caso corrige de esa frase

§6.2 concluye que la **adecuacion** no es decidible y que por eso se exige un dueño. Es cierto
**para una foto**: nadie puede saber si `5` es el numero correcto.

Pero **entre dos versiones si es computable**, y ahi esta el hallazgo: no hace falta saber si
la cota es la adecuada, solo que **se ha aflojado**. Eso es una comparacion, no un juicio. Lo
unico que se podia comprobar era lo que no se comprobaba.
