# canonical / n2-defaults-materialized

**Regla:** [`90-canonical-form.md` §N2](../../../spec/v1alpha1/90-canonical-form.md) · **Afirmación:** convergen

---

Un binding sin `materialization` y otro con `mode: passthrough` explícito.

**La forma canónica no contiene valores implícitos.** Todo valor por defecto se escribe, y
por eso las dos variantes colapsan en los mismos bytes.

Tiene una consecuencia que vale la pena ver: en el diff canónico, **añadir
`mode: passthrough` a un binding que no lo tenía no aparece como cambio.** Y eso es lo
correcto — no cambia nada. Lo que sí aparecería es pasar a `index`, porque eso sí cambia
qué se copia.

Nótese además que `default` en JSON Schema es **pura anotación**: no rellena nada. Quien
materializa el valor por defecto es el compilador al normalizar, no el validador.
