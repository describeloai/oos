# invalid / derived-declares-label

**Regla:** [`02-entity.md` §5](../../../spec/v1alpha1/02-entity.md) · **Código:** `OOS4008` · **Nivel:** L0

---

Lo importante de este caso: **la etiqueta declarada es la CORRECTA.**
`join(critical, critical) = critical`, y el documento dice `critical`. Aun así debe fallar.

Si se admitiera declararla cuando coincide, el día que alguien rebajase `bonus` a `high`
la etiqueta de `totalCompensation` seguiría diciendo `critical` — o peor, alguien la
rebajaría también "para que cuadre". **Una etiqueta que un humano puede desincronizar del
código acaba mintiendo**, y firmarla criptográficamente lo empeora: parece verificada.

Es el principio P2 —lo derivable no se declara— convertido en un caso ejecutable.
