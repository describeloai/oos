# v1alpha3 / diff / weaken-coverage

**Regla:** [`91-versioning.md` §4.1](../../../../spec/v1alpha1/91-versioning.md) · **Código:** `OOS5023` · **Nivel:** L0

---

El `Ruleset` del equipo de cumplimiento desaparece entre una version y la siguiente.

Hasta que este codigo existio, **eso pasaba en silencio**: `diff` no miraba el plano de
gobierno —`Ruleset` no aparecia ni una vez en su codigo— asi que retirar todas las reglas de
proteccion de datos de un paquete se clasificaba como *sin cambios*.

Y lo que se compara **no es la sintaxis de la regla, es su efecto**:

> `hr.Employee.email` tenia `constraint` y ha dejado de tenerlo.

Por eso hay un solo codigo y no cinco. Quitar el `Ruleset`, estrechar su objetivo, borrar la
asercion, rebajarla a `severity: warning`, quitar una mascara o cambiar una etiqueta de forma
que la seleccion encoja son **seis cambios distintos con un solo sintoma**. Un codigo por
sintoma, no por causa.

Solo se registra la direccion que **debilita**. Endurecer el gobierno no se marca, y no es un
olvido: endurecerlo rompe la compilacion de quien lo endurece, en su propia rama, de forma
ruidosa. Esta familia existe para cazar lo silencioso.
