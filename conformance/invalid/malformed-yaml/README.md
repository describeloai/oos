# invalid / malformed-yaml

**Código:** `OOS1001` · **Nivel:** L0

---

Llave sin cerrar en `metadata`. Falla en el análisis sintáctico, **antes de que exista un
documento sobre el que preguntar nada**.

Es el primer eslabón de la cadena de precedencia: no puede emitirse `OOS1003` por un `kind`
desconocido si el fichero ni siquiera se ha podido leer.
