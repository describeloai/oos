# 01 · La visibilidad dentro de un árbol

**Estado:** normativo. Parte de OOS v1alpha28.

## 1. Dos fronteras

Un árbol tiene dos fronteras, y hasta ahora una regla servía a las dos:

| frontera | qué separa | quién la cruza | qué la gobierna |
|---|---|---|---|
| **la del artefacto** | este árbol de otro | `dependencies` → un paquete publicado (`.oob`), por el lock | `exports` del paquete publicado |
| **la de la base** | dos miembros del mismo árbol | una referencia por nombre: una vista, un dataset, un transform | **el acceso**, al leer (§2) |

v1alpha8 las trataba igual porque el árbol solía tener un miembro. Desde que un árbol es un
catálogo con muchas bases, la segunda es la de cada día, y la primera la de publicar.

## 2. Dentro del árbol, las bases se leen por su nombre

**Normativo:**

- En un árbol cuyo `OntologyConfig` declara **v1alpha28 o posterior**, una referencia de un
  miembro a otro **compila** aunque el otro no la exporte. `OOS2028` **no se aplica** entre
  miembros del árbol.
- Vale para todas las clases de base y en las dos direcciones: una **standard** que lee otra, una
  standard que lee una **foránea** o la base del **catálogo de una fuente**, y una foránea que lee
  una standard (una vista mixta).
- Lo demás que una referencia debe cumplir **no cambia**: que exista (`OOS2018`), que su tipo
  cuadre, que el conducto lo deje (`OOS4011` para leer en vivo, `OOS4002` para no rebajar una
  etiqueta), que la fuente se deje leer en vivo (`OOS2051`).
- **Quién puede leer** una base no lo dice el árbol: lo decide quien sirve los datos, con la
  identidad de quien pregunta. Una implementación **DEBE** comprobarlo al leer, no al compilar —un
  nombre escrito no es un dato leído—.

## 3. `exports` es la frontera del artefacto

**Normativo:**

- `exports` (v1alpha8 `01` §3.2) declara lo que un paquete **publicado** deja usar a quien lo
  importa en `dependencies`. Su gramática, su `OOS2027` (cada nombre resuelve a un documento del
  paquete) y su defecto cerrado (ausente es *nada*) **no cambian**.
- Una referencia de un árbol a un documento de un paquete **de otro artefacto** que este no
  exporta **NO DEBE** resolverse — `OOS2028`. La comprueba quien resuelve el lock: el compilador de
  un árbol no abre los documentos de otro.
- Dentro del árbol, un `exports` presente **no estorba ni concede**: se escribe para quien publique
  el paquete, y entre miembros no se mira.

## 4. La base foránea expone sin pedir `exports`

v1alpha27 (`01` §3, regla 4) exponía sólo lo que el paquete de la fuente exportaba, y nombrar en
`include` algo no exportado era `OOS2028`.

**Normativo**, en un árbol v1alpha28:

- Una base foránea expone **lo que su `include` alcanza** de su fuente: las `Table` y los
  `ObjectTable` de su `datasource` con `metadata.schema` declarado, exporte o no su paquete.
- Lo demás de v1alpha27 sigue: la fuente con `federation: true` para leer (`OOS2051`), sin
  documentos propios salvo `Schema` y vistas sin copia (`OOS2049`), nombres únicos (`OOS2050`).

En un árbol anterior, la regla 4 de v1alpha27 sigue como estaba — `a-tree-before-v1alpha28-keeps-the-export`.

## 5. Los casos

| caso | espera | qué fija |
|---|---|---|
| `valid/databases-read-each-other` | acepta | standard → foránea, standard → fuente y standard → standard, sin un `exports` |
| `valid/a-foreign-package-exposes-without-exports` | acepta | la foránea expone el schema entero de una fuente que no exporta nada |
| `invalid/a-tree-before-v1alpha28-keeps-the-export` | `OOS2028` | el mismo cruce con el `OntologyConfig` en v1alpha27: la regla de antes |
