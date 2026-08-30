# v1alpha3 / invalid / uncovered-classified-property

**Regla:** [`02-ruleset.md` §6](../../../../spec/v1alpha3/02-ruleset.md#6) · **Código:** `OOS8001` · **Nivel:** L0

---

El `OOS4001` de este plano, y por la misma razon: **es el error que ningun revisor
encuentra.**

`OOS4001` existe porque nadie ve una etiqueta a dos saltos. Este existe porque el defecto
**no esta escrito en ninguna parte** — no hay una linea mal puesta que senalar, hay una linea
que nadie escribio. Un `grep` no lo encuentra, y una revision de codigo tampoco, porque no
hay diff donde mirarlo.

El paquete no trae ningun `Ruleset`, que es la forma mas limpia del fallo. La forma real es
peor y es la misma: alguien clasifico una columna nueva y las reglas se quedaron donde
estaban.
