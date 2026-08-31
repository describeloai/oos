# invalid / via-does-not-match-target-key

**Regla:** [`02-entity.md` §6](../../../spec/v1alpha1/02-entity.md) · **Código:** `OOS3006` · **Nivel:** L0

---

`ventas.Cliente` se identifica con `[id, codPais]`. La relación enlaza con **una** sola
propiedad.

Es el caso que justifica un código propio. **Todo resuelve**: `idCliente` existe,
`ventas.Cliente` existe, así que `OOS2005` no tiene nada que decir. Y no es un problema de
cardinalidad, así que tampoco es `OOS3005`. Lo que falla es que el enlace **une de menos**, y
un enlace que une de menos tiene exactamente el mismo aspecto que uno correcto: produce filas
de más, en silencio, y quien lea el esquema no verá nada raro.

Ningún esquema JSON alcanza esto: comprobarlo exige resolver `target` y leer la `primaryKey`
de **otro documento**.
