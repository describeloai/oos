# v1alpha2 / invalid / unknown-endorser

**Regla:** [`01-efectos.md` §3.2](../../../../spec/v1alpha2/01-efectos.md#3.2) · **Código:** `OOS7004` · **Nivel:** L0

---

`teamReview` suena razonable y no es verificable: el compilador no puede comprobar sin red
ni reloj que un equipo revisara algo.

Lo que si puede comprobar es **la constancia firmada de que lo hizo**, y por eso una
revision de CODEOWNERS no es un endosante propio: colapsa en `attested`. Esa es la razon de
que el vocabulario tenga dos entradas y no cinco.

Ampliarlo es un cambio de la especificacion, igual que ampliar el de desclasificadores.
