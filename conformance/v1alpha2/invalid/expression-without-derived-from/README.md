# v1alpha2 / invalid / expression-without-derived-from

**Regla:** [`04-expression.md` §2](../../../../spec/v1alpha2/04-expression.md#2) · **Código:** `OOS1004` · **Nivel:** L0

---

Una `expression` sin `derivedFrom`.

`derivedFrom` es lo que propaga las etiquetas; la expresion solo dice **como**. Sin ella la
propiedad derivada no hereda nada y queda sin clasificar — y no hay ningun sintoma, porque
una propiedad sin etiqueta es indistinguible de una propiedad que legitimamente no la tiene.

Es un fallo **de forma**: el esquema lo expresa entero, asi que es `OOS1004` y no necesita
codigo propio. Un codigo semantico para algo que el esquema resuelve es peso muerto — la
leccion de `OOS7010`.

Al reves si vale: `derivedFrom` sin `expression` es exactamente v1alpha1, procedencia
declarada sin decir como se calcula, y sigue siendo valido.
