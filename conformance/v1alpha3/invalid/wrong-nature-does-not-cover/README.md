# v1alpha3 / invalid / wrong-nature-does-not-cover

**Regla:** [`01-gobierno.md` §6.1](../../../../spec/v1alpha3/01-gobierno.md#6.1) · **Código:** `OOS8001` · **Nivel:** L0

---

```yaml
requiresGovernance:
  high: [authorization]      # el reticulo pide una POLITICA
```

Y lo que hay es una asercion de calidad, legible y con `severity: error`. Antes de tipar la
cobertura **esto compilaba**: habia una regla, y la regla contaba.

> **El fallo no es que falte una regla. Es que sobra la equivocada.**

Es el error de categoria, y es el frecuente: un equipo cubre una columna con PII poniendole
una comprobacion de nulos, la compilacion pasa, y nadie ha decidido quien puede verla. Con
la cobertura sin tipar, `OOS8001` no distinguia una cosa de la otra — media el numero de
reglas, no si eran las que la clasificacion pedia.

Esto es lo decidible de la frontera entre cobertura y utilidad. Lo indecidible sigue
estandolo, y esta escrito como limite: **una politica que permite todo cubre igual que una
que no permite nada**, y eso no lo dice ningun analisis estatico. Lo responde un dueno, y si
hace falta mas, un endoso.
