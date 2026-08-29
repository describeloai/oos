# canonical / n6-identifiers-case-sensitive

**Regla:** [`90-canonical-form.md` §N6](../../../spec/v1alpha1/90-canonical-form.md) · **Afirmación:** **NO** convergen

---

`employeeId` y `employeeid` son identificadores **distintos**.

Parece obvio y no lo es: PostgreSQL pliega a minúsculas los identificadores sin comillas,
Snowflake a mayúsculas, y una implementación que «ayudase» normalizando el caso para
parecerse a su origen haría converger estos dos paquetes.

Convergerían **en silencio**: sin error, sin aviso, y con dos propiedades distintas
colapsadas en una.

Es la frontera entre el plano semántico y el físico llevada al nivel del nombre. **Las
reglas de nomenclatura del origen son del origen** — viven en `column`, que es una cadena
opaca. Las de OOS son de OOS, y no se negocian con el almacén de turno.
