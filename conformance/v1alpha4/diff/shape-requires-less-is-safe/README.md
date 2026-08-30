# v1alpha4 / diff / shape-requires-less-is-safe

**Regla:** [`03-interface.md` §4.2](../../../../spec/v1alpha4/03-interface.md#42) · **Nivel:** L0

---

El gemelo de `shape-requires-more`, con la flecha girada: `acme.Party` deja de exigir
`acme.taxId`. **Ningun cambio rompedor**, y ni siquiera una version mayor.

## Por que es un teorema y no una concesion

```
Party.requires encoge   ⟹   Party.requires ⊆ I.requires  para MAS formas I
                        ⟹   Party ⊒ mas formas
                        ⟹   una regla sobre Party alcanza MAS entidades
```

Y quien ya la satisfacia sigue satisfaciendola, porque satisfacer un subconjunto es gratis
cuando ya se satisfacia el conjunto.

Las dos direcciones salen de la misma inclusion de conjuntos —§4.2 de
[`03-interface`](../../../../spec/v1alpha4/03-interface.md)— y llevan a sitios opuestos. Que
este caso este en verde y su gemelo en `OOS5025` es la comprobacion de que el mecanismo
**discrimina** en vez de tratar todo cambio como sospechoso.

Un diff que marcase esto como rompedor no seria mas prudente: seria menos util, y con el
tiempo la gente deja de leer una herramienta que grita siempre.
