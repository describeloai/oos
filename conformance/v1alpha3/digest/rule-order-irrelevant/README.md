# v1alpha3 / digest / rule-order-irrelevant

**Regla:** [`90-canonical-form.md` §N4](../../../../spec/v1alpha1/90-canonical-form.md) · **Afirmación:** mismo digest · **Nivel:** L0

---

Contrapartida a nivel de **digest** de
[`n4-assertions-are-a-set`](../../canonical/n4-assertions-are-a-set/). Aquel afirma que las
formas canonicas coinciden; este, que el artefacto desplegable es literalmente el mismo.

La diferencia importa en operacion, y aqui mas que en ningun otro sitio: **el paquete de
reglas lo escribe otro equipo**, con otra cadencia y otro repositorio. Si el orden en que el
equipo de cumplimiento teclea sus aserciones cambiara el digest, cada reordenacion cosmetica
**obligaria a redesplegar y a volver a firmar** un artefacto identico en significado — y a
que alguien revisara un diff que no dice nada.
