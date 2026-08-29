# invalid / unit-mismatch-in-derivation

**Regla:** [`02-entity.md` §5](../../../spec/v1alpha1/02-entity.md) · **Código:** `OOS3004` · **Nivel:** L0

---

`totalCompensation` suma un `Money<EUR,2>` y un `Money<USD,2>`.

Es el caso que justifica por qué los tipos paramétricos son **parte del sistema de tipos** y
no una anotación documental. La comprobación exige comparar los tipos de **tres
propiedades entre sí**, así que ningún JSON Schema la alcanza y ningún estándar del mercado
la tiene: con `datatype: Decimal` en ambos lados, esto suma sin protestar.

Y obsérvese que **el compilador no ejecuta la expresión** — sigue siendo documental. Lo que
comprueba es `derivedFrom`, que es normativo: las unidades de los orígenes declarados deben
ser compatibles con la del resultado. Es la misma información que usa para propagar
etiquetas, aplicada a otra dimensión.
