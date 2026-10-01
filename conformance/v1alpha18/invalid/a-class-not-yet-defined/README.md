# v1alpha18 / invalid / a-class-not-yet-defined

**Regla:** [`01-la-funcion-de-codigo.md` §4.6](../../../../spec/v1alpha18/01-la-funcion-de-codigo.md#4.6) · **Espera:** `OOS2043` · **Nivel:** L0

---

Sin comillas ni `from __future__ import annotations`, `-> Nivel` se resuelve donde está el `def`, y `Nivel` se define después. En el runtime sería un `NameError` al importar.
