# invalid / two-bindings-claim-the-same-row

**Regla:** [`03-binding.md` §3.5](../../../spec/v1alpha1/03-binding.md) · **Código:** `OOS2014` · **Nivel:** L0

---

`app.Pedido` toma `tipo: PEDIDO`; `app.Cliente` toma `tipo: [PEDIDO, CLIENTE]`. **La fila
`PEDIDO` cae en los dos**, y un ejecutor devolvería pedidos como si fueran clientes.

Esto es lo que compra la gramática cerrada de §3.5.1. Cada clave restringe una columna a un
conjunto finito, así que la disyunción se **decide**: dos selectores reparten si alguna
columna común tiene conjuntos que no se cortan. Con un `where` opaco no se podría ni
plantear, y este documento pasaría.

Y el caso trivial no es un caso aparte: un binding **sin** selector reclama todas las filas,
así que se solapa con cualquiera por construcción. «Falta el selector» **es** el solape
total, y darle un código propio sugeriría que son dos problemas distintos.
