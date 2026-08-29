# invalid / malformed-owner

**Regla:** [`01-package.md` §3.2](../../../spec/v1alpha1/01-package.md) · **Código:** `OOS2009` · **Nivel:** L0

---

`People Platform` identifica a un equipo para un humano y para nadie más.

`owner` exige la forma `team:<handle>` o `user:<handle>` porque **es lo que se alinea con
`CODEOWNERS`**, que es el mecanismo que realmente hace cumplir la revisión. Un nombre libre
no se puede resolver contra un sistema de control de versiones, y la propiedad declarada
dejaría de tener consecuencia.
