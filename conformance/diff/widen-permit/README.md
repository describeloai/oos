# diff / widen-permit

**Regla:** [`91-versioning.md` §5.2](../../../spec/v1alpha1/91-versioning.md) · **Eje:** `POLICY` · **Código:** `OOS5013`

---

Desaparece `resource.owner in principal.directReports`. La política sigue exigiendo el rol
y la finalidad; lo que ya no exige es **que el empleado sea tuyo**.

Cualquier manager pasa de ver la compensación de su equipo a ver la de toda la empresa. El
diff son dos líneas y no hay ningún error en ninguna parte.

Y es donde el análisis de Cedar deja de ser una comodidad: **saber que este conjunto de
políticas es estrictamente más permisivo que el anterior no se puede hacer comparando
texto.** Es una pregunta sobre el comportamiento de dos programas de autorización para toda
entrada posible, y Cedar la responde sin ejecutar consultas.

Nótese además qué es lo que se retiró: la condición que implementaba el ReBAC recorriendo la
cadena de managers. La jerarquía sigue existiendo en la ontología — simplemente ya nadie la
consulta.
