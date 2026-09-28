# v1alpha16 / invalid / a-source-that-keeps-its-objects-to-itself

**Regla:** [`02-media-collection.md` §4](../../../../spec/v1alpha16/02-media-collection.md#4) · **Código:** `OOS2028` · **Nivel:** L0

---

El `ObjectTable` vive en el paquete de la fuente y la colección en una base: la referencia cruza
de paquete, y `exports` ausente no significa «todo», significa nada (v1alpha8). Existe, y por
eso no es `OOS2018`.
