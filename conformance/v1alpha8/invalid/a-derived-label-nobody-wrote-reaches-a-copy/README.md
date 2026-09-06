# invalid / a-derived-label-nobody-wrote-reaches-a-copy

**Regla:** [`04-flow.md` §3.1](../../../spec/v1alpha1/04-flow.md) · **Debe:** `OOS4001` · **Nivel:** L0

---

La copia lleva **solo** `total`: sus origenes viven en otra entidad, sobre una vista
virtual. Sin esa separacion el caso emitiria tambien `OOS4002` por `baseSalary` y `bonus`,
y dejaria de aislar lo que quiere demostrar.

`total` no declara ninguna etiqueta —hacerlo seria `OOS4008`—, y aun asi lleva
`gdpr.sensitivity: critical`, porque es el `join` de `baseSalary` y `bonus`. Esa
etiqueta **no esta escrita en ningun fichero**: la computa el compilador.

Y por eso `OOS4001` y no `OOS4002`, siendo la misma violacion de la regla de flujo. Lo que
las separa es el remedio: con `OOS4002` el nivel esta escrito en algun sitio y se puede ir a
buscar; aqui hay que ir a los **origenes de la derivacion**, que son otras propiedades y
pueden estar en otra entidad. El mensaje tiene que decir de donde salio el nivel, porque el
autor no lo escribio y no lo reconoce.

**Es el ultimo codigo que el censo de paridad senalaba como ciego** —valia en los dos
paradigmas y solo se probaba con `Binding`—, y el motivo no era que faltara este fichero:
era que **no podia saltar**. El analisis de flujo no resolvia la cadena hacia arriba, asi
que la etiqueta computada no llegaba a la copia y lo que se veia era el suelo del
datasource, heredado. `pruebas-de-fuego/medida-la-etiqueta-computada.py`.
