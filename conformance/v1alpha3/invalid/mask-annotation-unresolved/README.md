# v1alpha3 / invalid / mask-annotation-unresolved

**Regla:** [`02-ruleset.md` §4.1](../../../../spec/v1alpha3/02-ruleset.md#4.1) · **Código:** `OOS2001` · **Nivel:** L0

---

```cedar
@oosMask("eu.nif#no-existe")
permit (...);
```

La anotacion **nombra** una mascara declarada en un `Ruleset`; no la declara. Es lo que
mantiene la definicion en un solo sitio, con dueno, con version y con el descenso verificado
— dos sitios donde declarar una mascara serian dos semanticas.

Y por eso el codigo no es propio: es `OOS2001`, la misma reserva de v1alpha1 que ya activa
el `call` de un deber. **Una obligacion que nombra algo inexistente es exactamente lo que
mato a XACML**, cuyas obligaciones nombraban deberes que ningun runtime sabia ejecutar.

Lo que **no** se comprueba, y es la mitad importante de la respuesta: la clausula `when` de
la politica. Evaluarla seria reimplementar el evaluador de Cedar, que es justo lo que **P6**
existe para impedir. Se comprueba lo estructural —que la referencia resuelva, y que el ambito
de la politica se solape con el objetivo de la regla— y eso basta para el fallo que importa.
