# v1alpha2 / valid / probabilistic-endorsed-reaches-top

**Regla:** [`03-resolution.md` §3](../../../../spec/v1alpha2/03-resolution.md#3) · **Código:** `—` · **Nivel:** L0

---

Identica a
[`probabilistic-claims-top-integrity`](../../invalid/probabilistic-claims-top-integrity/)
salvo por tres lineas:

```yaml
endorsements:
  - endorser: attested
    attestation: attestations/customer_identity.intoto.jsonl
```

El par existe porque un techo que no se puede levantar no es un techo, es una prohibicion, y
el caso negativo por si solo no distingue las dos cosas. Aqui la integridad no viene del
metodo —sigue siendo una conjetura— sino de que **alguien firmo haciendose responsable de la
fusion**, que es exactamente lo que un endoso significa en el otro documento.

Y es el mismo mecanismo que `02-function` §6, deliberadamente: un regimen con dos formas de
decir «que lo mire una persona» acaba con dos semanticas.
