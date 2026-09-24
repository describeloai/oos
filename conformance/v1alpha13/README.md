# Suite de conformidad — v1alpha13

**Borrador.** Certifica lo que añade [`spec/v1alpha13/`](../../spec/v1alpha13/): el `kind`
`Schema`, `metadata.schema` en el contenido del catálogo y el nombre de tres niveles
`<paquete>.<schema>.<nombre>`. El alcance sigue **abierto** y **no es normativo**.

---

## Por qué vive en su propio árbol

Por lo mismo que los demás borradores: un marcador significa *una implementación de referencia
pasa esto*. **Los árboles anteriores no se tocan**: la afirmación que esta versión tiene que
sostener es que no cambia un solo resultado de v1alpha1 a v1alpha12 —lo de antes está en
`default` y se llama lo mismo—.

## Qué cubre

Cinco casos que aceptan y diez que rechazan. Los `expects` se midieron contra la implementación
de referencia (ORE, 0038 P1) antes de escribirse.

| | Casos |
|---|---|
| **el nombre** | `the-same-name-in-two-schemas` · `the-same-name-twice-in-a-schema` (OOS2035) |
| **las referencias** | `one-part-is-its-own-schema` · `three-parts-cross-schemas` · `two-parts-is-default` · `default-by-its-three-parts` · `one-part-does-not-cross-schemas` (OOS2018) |
| **la carpeta se ata al nombre** | `outside-its-schema-folder` · `default-inside-a-schema-folder` · `a-schema-out-of-its-folder` (OOS2036) · `a-schema-nobody-declares` (OOS2037) |
| **el `Schema`** | `a-schema-called-default` (OOS1004) |
| **lo de otra versión o de otra clase** | `metadata-schema-in-v1alpha12` (OOS1005) · `a-schema-in-v1alpha12` (OOS1003) · `a-concept-in-a-schema` (OOS1005) |

`two-parts-is-default` y `default-by-its-three-parts` son los que importan: un documento de
v1alpha12 —que no puede decir su schema— se nombra `ventas.clientes` y `ventas.default.clientes`
indistintamente, desde un documento de v1alpha13. Es lo que demuestra que lo escrito hasta hoy
sigue nombrando lo mismo.

Lo que se comprueba con la forma y no tiene caso propio: `information_schema` como nombre
(OOS1004, el mismo camino que `default`), un `owner` que no es un handle (OOS2009), un schema
con un nombre que no es `identifier`. La forma canónica de tres partes y el `docId` los prueba la
implementación de referencia en su suite (`normalize`), porque aquí se compara el resultado de
validar y no los bytes.
