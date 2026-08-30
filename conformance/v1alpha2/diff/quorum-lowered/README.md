# v1alpha2 / diff / quorum-lowered

**Regla:** [`91-versioning.md` §5.2](../../../../spec/v1alpha1/91-versioning.md) · **Código:** `OOS5016`

---

Tres firmas pasan a dos. Nadie recibe un error, y a partir de ese commit **una firma menos
basta para mover dinero**. Es el eje `POLICY` en su forma más pura: *«relajar una política no
rompe a ningún consumidor y es, sin embargo, el cambio más peligroso que existe en este
sistema»*.

## Sin código nuevo, y la razón importa

`OOS5016` nació para *«reducir `minGroupSize` de un desclasificador `aggregate`»* y ya se
había reutilizado para el umbral de una `Resolution` y para la cota de una aserción. El
registro emite **un código por síntoma, no por causa**, y el síntoma es el mismo en los
cuatro: **un parámetro de seguridad aflojado**.

Con este caso, el texto del registro deja de nombrar solo el primero de los cuatro.

## Por qué no se ve comparando conjuntos

`endorsements` se compara como conjunto, y **el endoso no desaparece**: sigue siendo
`humanApproval`. Tres firmas y dos firmas son el mismo endoso para un conjunto, así que la
bajada es invisible ahí. Por eso el quórum se compara aparte — es un parámetro **dentro** de
un elemento que se queda, que es exactamente la clase de cambio que
[`v1alpha3/diff/assertion-removed-from-a-surviving-ruleset`](../../v1alpha3/diff/assertion-removed-from-a-surviving-ruleset)
descubrió por primera vez.
