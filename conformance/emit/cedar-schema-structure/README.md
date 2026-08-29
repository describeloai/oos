# emit / cedar-schema-structure

**Regla:** [`00-overview.md` §4.1](../../../spec/v1alpha1/00-overview.md) · **Afirmación:** estructura · **Formato:** esquema Cedar

---

OOS no define un lenguaje de autorización: las políticas son Cedar. Lo que sí define es el
**mapeo determinista de un paquete a un esquema Cedar**, y eso hay que certificarlo — si dos
implementaciones proyectan distinto, las mismas políticas dejan de validar.

Se afirman **propiedades estructurales, no texto**: dos implementaciones pueden formatear el
esquema de forma distinta y ser ambas correctas.

## Las dos proyecciones que hacen el trabajo

**`Property in [Label, EntityType]`** — una propiedad pertenece a la vez a su entidad y a
todas sus etiquetas. Es lo que permite escribir `resource in Label::"gdpr.sensitivity:high"`
en lugar de enumerar propiedades, y por tanto lo que hace que **una entidad nueva quede
gobernada el día que se etiqueta**, sin tocar ninguna política.

**`Employee in [Employee]`** — la autorreferencia `manager` se proyecta como jerarquía de
entidades. De ahí sale el ReBAC estilo Zanzibar sin añadir un segundo sistema de
autorización.

Nótese que los niveles de `oos.maturity` aparecen aunque el paquete no declare ese retículo:
es estándar de la especificación y siempre está activo.
