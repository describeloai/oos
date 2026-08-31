# diff / relation-changes-its-via

**Regla:** [`91-versioning.md` §5.1](../../../spec/v1alpha1/91-versioning.md) · **Código:** `OOS5027` · **Nivel:** L0

---

`Cliente` gana una segunda propiedad en su identidad y `Factura.cliente` pasa de unir por
`[idCliente]` a unir por `[idCliente, codPais]`.

**Es el cambio que un consumidor no puede ver venir.** El campo se sigue llamando `cliente`,
sigue devolviendo un `Cliente`, y el SDL emitido no cambia ni una letra — pero devuelve otras
filas. Un `idCliente` que antes casaba con un cliente ahora casa solo si además coincide el
país. Sin código propio, este cambio pasaría por menor.

Salen **dos**: `OOS5006` por la `primaryKey` de `Cliente` y `OOS5027` por el `via` de la
relación. No es redundancia — son dos documentos distintos con dos dueños posibles, y un
`via` puede cambiar sin que ninguna clave lo haga.
