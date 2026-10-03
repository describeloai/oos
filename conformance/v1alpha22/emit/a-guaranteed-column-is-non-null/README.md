# v1alpha22 / emit / a-guaranteed-column-is-non-null

**Regla:** [`01-nunca-nula.md` §7](../../../../spec/v1alpha22/01-nunca-nula.md#7-lo-que-se-expone) · **Nivel:** L0

---

Una tabla cuyo origen garantiza `id` y `email`, una vista que las lee tal cual, y la entidad que
respalda. El SDL de la entidad dice qué campos nunca son nulos, y lo saca **del árbol**:

| campo | columna | sale |
|---|---|---|
| `id` | garantizada, y clave | `ID!`, por ser clave |
| `email` | garantizada (`required: true`) | **`String!`** |
| `nota` | `required: false` | `String` |
| `apodo` | sin garantía, aunque la propiedad diga `required: true` | `String`: el `required` semántico no pone el `!` |

Lo de `apodo` es además el aviso de §8: la entidad pide lo que el origen no garantiza. El documento
es válido; quien lo comprueba es un `Ruleset`.
