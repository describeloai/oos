# v1alpha3 / digest / order-of-natures-is-irrelevant

**Regla:** [`01-gobierno.md` §6.1](../../../../spec/v1alpha3/01-gobierno.md#61) · **Nivel:** L0

---

`requiresGovernance: { high: [authorization, constraint] }` y el mismo retículo con las dos
naturalezas al revés. Mismo digest.

**Antes daban dos distintos, y llevaba así desde que existe el campo.**

## Cómo se destapó

No leyendo. `CONJUNTOS` mira **la clave bajo la que cuelga una secuencia**, y aquí las listas
cuelgan del nombre de un nivel —`high`, `critical`— que es un nombre arbitrario y no puede
estar en ninguna lista fija. Así que añadir `requiresGovernance` a `CONJUNTOS` arreglaba el
concepto de v1alpha4 y **no arreglaba el retículo**.

Eso habría dejado **el mismo nombre comportándose distinto en dos documentos**: ordenado en
un `Concept`, sin ordenar en un `Lattice`. Dos semánticas para una palabra, que es
exactamente lo que esta especificación persigue en todas partes menos, resultó, en su propia
forma canónica.

De ahí sale `MAPAS_DE_CONJUNTOS`: el que sabe que sus valores son conjuntos no es la
secuencia, **es el mapa que la contiene**.

## Por qué el caso vive aquí y no en v1alpha4

Porque el documento roto es de v1alpha3. Lo encontró la versión siguiente, y eso es un dato
sobre cómo se encuentran las cosas —**construir el plano nuevo es lo que audita el viejo**—,
no sobre a quién pertenece el defecto.
