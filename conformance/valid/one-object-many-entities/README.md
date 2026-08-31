# valid / one-object-many-entities

**Regla:** [`03-binding.md` §3.5](../../../spec/v1alpha1/03-binding.md) · **Nivel:** L0

---

Dos entidades, una tabla. Es el **diseño de tabla única** de DynamoDB, y es la forma normal
de ese almacén, no una rareza.

§2.1 ya decía que una entidad puede tener varios bindings —el caso de las **columnas**—. El
caso inverso no estaba escrito, y sin `selector` este documento validaba limpio **sin decir
qué filas eran de quién**: un ejecutor que resolviera `Pedido` habría devuelto también los
clientes.

El discriminante es una columna física y no una propiedad. Exigir que fuera una propiedad
metería un artefacto del almacén dentro de la entidad, que es lo que
[`02-entity`](../../../spec/v1alpha1/02-entity.md) §1.1 prohíbe. El selector vive en el
binding **porque** es plano físico.
