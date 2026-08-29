# v1alpha2 / invalid / conditional-endorsement-does-not-close

**Regla:** [`02-function.md` §6.1](../../../../spec/v1alpha2/02-function.md#6.1) · **Código:** `OOS7002` · **Nivel:** L0

---

El caso que solo aparece al intentar hacer la regla comprobable.

```yaml
endorsements:
  - endorser: humanApproval
    when: 'target.totalAmount > 50000'
```

Se lee como una buena practica —pedir firma humana para importes altos— y **como endoso no
vale**. Si la condicion es falsa no hay aprobacion, luego no hay elevacion, luego la
carencia sigue abierta exactamente en el caso que la regla existe para cubrir: el pedido de
49.999 euros aprobado por un binario sin procedencia.

Un endoso condicional es un control de negocio adicional. Solo los incondicionales cierran
una carencia de integridad.
