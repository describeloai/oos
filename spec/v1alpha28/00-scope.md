# OOS v1alpha28 — alcance

**Estado:** borrador de alcance. Su regla vale para **todo** árbol, declare la `apiVersion` que
declare (sólo quita errores: [`01`](01-la-visibilidad.md) §6), y es **alpha**: sin garantías de
compatibilidad.

| | |
|---|---|
| `00-scope` | **este documento** — qué entra, qué no, y por qué |
| [`01-la-visibilidad`](01-la-visibilidad.md) | **la visibilidad dentro de un árbol**: las bases de un árbol se leen entre sí por su nombre; `exports` es la frontera del artefacto, no la de cada base |

Esta versión **no añade un `kind`, ni una clave, ni un código**. Cambia **dónde se aplica una regla
que ya existía** —`OOS2028`, de v1alpha8— y lo que la base foránea de v1alpha27 pide a su fuente.

---

## 1. La tesis

| versión | un árbol | una referencia a otro paquete del árbol |
|---|---|---|
| v1alpha8 | un paquete, a veces dos | **compila sólo si el otro la exporta** (`OOS2028`) |
| v1alpha20 | sus paquetes son **bases** con schemas, como en un catálogo | igual |
| **v1alpha28** | **un catálogo** —un *metastore*— con muchas bases | **compila**; quién puede leerla lo decide el acceso |

`exports` se escribió (v1alpha8 `01` §3.2) para el paquete como **módulo**: la unidad que un equipo
publica y otro importa, con su superficie pública, como el `module-info` de Java. Lo dijo entonces
con lo medido: *«en el corpus entero ninguna referencia cruza la frontera de un paquete dentro del
mismo árbol»*. El árbol era, casi siempre, un paquete.

Hoy no. La plataforma que implementa OOS (ORE 0038) hace del árbol **el catálogo de una
organización**, con una base por fuente, por equipo, por producto, y lo medido en sus dos celdas
(ORE 0057 X0, 2026-10-07) es esto:

- `exports` **sólo lo escribe la fuente**, para que el resto pueda leer las tablas que cataloga: 6
  de 22 bases en una celda, 5 de 8 en la otra. Ninguna persona lo escribió.
- **Ninguna referencia cruza entre dos bases de usuario.** No porque no se quiera: porque **no
  compila**. La primera vez que alguien lo intentó —una vista en una base de pruebas sobre la
  colección de otra— fue `OOS2028`.
- Lo que protege, al leer, **no es esto**: decidir quién lee qué base es del control de acceso de
  quien sirve los datos. Un manifiesto que se comprueba al compilar no impide leer nada; sólo
  impide **escribir** la referencia.

Es lo que hace la industria de catálogos. En Unity Catalog las bases de un *metastore* se nombran
entre sí sin lista de exportación, y quién lee qué es un `GRANT` (`USE CATALOG`, `USE SCHEMA`,
`SELECT`); lo que sale del *metastore* hacia otro se comparte aparte (*Delta Sharing*). Snowflake
igual: las bases de una cuenta se leen por su nombre con privilegios, y salir de la cuenta es un
*share*.

## 2. Lo que entra

1. **Dentro de un árbol, una referencia entre bases compila** —standard, foránea o la
   base del catálogo de una fuente; en cualquier dirección—. `OOS2028` no se aplica entre miembros
   del árbol ([`01`](01-la-visibilidad.md) §2).
2. **`exports` sigue siendo la superficie pública del paquete hacia fuera del árbol**: lo que un
   paquete publicado deja usar a quien lo declara en `dependencies` ([`01`](01-la-visibilidad.md)
   §3). Su gramática no cambia.
3. **La base foránea expone lo que su `include` alcanza**, aunque el paquete de la fuente no lo
   exporte ([`01`](01-la-visibilidad.md) §4). Lo demás de v1alpha27 no cambia: la fuente con
   `federation: true` (`OOS2051`), sin datos propios (`OOS2049`), nombres únicos (`OOS2050`).
4. **Sin puerta de versión** ([`01`](01-la-visibilidad.md) §6): la regla sólo quita errores, así
   que vale para todo árbol, también los de un `OntologyConfig` anterior. Ninguno deja de compilar.

## 3. Lo que no entra

- **Quién puede leer qué.** Es el control de acceso de la plataforma (en ORE, 0047 A8), al servir
  los datos. OOS no gana con esta versión una gramática de permisos: los conductos (`federation.read`,
  `materialization.payload`, `contextSurface.*`) siguen diciendo **por dónde** puede salir un dato,
  que es otra pregunta.
- **Compartir fuera del árbol** con otra organización (lo que Unity llama *Delta Sharing*). El
  artefacto (`.oob`) y `dependencies` ya son la frontera; un modo de compartir sin publicar no
  entra.
- **Comprobar la frontera del artefacto en el compilador.** Una dependencia se resuelve por el lock y
  el registro, no por el árbol: el compilador de un árbol no abre los documentos de otro. La regla
  es normativa ([`01`](01-la-visibilidad.md) §3) y la aplica quien resuelve el lock.

## 4. Lo que se pierde, y por qué se acepta

Con la regla de antes, para que otra base leyera algo había que **publicarlo a propósito**. Con
esta, cualquier base del árbol lo nombra. La señal *«esto lo expongo»* deja de vivir en el
manifiesto y pasa al acceso: hasta que la plataforma decida lecturas por base, schema u objeto,
cualquiera que lea el árbol puede **escribir** una referencia a cualquier base de él.

Se acepta porque la señal de antes **no protegía lo que parecía**: no impedía leer, sólo nombrar; y
porque en el corpus medido no la escribía nadie más que la fuente, para abrir lo que cataloga.
