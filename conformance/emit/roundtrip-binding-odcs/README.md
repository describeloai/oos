# emit / roundtrip-binding-odcs

**Regla:** [`03-binding.md` §5](../../../spec/v1alpha1/03-binding.md) · **Afirmación:** `OOS → ODCS → OOS` es la identidad · **Formato:** ODCS v3.1.0

---

Un `Binding` con `physicalType`, materialización en modo `index` y —lo importante— una
**ruta física anidada**: `addressCity` se mapea a `address.city`.

## El aplanamiento tiene que ser reversible

`02-entity` §4.4 aplana las estructuras en el binding: un objeto anidado del origen se
convierte en propiedades planas. Y §9.3 promete que la emisión **reconstruye el anidamiento
original**.

Ese par de reglas solo se sostiene si el binding conserva la **ruta completa**, y este caso
es lo que lo comprueba. Una implementación que guardase solo el último segmento —`city`—
pasaría toda la validación de esquema, funcionaría en producción y **rompería la ida y
vuelta en silencio**.

Es también la corrección de una afirmación demasiado optimista: al leer ODCS se vio que
admite anidamiento (`items`, `logicalType: object`), y que aplanar sin conservar la ruta
haría falsa la fidelidad sin pérdida para cualquier entrada anidada.
