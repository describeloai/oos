# invalid / circular-dependency

**Regla:** [`01-package.md` §3.1](../../../spec/v1alpha1/01-package.md) · **Código:** `OOS2002` · **Nivel:** L0

---

`acme/alpha` depende de `acme/beta`, que depende de `acme/alpha`.

Importar es **transferir autoridad**, y un ciclo significa que dos paquetes se delegan la
decisión el uno al otro sin que nadie la tome. No es solo un problema de resolución: es una
cadena de autoridad sin origen.
