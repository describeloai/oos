# v1alpha2 / diff / function-loses-an-endorsement

**Regla:** [`91-versioning.md` §4.1](../../../../spec/v1alpha1/91-versioning.md#41) · **Codigo:** `OOS5011` · **Nivel:** L0

---

`crm.anonymize` tenia dos endosos y se queda con uno.

`02-function` §6 dice que **la integridad de una funcion se computa de sus endosos** — no se
declara, precisamente para que nadie pueda afirmar sobre si mismo. La consecuencia es directa:
**perder un endoso baja su etiqueta de integridad**, y con ella los destinos a los que puede
escribir legalmente.

## Por que `OOS5011`

Es *«etiqueta de una propiedad rebajada»*, de v1alpha1. El sujeto no es una propiedad, pero el
sintoma es identico: **una etiqueta bajo**. Y este registro emite un codigo por sintoma, no
por causa — la alternativa habria sido un codigo nuevo que dijera lo mismo con otras palabras.

Que la etiqueta sea **computada** y no escrita no cambia nada, y de hecho lo agrava: nadie
edito una linea que diga `integrity`, asi que no hay diff donde mirarlo. Es el `OOS4001` de
este plano.
