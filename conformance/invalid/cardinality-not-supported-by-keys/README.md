# invalid / cardinality-not-supported-by-keys

**Regla:** [`02-entity.md` §6](../../../spec/v1alpha1/02-entity.md) · **Código:** `OOS3005` · **Nivel:** L0

---

La relación declara `one_to_one` a través de `departmentId`, que no está ni en
`primaryKey` ni en `uniqueKeys`.

`one_to_one` **afirma** que ningún otro empleado apunta al mismo departamento. Nada en las
claves declaradas sostiene esa afirmación, y con `nationalId` sí la sostendría.

Importa porque la cardinalidad no es documentación: el índice de topología la usa para
decidir la estructura de las aristas, y `ore diff` la usa para detectar que endurecerla es
un cambio rompedor (`OOS5003`). Una cardinalidad que miente produce un índice incorrecto y
un diff que no protege a nadie.
