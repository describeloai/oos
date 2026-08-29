# diff / remove-forbid

**Regla:** [`91-versioning.md` §5.2](../../../spec/v1alpha1/91-versioning.md) · **Eje:** `POLICY` · **Código:** `OOS5014`

---

Desaparece el `forbid` que impedía a los agentes leer compensación. El `permit` no cambia.

## Este caso es la justificación de haber elegido Cedar

Decidir que un conjunto de políticas es **estrictamente más permisivo** que otro no es
comparar texto: es una pregunta sobre el comportamiento de dos programas de autorización
para toda entrada posible.

Rego no puede responderla — su generalidad tipo Datalog la hace indecidible en el caso
general. **Cedar sí**, porque tiene análisis estático del conjunto de políticas sin ejecutar
consultas, y ese fue el criterio decisivo de la elección.

Sin esa capacidad, `OOS5014` sería una heurística sobre diffs de texto. Con ella, es una
demostración.

Y nótese el detalle de Cedar que lo hace grave: **un `forbid` gana siempre sobre cualquier
`permit`**. Mientras existía, ninguna política futura podía aflojarlo por descuido.
Retirarlo abre de golpe todo lo que cubría.
