# v1alpha4 / valid / shape-satisfied-across-vocabularies

**Regla:** [`01-significado.md` §4.3](../../../../spec/v1alpha4/01-significado.md#43) · **Nivel:** L0

---

`crm.Customer` tiene `email` y `name`. `erp.Supplier` tiene `contactEmail` y `razonSocial`.
**No comparten un solo nombre de propiedad**, y las dos implementan `acme.Party`.

Eso es todo el argumento de la version en cuatro lineas de YAML. Si la interfaz exigiera
nombres, para gobernar los dos habria que renombrar uno —y el que manda no es el modelo,
es el sistema que produce el dato, que lleva veinte anos llamandolo `razonSocial`—.
**Modelar asi obliga a limpiar antes de gobernar, que es el orden imposible.**

La forma se satisface en conceptos. El nombre se queda donde estaba.
