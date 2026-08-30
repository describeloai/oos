# v1alpha5 / emit / ceiling-prunes-the-classified

**Regla:** [`01-emision-graphql.md` §4](../../../../spec/v1alpha5/01-emision-graphql.md#4-lo-que-la-emisión-ejecuta-antes-de-escribir) · **Nivel:** L0

---

**Este es el caso que certifica la tesis de la versión**, y el único cuya ausencia haría el
producto *falso* en vez de incompleto. Es el
[peldaño 2](../../../../spec/v1alpha5/01-emision-graphql.md#62--peldaño-2--es-honesto).

El conducto admite hasta `medium`. Tres propiedades clasificadas, una a cada lado:

| propiedad | `gdpr.sensitivity` | ¿sale? |
|---|---|---|
| `country` | `none` | **sí** |
| `email` | `medium` | **sí** — el techo es inclusivo |
| `nationalId` | `critical` | **no** |

## Por qué «exactamente»

Las dos direcciones fallan, y por motivos distintos:

- **Una de más** es una fuga de datos.
- **Una de menos** es una fuga de disponibilidad — un contrato que oculta lo que sí podía
  servirse obliga al consumidor a buscarlo por otro camino, y ese camino no está gobernado.

## Y sale ausente, no prohibida

`nationalId` no aparece con un error, ni con una directiva, ni marcada. **No existe en el
contrato.** El consumidor no puede pedirla, un agente no puede alucinarla y una pasarela no
puede olvidarse de filtrarla, porque no hay nada que filtrar.

> **La clasificación no se emite: se ejecuta al emitir.**
