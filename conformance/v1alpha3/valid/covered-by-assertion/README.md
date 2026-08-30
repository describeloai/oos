# v1alpha3 / valid / covered-by-assertion

**Regla:** [`02-ruleset.md` §6](../../../../spec/v1alpha3/02-ruleset.md#6) · **Código:** `—` · **Nivel:** L0

---

`gdpr.sensitivity` declara `requiresGovernance: high`, y `taxId` esta clasificada `high`.
La cubre una asercion `library` con `severity: error`.

Es el positivo que da sentido a los dos negativos de `OOS8001`, y hay que leerlo con la
monotonia de §2.3 delante: **un objetivo con suelo `medium` tambien la cubriria**. Que el
suelo aqui sea `high` no es lo que hace valido el caso — lo que lo hace valido es que la
asercion sea legible y pueda fallar.
