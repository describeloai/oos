# invalid / a-document-identity-declared-twice

**Regla:** [`90-canonical-form.md` §5.2](../../../spec/v1alpha1/90-canonical-form.md#52--digest-de-paquete) · **Código:** `OOS2035` · **Nivel:** L0

---

`Cliente.yaml` y `Cliente-copia.yaml` declaran la misma `Entity:ventas.Cliente`. La identidad
de un documento es su `kind` y su nombre cualificado —es lo que el digest del paquete lista— y
**el fichero es incidental**: renombrarlo o moverlo no cambia el artefacto. Dos ficheros con la
misma identidad son, por tanto, dos verdades bajo el mismo nombre, y ninguna referencia sabría
cuál resolver.

Se midió que faltaba (2026-09-17): dos ficheros con la misma `Entity`, `View`, `Table`,
`Lattice`, `Concept` o `Package` compilaban limpios en la implementación de referencia, y cada
referencia resolvía la primera que encontraba según el orden de lectura del directorio. Un
verbo que escribiera por nombre reescribiría una y dejaría la otra.

Lo que este caso **no** afirma: que el mismo nombre en dos kinds choque. `View:hr.empleados` y
`Table:hr.empleados` son identidades distintas, y `from.view` y `from.table` ya dicen cuál se
nombra.
