# v1alpha2 / invalid / probabilistic-claims-top-integrity

**Regla:** [`03-resolution.md` §3](../../../../spec/v1alpha2/03-resolution.md#3) · **Código:** `OOS7011` · **Nivel:** L0

---

`threshold: "0.92"` y la entidad declara `attested`, la cima del reticulo.

**Una coincidencia probable no produce un hecho.** Por bien calibrada que este, una
estrategia probabilistica infiere: produce una conclusion, no una observacion. Y el techo es
«no el maximo» en vez de un nivel con nombre a proposito — obligar a cada reticulo a declarar
cual de sus niveles significa «inferido» seria vocabulario nuevo para decir algo que la
posicion ya dice. **Sea lo que sea la cima de tu reticulo, una conjetura no es eso.**

La consecuencia esta aguas abajo y es la que importa: una `Function` que escriba sobre esta
entidad hereda el techo. Aprobar un pedido a un proveedor que *probablemente* es el que crees
no es una operacion con una integridad distinta de esa probabilidad.

La salida es un endoso incondicional: alguien mira los dos registros y se hace responsable
de la fusion.
