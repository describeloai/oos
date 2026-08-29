# invalid / relation-target-not-found

**Regla:** [`02-entity.md` §6](../../../spec/v1alpha1/02-entity.md) · **Código:** `OOS2005` · **Nivel:** L0

---

`hr.Department` está bien formado como nombre cualificado y no existe.

Es el ejemplo más simple de por qué la validación de esquema es solo la mitad del trabajo:
`entity.schema.json` comprueba que `target` casa el patrón de nombre cualificado, y no
puede comprobar nada más. **Resolver un nombre exige el paquete entero**, no el documento.

Mismo código cubre las demás referencias a entidad o propiedad: `via`, `derivedFrom`,
`primaryKey`, `targetEntity` de un binding y las claves de su mapeo.
