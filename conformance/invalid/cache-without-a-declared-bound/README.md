# invalid / cache-without-a-declared-bound

**Regla:** [`03-binding.md` §3.1.5](../../../spec/v1alpha1/03-binding.md) · **Código:** `OOS1004` · **Nivel:** L0

---

El binding declara `payload` con sus propiedades y **no dice cuánto tolera que envejezcan**.

La asimetría con `topology` es la de siempre: la topología es derivable, y una caché **pone
valores gobernados en reposo en un segundo sitio**. Una copia sin cota declarada es una copia
que nadie va a notar ponerse mala.

Y tiene una consecuencia de cumplimiento que no es teórica: **un borrado en el origen tarda
hasta `freshnessSLA` en propagarse**, así que ese número es exactamente lo que acota la
respuesta a una solicitud de supresión. Sin él no hay nada que responder.

El esquema lo exigía desde que `03-binding` §3.1 pasó a dos ejes, y **nada lo comprobaba**:
ORE no lleva un validador de JSON Schema (`ore/docs/decisions/0002`), así que las
restricciones que solo viven en el esquema no existen hasta que alguien escribe la regla de
forma. Un `payload: {}` validaba limpio — justo la regla que justifica que el campo exista.
