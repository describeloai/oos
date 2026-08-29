# diff / harden-cardinality

**Regla:** [`91-versioning.md` §5.1](../../../spec/v1alpha1/91-versioning.md) · **Eje:** `CONSUMER` · **Código:** `OOS5003`

---

La relación pasa de `required: false` a `required: true`.

Endurecer parece siempre seguro y no lo es: **todo empleado sin departamento que ya existe
en el origen deja de satisfacer el modelo**. El paquete compila, y la primera consulta que
tropiece con uno de esos registros devuelve algo que nadie ha decidido qué debería ser.

Es el caso que justifica que la cardinalidad sea un campo explícito y no algo inferido de
la dirección de la relación: **lo implícito no se puede diffear.**
