# diff / change-currency

**Regla:** [`91-versioning.md` §5.1](../../../spec/v1alpha1/91-versioning.md) · **Eje:** `CONSUMER` · **Código:** `OOS5010`

---

`Money<EUR, 2>` pasa a `Money<USD, 2>`.

**Con `datatype: Decimal` en ambos lados, este diff estaría vacío.** El tipo no habría
cambiado, la forma tampoco, y ningún estándar del mercado tendría nada que decir — mientras
todas las cifras del sistema cambian de significado en silencio.

Es la justificación retrospectiva de los tipos paramétricos: no existen para ser precisos,
existen para que **este cambio sea visible**.
