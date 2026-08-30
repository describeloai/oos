# v1alpha2 / invalid / quorum-on-a-static-endorsement

**Regla:** [`01-efectos.md` §3.2.1](../../../../spec/v1alpha2/01-efectos.md) · **Código:** `OOS1004`

---

`quorum` existe por una razón muy concreta: `endorsements` es un **conjunto** cuya identidad
es `(endorser, attestation)`, así que **dos `humanApproval` sin atestación colapsan en uno**.
Un conjunto no cuenta; un número sí.

Esa razón **no aplica a `attested`**. Una atestación es un artefacto firmado, y dos
atestaciones son dos rutas distintas: ya se distinguen sin contar. Escribir `quorum: 2` allí
no expresa nada nuevo — expresa lo mismo dos veces, con una de las dos sin efecto.

## Sin código propio

Es `OOS1004`, que es forma del documento. Un **endosante** mal escrito sí tiene el suyo
—`OOS7004`— porque el vocabulario de endosantes es una decisión del régimen; que un campo
esté donde no va, no.
