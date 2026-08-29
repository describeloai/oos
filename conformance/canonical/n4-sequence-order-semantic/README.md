# canonical / n4-sequence-order-semantic

**Regla:** [`90-canonical-form.md` §N4](../../../spec/v1alpha1/90-canonical-form.md) · **Afirmación:** **NO** convergen

---

`primaryKey` es una **secuencia**. En una clave compuesta, `[employeeId, departmentId]` y
`[departmentId, employeeId]` no son la misma clave: el orden determina el índice, el
prefijo consultable y la representación de la instancia.

Una implementación que ordenase todas las listas «para ser determinista» haría converger
estos dos paquetes y **borraría un cambio rompedor** — `OOS5006` no se dispararía nunca.

Por eso N4 exige que cada campo de tipo lista **declare en su esquema si es conjunto o
secuencia**. No es una anotación: es lo que decide si una diferencia es ruido o significado,
y es el par exacto de [`n4-set-order-irrelevant`](../n4-set-order-irrelevant/).
