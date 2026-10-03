# v1alpha23 / invalid / an-enum-is-not-erasable

**Regla:** [`01-la-funcion-de-typescript.md` §8](../../../../spec/v1alpha23/01-la-funcion-de-typescript.md#8) · **Espera:** `OOS2043` · **Nivel:** L0

---

Node 24 ejecuta TypeScript quitando los tipos. Un `enum` genera código, así que el fichero no es TypeScript del runtime, aunque la firma no lo use.
