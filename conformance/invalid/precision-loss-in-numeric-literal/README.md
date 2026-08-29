# invalid / precision-loss-in-numeric-literal

**Regla:** [`90-canonical-form.md` §4.1](../../../spec/v1alpha1/90-canonical-form.md) · **Código:** `OOS6003` · **Nivel:** L0

---

`68400.50` como número JSON en una propiedad `Money<EUR,2>`. Debe ser la cadena
`"68400.50"`.

No es purismo. Un número JSON se representa como coma flotante binaria de doble precisión,
y `68400.50` no tiene representación exacta en base 2. La serialización canónica de
RFC 8785 fija el algoritmo, pero **no puede recuperar los dígitos que el parseo ya perdió**.

Consecuencia directa sobre la garantía **G1**: dos implementaciones con parseadores YAML
distintos podrían producir bytes distintos para el mismo documento, y con ellos **digests
distintos**. La identidad determinista se caería por un céntimo.

Por eso el importe monetario viaja como cadena en la forma canónica, y por eso este error
pertenece a la familia de forma canónica y no a la de tipos.
