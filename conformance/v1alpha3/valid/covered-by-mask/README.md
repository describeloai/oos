# v1alpha3 / valid / covered-by-mask

**Regla:** [`02-ruleset.md` §6](../../../../spec/v1alpha3/02-ruleset.md#6) · **Código:** `—` · **Nivel:** L0

---

Sin ninguna asercion: el `Ruleset` solo trae una mascara.

Cuenta para la cobertura, y el motivo es el mismo criterio de §6 aplicado al otro lado: el
compilador **la lee** —sabe que desclasificador es y que nivel produce— y **puede
rechazarla** con `OOS8003`. Las dos mitades de la regla se cumplen.

Y es el caso que cierra el hueco que `99-errors` registro para v1alpha2 y v1alpha2 no toco:
*«no existe forma de desclasificar en tiempo de materializacion»*. Aqui existe, y no hizo
falta vocabulario nuevo — solo un sitio donde poner un desclasificador **sin sujeto**.
