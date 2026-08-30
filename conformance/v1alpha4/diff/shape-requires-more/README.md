# v1alpha4 / diff / shape-requires-more

**Regla:** [`03-interface.md` §4.2](../../../../spec/v1alpha4/03-interface.md#42) · **Codigo:** `OOS5025` · **Nivel:** L0

---

`acme.Party` exigia `{personalEmail, legalName}`. Ahora exige tambien `acme.taxId`.

Toda entidad que declaraba `implements: [acme.Party]` **deja de satisfacerla**, y no en forma
de aviso: `OOS9001`, y no compila. Es el unico cambio de esta fase que rompe hacia abajo de la
manera mas dura que existe en este proyecto.

## El unico codigo nuevo de la fase, y por que hacia falta

No hay nada en v1alpha1 que signifique *«un contrato existente pasa a exigir mas»*.
`OOS5003` endurece una **cardinalidad**, que es otra cosa; `OOS5001` retira algo. Aqui no se
retira nada: se anade una condicion a una definicion que otros ya habian firmado.

## Y su gemelo NO esta aqui, que es la mitad del contenido

Encoger `requires` **no rompe**, y no es una concesion: es un teorema. Si `Party.requires`
encoge, entonces `Party.requires ⊆ I.requires` se cumple para **mas** formas `I`, luego una
regla que apunte a `Party` alcanza **mas** entidades. Agrandar lo gobernado es la direccion
segura, la misma que hace que `atLeast` sea monotono.

La asimetria esta certificada aparte, en `shape-requires-less-is-safe`. Un mecanismo que
tratara los dos casos igual seria mas simple y estaria mal.
