# emit / ossie-requires-binding

**Regla:** [`02-entity.md` §9.1](../../../spec/v1alpha1/02-entity.md) · **Afirmación:** la emisión **falla** · **Formato:** Apache Ossie v1.0

---

Un paquete válido, que compila sin un solo error, y cuya emisión a Ossie **debe fallar**.

## Es la demostración de por qué Entity no perfila Ossie

Un `Dataset` de Ossie exige `source`. Cada `Field` exige `expression`. **Ninguno de los dos
está en la entidad — están en el binding.** Aquí no hay ninguno.

Una implementación que emitiera de todos modos tendría que **inventar** los valores
obligatorios: un `source` vacío, una expresión que es el nombre de la propiedad. Produciría
un documento que valida contra el esquema de Ossie y **miente sobre dónde vive el dato**.

Por eso `Entity` es gramática propia y no perfil:

> ¿Puede este documento expresarse como documento válido del anfitrión **sin inventar
> valores**? Contra Ossie, no.

Y por eso la formulación correcta es que **`Entity` + `Binding` compilan a Ossie**, no que
`Entity` sea un Ossie restringido. Este caso es lo que impide que esa distinción se
degrade a comentario.

## Contraste

[`roundtrip-binding-odcs`](../roundtrip-binding-odcs/) es el mismo paquete **con** binding, y
ahí la emisión funciona. La diferencia no es el modelo: es tener las dos mitades.
