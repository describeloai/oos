# OOS v1alpha27 — alcance

**Estado:** borrador de alcance. Gobierna los documentos que declaran su `apiVersion`, y es
**alpha**: sin garantías de compatibilidad.

| | |
|---|---|
| `00-scope` | **este documento** — qué entra, qué no, y por qué |
| [`01-la-base-foranea`](01-la-base-foranea.md) | **la base foránea**: un `Package` que expone, con su nombre, las `Table` y los `ObjectTable` de una fuente que se lee en vivo; no tiene objetos propios ni copia |

Esta versión **no añade un `kind`**. Añade **una clave** a dos documentos —`spec.foreign` en el
`Package` y `federation` en cada `datasources[]` del `OntologyConfig`— y **tres códigos**:
`OOS2049`, `OOS2050` y `OOS2051`. Lo demás que puede fallar ya tiene código: una fuente que no
está declarada es `OOS2004`, un nombre que la base no expone es `OOS2018`, una tabla que su
paquete no exporta es `OOS2028`, y leer sin `federation.read` es `OOS4011`.

---

## 1. La tesis

| versión | la base *foreign* |
|---|---|
| v1alpha10 | un hecho del catálogo: «un espejo, cada lectura va al origen»; **sin gramática** (§5: «un kind de database» no entra) |
| v1alpha14 | una vista sobre una `Table` es «la vista de una base *foreign*», que se lee donde está |
| v1alpha24 | leerla en vivo tiene permiso (`federation.read`) y cuidado (`fullScan`, `requiredFilters`) |
| **v1alpha27** | **una declaración del `Package`**: qué fuente expone y qué parte; sus nombres resuelven a los objetos de la fuente |

v1alpha10 dejó la clase fuera de la gramática porque entonces sólo decidía **si las vistas
tenían copia**, y eso ya se leía en el árbol (`materialized` en todas o en ninguna). Hoy decide
algo que el compilador **tiene que saber**: **cómo se resuelve un nombre**. Lo pidió la
plataforma que implementa OOS (ORE 0057, «bases foráneas», 2026-10-06), con lo medido en sus dos
celdas:

- **Las 31 vistas de sus siete bases foráneas eran la identidad** de una `Table` de la fuente —
  `SELECT` de todas sus columnas, sin un filtro—, escritas por quien induce y regeneradas cada vez
  que el origen cambia. Ninguna la escribió una persona. Repetían las columnas y **escondían** el
  coste que la tabla declara: una vista de v1alpha14 sobre una `Table` no pide `federation.read`
  al compilar.
- **La clase vivía fuera de la gramática**, así que no se podía comprobar nada de ella: una base
  foránea con copias, una sobre una fuente que no se deja leer en vivo, el paquete de la fuente
  confundido con una base.

La industria lo resuelve igual: el *foreign catalog* de Unity (Lakehouse Federation), el
catálogo de Trino y la *external schema* de Redshift **nombran** las tablas del origen; no
escriben una vista por tabla.

## 2. Qué entra

- **`spec.foreign`** en el `Package` (`01` §2): la fuente (`datasource`) y qué parte expone
  (`include`): schemas enteros —un **espejo**: lo que la fuente tenga después en ellos aparece
  solo— o objetos uno a uno.
- **La resolución** (`01` §3): `<base>.<schema>.<objeto>` **es** la `Table` o el `ObjectTable` de la
  fuente. **El mismo documento con dos nombres**, no una copia: columnas, tipos, `reads` y
  `changes` son los suyos.
- **Lo que una base foránea contiene** (`01` §4): `Schema` y vistas **sin copia**. Nada más
  (`OOS2049`). Copiar es de otra base.
- **Los nombres son únicos** (`01` §5): dos objetos de la fuente con el mismo nombre expuesto, o una
  vista con el nombre de uno expuesto, son `OOS2050`.
- **El interruptor** (`01` §6): `datasources[].federation` dice si la fuente se deja leer en vivo.
  Sin él, la base foránea **compila y está congelada**: toda lectura de lo que expone es `OOS2051`
  antes de conectar.
- **La colección virtual** (`01` §7): en una base foránea, un `ObjectTable` expuesto **es** su
  colección virtual de medios: sus ítems son los objetos del origen, en vivo.

## 3. Qué no entra

- **Un `kind` de base.** Una base estándar es un `Package` cuyos documentos son suyos; una foránea
  es un `Package` que además **nombra** lo de una fuente. La diferencia es una clave, no un tipo de
  documento.
- **Entidades sobre una base foránea.** Respaldar una entidad con lo que se lee en vivo pide decidir
  qué se sirve, con qué latencia y qué se escribe; queda para otra versión. Hoy es `OOS2049`.
- **Escribir en el origen.** Nada de lo expuesto se escribe: la salida de un `Transform` que
  resuelve a algo expuesto es `OOS2046`, como la de una `Table`.
- **Renombrar o recortar al exponer.** Lo expuesto se llama como en la fuente y tiene sus columnas;
  otra forma es una vista dentro de la base.
- **Cuándo se cataloga la fuente.** Que un objeto nuevo del origen aparezca en el espejo depende de
  que alguien lo catalogue en la fuente; cuándo y cómo, es de quien implementa.
- **Cambiar lo que ya compila.** Un `Package` sin `spec.foreign` sigue siendo lo que era, con
  cualquier `apiVersion`.
