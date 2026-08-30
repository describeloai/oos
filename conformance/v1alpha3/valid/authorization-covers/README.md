# v1alpha3 / valid / authorization-covers

**Regla:** [`01-gobierno.md` §6.1](../../../../spec/v1alpha3/01-gobierno.md#6.1) · **Código:** `—` · **Nivel:** L0

---

El mismo paquete que
[`wrong-nature-does-not-cover`](../../invalid/wrong-nature-does-not-cover/), con la politica
que faltaba:

```cedar
permit (principal in Role::"analyst", action == Action::"read",
        resource in Label::"gdpr.sensitivity:high");
```

Lo que se lee es **a que clasificacion apunta**, no lo que decide. `Label::"..."` es lo que
la proyeccion a esquema Cedar emite para cada nivel de cada reticulo, asi que mencionarlo
**es** apuntar a la clasificacion — buscarlo no es un atajo, es leer el vocabulario que
nosotros mismos generamos.

No se evalua ninguna condicion. Si esta politica es **la adecuada** no lo decide esto: lo
registra un dueno, y si hace falta mas, un endoso. **El compilador decide la cobertura; el
endoso registra la adecuacion.**
