# digest / one-file-or-two-is-the-same-package

**Regla:** [`90-canonical-form.md` §5.3](../../../spec/v1alpha1/90-canonical-form.md) · **Nivel:** L0

---

El mismo paquete, organizado de dos maneras:

| | `a` | `b` |
|---|---|---|
| `hr.Employee` | `entities/Employee.yaml` | `entities/hr.yaml`, primer documento |
| `hr.Department` | `entities/Department.yaml` | `entities/hr.yaml`, tras un `---` |

Mismo digest.

## Por qué este caso no existía, y por qué hacía falta

§5.2 dice desde v1alpha1 que **el nombre del fichero es incidental** y que la identidad de un
documento vive dentro de él. De ahí se sigue que partir o juntar ficheros no cambia el
artefacto — pero **la deducción no la comprobaba nadie**, y ningún caso de los 146 usaba
`---`.

Lo que había debajo era pérdida de datos silenciosa: el motor de referencia llamaba a su
analizador con `multi = false`, así que **rompía el bucle tras el primer documento**. Un
`Binding` puesto después de un `---` no existía, y `ore validate` decía *ok · sin errores*
aunque apuntara a un `datasourceRef` inexistente.

## Lo que este caso obliga

Que un fichero se lea como lo que YAML dice que es: **un flujo**. No es una concesión de
comodidad — es lo que hace cierta la frase de §5.2. Un motor que lee el primero y descarta el
resto convierte una decisión de organización en un cambio de contenido, y lo hace en silencio.

## Y lo que abre

Si el fichero es incidental y un flujo admite varios documentos, **un paquete entero cabe en
un fichero**. Sirve para transportarlo, para incrustarlo, para un ejemplo de documentación que
además sea entrada válida — y no cuesta nada, porque la identidad ya vivía dentro de cada
documento.
