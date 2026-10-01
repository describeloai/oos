# OOS v1alpha19 — alcance

**Estado:** borrador de alcance. Gobierna los documentos que declaran su `apiVersion`, y es
**alpha**: sin garantías de compatibilidad.

| | |
|---|---|
| `00-scope` | **este documento** — qué entra, qué no, y por qué |
| [`01-la-coleccion-escrita-deriva`](01-la-coleccion-escrita-deriva.md) | una `MediaCollection` **escrita** dice lo que el código leyó para escribirla —`derivedFrom`, como el dataset escrito— y por ahí le baja la clasificación |

Esta versión **cambia un `kind`** —`MediaCollection`—: la forma escrita gana una clave,
`derivedFrom`. Y **aclara** una cosa que valía desde v1alpha16 y la tabla de v1alpha12 no decía:
el `derivedFrom` de un `Dataset` escrito puede nombrar una colección. No añade códigos: usa los
del dataset escrito (`OOS1004`, `OOS2018`, `OOS2019`) y el de las etiquetas (`OOS4012`). Los demás
`kind` no cambian.

---

## 1. La tesis

| versión | verbo | la regla |
|---|---|---|
| v1alpha12 | **escribir** | lo que el código escribe es un dataset, y lleva lo que leyó (`derivedFrom`) |
| v1alpha16 | **tener ficheros** | una colección de ficheros es un documento, mantenida desde un origen o escrita por código |
| **v1alpha19** | **derivar ficheros** | **una colección escrita lleva lo que el código leyó para escribirla, como un dataset escrito** |

v1alpha16 dejó la colección escrita sin linaje en el documento: «el linaje de cada escritura va en
su puntero». Para el dataset escrito eso no bastó en v1alpha12, y por la misma razón no basta
aquí: **la clasificación no se lee del puntero**. Un trabajo que lee los contratos —`high`— y
escribe sus páginas como imágenes deja una colección que, sin `derivedFrom`, dice no haber leído
nada y lleva sólo las etiquetas que alguien se acuerde de ponerle. Quedarse corto no produce
ningún síntoma (v1alpha1 P4): por eso el linaje que gobierna tiene que estar en el documento.

## 2. Qué entra

- **`spec.derivedFrom` en una `MediaCollection` escrita** (`01` §2): los nombres de lo que el
  código leyó —vistas, datasets y colecciones—. Lo escribe la herramienta al confirmar cada
  transacción, de la procedencia del trabajo; una persona puede corregirlo.
- **Por ahí baja la clasificación** (`01` §3): la colección escrita lleva el *join* de lo que
  derivó, y sus `metadata.labels` pueden elevarlo y no rebajarlo (`OOS4012`), como una mantenida
  respecto de su origen.
- **Una aclaración para todas las versiones desde v1alpha16** (`01` §4): el `derivedFrom` de un
  `Dataset` escrito puede nombrar una `MediaCollection` (v1alpha16 `02` §6 lo decía; la tabla de
  v1alpha12 `01` §2 sólo nombraba vistas y datasets).

## 3. Qué no entra

- **Qué transacción de cada entrada se leyó.** Va en el puntero de la escritura (su procedencia),
  como el snapshot de cada entrada de un dataset escrito: el documento dice *qué* se leyó, el
  puntero *cuándo*.
- **Cómo se escribe un ítem** (transacciones, `put`): es del contrato de ejecución de quien lo
  implemente, no de la gramática.
- **`derivedFrom` en una mantenida**: su linaje es `from` (`OOS1004`).
