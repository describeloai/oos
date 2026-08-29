# invalid / conduit-without-clearance

**Regla:** [`04-flow.md` §4](../../../spec/v1alpha1/04-flow.md) · **Código:** `OOS4011` · **Nivel:** L0

---

Es el caso que distingue **denegación por defecto** de **violación de flujo**, y por eso
está construido para que no haya ninguna etiqueta en juego: `quantity` no tiene etiqueta y
`shipmentId` tampoco. Nada aquí es sensible.

Y aun así falla, porque el binding declara `mode: index` y la política de conductos solo
autoriza `materialization.cache`.

> **Omitir un conducto no es dejarlo abierto: es cerrarlo.**

Un sistema con el reflejo contrario —lo no declarado se permite— habría dejado pasar este
paquete en silencio, y con él la siguiente materialización que sí llevase datos sensibles.
`OOS4011` es lo que hace que P4 sea una garantía y no una recomendación.
