# invalid / derived-label-into-cache-sink

**Regla:** [`04-flow.md` §3.1](../../../spec/v1alpha1/04-flow.md) — propagación por derivación
**Código:** `OOS4001` · **Nivel:** L0

---

## Por qué este caso es el importante

`derived-label-into-cache-sink` y `pii-into-cache-sink` parecen el mismo caso y no lo son.

En el directo, `email` lleva `gdpr.sensitivity: high` **escrito en el documento**. Eso lo
detecta cualquier linter que sepa comparar dos valores.

Aquí `totalCompensation` **no tiene etiqueta declarada en ninguna parte**. La etiqueta que
provoca el error la computa el compilador:

```
baseSalary : critical  (declarada)
bonus      : critical  (declarada)
           ↓ join
totalCompensation : critical  (COMPUTADA — nadie la escribió)
           ↓ binding, mode: cache
materialization.cache : low   →  critical ⋢ low
```

**Esto es lo que ningún catálogo del mercado hace.** En cualquiera de ellos,
`totalCompensation` acabaría sin clasificar porque alguien olvidó ponerle la etiqueta — y
seis meses después nadie recordaría que ese campo es tan sensible como los dos de los que
sale.

Un caso que solo probara la comprobación directa dejaría sin respaldo la afirmación
central del proyecto.

## Qué debe ocurrir

Rechazo con `OOS4001` —no `OOS4002`, que es la violación directa— y la cadena causal
completa: origen declarado, paso de propagación, conducto alcanzado.
