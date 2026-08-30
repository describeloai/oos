# v1alpha4 / valid / target-by-shape

**Regla:** [`01-significado.md` §4.3](../../../../spec/v1alpha4/01-significado.md#43) · **Nivel:** L0

---

Un `Ruleset` gana el tercer criterio, y los tres no dicen lo mismo de tres maneras:

| Objetivo | Nombra un conjunto por |
|---|---|
| `atLeast` | **clasificacion** |
| `named` | **identidad** |
| `implements` | **forma** |

Aqui la regla apunta a `acme.Party` y cubre `crm.Customer.email` y `erp.Supplier.contactEmail`
sin nombrar ninguna de las dos.

**Y no alcanza a toda propiedad de esas entidades**, que es la parte facil de hacer mal.
`crm.Customer.internalNote` esta clasificada `high` y **no la cubre esta regla** — por eso
el paquete trae ademas una por predicado. Acreditar cobertura sobre lo que la interfaz no
nombra seria acreditar lo que nadie exigio: el mismo error, en el sentido inseguro, que la
cobertura por orden de reticulo que ya se corrigio una vez.
