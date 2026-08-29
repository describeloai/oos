# digest / one-cent-differs

**Regla:** [`90-canonical-form.md` §4.1](../../../spec/v1alpha1/90-canonical-form.md) · **Afirmación:** digest **distinto**

---

`"68400.50"` frente a `"68400.51"`. Un céntimo.

Parece trivial y es la comprobación de que **G1 funciona en el límite**, no solo en el caso
cómodo. Un digest que no distinguiera este par estaría redondeando en alguna parte, y lo
haría en silencio.

## Y por qué el valor va entre comillas

Es el par positivo de
[`precision-loss-in-numeric-literal`](../../invalid/precision-loss-in-numeric-literal/), que
rechaza exactamente el mismo importe escrito **sin comillas**.

`68400.50` como número JSON se representa en coma flotante binaria, donde no tiene
representación exacta. Dos parseadores YAML podrían reconstruirlo con el último bit
distinto y producir digests distintos **para el mismo documento** — G1 caída por medio euro.

Los dos casos juntos cierran el asunto: como cadena, se compara; como número, se rechaza.
