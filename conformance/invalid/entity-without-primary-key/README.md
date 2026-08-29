# invalid / entity-without-primary-key

**Regla:** [`02-entity.md` §2](../../../spec/v1alpha1/02-entity.md) · **Código:** `OOS2010` · **Nivel:** L0

---

Un log de auditoría no tiene identidad estable por registro. Su `nature` debería ser
`event` con un `timeKey`; declarado como `entity`, le falta la clave primaria.

## Este caso fija una regla de precedencia

`entity.schema.json` **también** detecta esto, con un `if/then` sobre `nature`. Emitir
`OOS1004` sería técnicamente cierto y prácticamente inútil:

```
OOS1004: el documento no valida contra entity.schema.json
OOS2010: hr.AuditLog declara nature 'entity' y no tiene primaryKey.
         Un log de auditoría suele ser nature 'event' con timeKey.
```

De ahí la regla general: **cuando un código específico y `OOS1004` describen el mismo
fallo, la implementación DEBE emitir el específico.** Si la tesis es que el error es el
producto, dejar que gane el genérico es rendirse en el único sitio donde se nota.
