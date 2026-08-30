# v1alpha4 / valid / draft-carries-confidence

**Regla:** [`01-significado.md` §4.2.1](../../../../spec/v1alpha4/01-significado.md#421) · **Nivel:** L0

---

**Este es el fichero que produce un inductor**, y por eso el caso importa mas de lo que
parece: la prueba de fuego de esta version es que *alguien que induce tiene que poder
escribir contra este vocabulario*. Si esto no compilase, lo propuesto no llegaria nunca a
la cola de revision y `OOS9003` no estaria bloqueando nada — estaria impidiendo el paso
anterior.

Dos propuestas, dos radios distintos:

- `email: { is: gdpr.personalEmail, confidence: 0.91 }` — **mapear**. Se equivoca en un sitio.
- `gdpr.loyaltyTier` acunado con `confidence: 0.62` — **acunar**. Si se equivoca, es una
  palabra que otros van a hablar.

**El mecanismo no las distingue, y no debe**: son la misma clase de acto y llevan la misma
marca. Lo que las separa es la consecuencia, no la naturaleza — y la consecuencia la mide
quien revisa, no el compilador.
