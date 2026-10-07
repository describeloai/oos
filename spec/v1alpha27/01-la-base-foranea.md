# 01 · La base foránea

**Estado:** normativo. Parte de OOS v1alpha27.

## 1. Qué es

Una **base foránea** es un `Package` que **expone, con su nombre, los objetos de una fuente** que
se lee en vivo: sus `Table` y sus `ObjectTable`. No los copia ni los redeclara: los **nombra**.
Quien pregunta por `ventas_vivo.ventas.clientes` lee la tabla `clientes` del origen, en el momento
en que pregunta ([`v1alpha24/01`](../v1alpha24/01-leer-el-origen.md)).

| | base **estándar** | base **foránea** |
|---|---|---|
| qué es | un `Package` | un `Package` con `spec.foreign` |
| sus datos | **suyos**: datasets, colecciones, en el lago | **del origen**: se leen donde están |
| qué contiene | lo que declare | `Schema` y vistas sin copia (§4) |
| una tabla del origen | la copia en un `Dataset` | **la misma `Table`**, con otro nombre (§3) |
| fuera | *managed catalog* (Unity), un proyecto de Foundry | *foreign catalog* (Unity), un catálogo de Trino, una *external schema* de Redshift |

## 2. La declaración

```yaml
apiVersion: oos.dev/v1alpha27
kind: Package
metadata: { name: ventas_vivo, version: 0.1.0, status: active, domain: ventas }
spec:
  owner: team:ventas
  foreign:
    datasource: erp                 # la fuente; tiene que estar en `datasources` (OOS2004)
    include:
      - ventas                      # un schema entero: un espejo
      - finanzas.facturas           # un objeto suelto
```

| clave | | |
|---|---|---|
| `foreign.datasource` | **obligatoria** | el nombre de una fuente de `datasources` (`OOS2004` si no está) |
| `foreign.include` | **obligatoria**, no vacía | cada entrada es un **schema** (`<schema>`) o un **objeto** (`<schema>.<objeto>`) de la fuente, sin repetidos |

**Normativo.**

- Un `Package` con `spec.foreign` **ES** una base foránea; uno sin él, no, con cualquier
  `apiVersion`. No hay otra forma de declararla.
- Un schema en `include` es un **espejo**: expone lo que la fuente tenga en él **cuando se compila**
  —lo que se catalogue después aparece sin tocar la base—. Un objeto en `include` expone ese y sólo
  ese.
- Una entrada que no nombra nada de la fuente **no es un error**: el origen cambia sin pedir
  permiso, y una base que dejara de compilar porque alguien borró una tabla allí no sería un
  espejo. Una implementación **DEBERÍA** avisar.

## 3. La resolución: el mismo documento, dos nombres

Lo que una base foránea `B` con `foreign.datasource: D` **expone** es cada documento `T` tal que:

1. `T` es una `Table` o un `ObjectTable` con `spec.datasource: D`;
2. `T` declara `metadata.schema` ([`v1alpha13/01`](../v1alpha13/01-el-schema.md)) — `s` — y su nombre es `n`;
3. `include` nombra `s`, o nombra `s.n`;
4. el paquete de `T` lo **exporta**. Si `include` nombra `s.n` y no se exporta, es `OOS2028`; un
   schema en espejo expone sólo lo exportado.
   *(Desde v1alpha28 —[`01-la-visibilidad`](../v1alpha28/01-la-visibilidad.md) §4—, en un árbol
   v1alpha28 esta regla no se aplica: se expone lo que `include` alcanza.)*

Su **nombre expuesto** es `B.s.n`.

**Normativo.**

- `B.s.n` **ES** `T`. No es otra tabla ni una vista: columnas, tipos, `reads`, `changes`, etiquetas
  y la fuente son los de `T`, y cambian cuando `T` cambia. Una implementación **NO DEBE** derivar
  de `T` un documento nuevo para exponerlo.
- Todo lo que resuelve un nombre —una vista, un `FROM`, una entrada de un `Transform`, una
  consulta— resuelve `B.s.n` a `T`. Un nombre de `B` que no es expuesto ni un documento de `B` es
  `OOS2018`, como cualquier nombre que no existe.
- Leer `B.s.n` **ES** leer `T` en vivo, con todo lo de [`v1alpha24/01`](../v1alpha24/01-leer-el-origen.md):
  el conducto `federation.read` (`OOS4011`), lo que se empuja, `fullScan` y `requiredFilters`
  (`OOS2044`, `OOS2045`).
- Un documento de otro paquete que nombra `B.s.n` necesita que `B` lo exporte (`OOS2028`):
  `exports` de una base foránea puede nombrar lo que expone sin que sea `OOS2027`.
- Una `Table` sin `metadata.schema` no se expone nunca.

## 4. Lo que contiene

Una base foránea no tiene datos propios. **Normativo:**

- Sus documentos son `Schema` y `View` **sin `materialized`**. Cualquier otro —`Table`,
  `ObjectTable`, `Dataset`, `MediaCollection`, `Entity`, `Binding`— o una vista con
  `materialized` es `OOS2049`.
- Tampoco es la salida de un `Transform` (v1alpha25): un build escribe datos, y los escribe en una
  base estándar. Un `Transform` cuyo `output` nombra una base foránea es `OOS2049`, y se dice al
  validar, sin construir. Sí puede leerla: sus `inputs` nombran lo que ella expone.
- Un schema expuesto existe sin documento: lo crea la exposición. Para escribir una vista en él, la
  base declara su `Schema`, como siempre (`OOS2037`).
- Una vista de una base foránea puede leer lo que exponga ella, lo que expongan otras y lo que
  sea legible por nombre en el espacio de trabajo: es una vista virtual, y se lee en vivo hasta
  donde llegue al origen.

> **Por qué nada más.** Una copia dentro de una base foránea es la regla que hacía de la clase un
> hecho y no una declaración: «es foránea, menos esta tabla». Copiar algo del origen es crear un
> `Dataset` **en otra base** —una estándar—, que lo lee de aquí.

## 5. Los nombres son únicos

**Normativo.** Es `OOS2050`:

- que dos documentos expuestos tengan el mismo nombre expuesto —dos `Table` de la fuente, en dos
  paquetes, con el mismo schema y el mismo nombre—;
- que una vista de la base tenga el nombre de algo que expone.

## 6. El interruptor, y la base congelada

Esta versión añade a cada entrada de `datasources` del `OntologyConfig`:

| clave | | |
|---|---|---|
| `federation` | opcional, `false` por defecto | `true`: la fuente se deja **leer en vivo** |

```yaml
apiVersion: oos.dev/v1alpha27
kind: OntologyConfig
metadata: { name: acme, version: 0.1.0 }
datasources:
  - { name: erp, type: postgres, connectionEnv: ERP_URL, federation: true }
```

`federation` y `federation.read` son dos decisiones: la primera es **de la fuente** —quien la
administra dice si se le puede preguntar en vivo—; la segunda, **de lo que sale** —qué puede
fluir de lo leído, con qué etiquetas—. Las dos tienen que dejar.

**Normativo.**

- Con un `OntologyConfig` de v1alpha27 o posterior, una lectura en vivo de un objeto de una fuente
  sin `federation: true` **NO DEBE** hacerse: `OOS2051`, **antes de conectar** y antes que
  cualquier otro código de la lectura. Uno anterior no declara el interruptor, y su ausencia no
  niega nada.
- Una base foránea sobre esa fuente **compila**, se ve y conserva sus vistas: está **congelada**.
  Todo lo que lea de ella es `OOS2051`. Cuando la fuente vuelve a `federation: true`, vuelve sola.

## 7. La colección virtual de una base foránea

Un `ObjectTable` expuesto **es** la colección virtual de medios de la base: sus ítems son los
objetos que el origen lista **ahora**, con sus metadatos (`key`, `size`, `modified`…), y sus bytes
se sirven desde el origen. **Normativo:**

- Listar y servir un ítem de lo expuesto **ES** una lectura en vivo (§3): `federation.read`,
  `OOS2051`.
- No tiene transacciones ni historia. La `MediaCollection` con `virtual: true`
  ([`v1alpha16/02` §3](../v1alpha16/02-media-collection.md)) —la que fija qué ítems tenía en cada
  transacción sin copiar los bytes— sigue existiendo, **fuera** de las bases foráneas.

## 8. Códigos

| Código | Condición | Doc |
|---|---|---|
| `OOS2049` | una base foránea contiene algo que no es un `Schema` o una vista sin `materialized` | §4 |
| `OOS2050` | un nombre expuesto no es único: dos objetos de la fuente, o un objeto y una vista de la base | §5 |
| `OOS2051` | lectura en vivo de un objeto de una fuente sin `federation: true` (una base foránea congelada) | §6 |

## 9. De v1alpha26 a v1alpha27 (informativo)

Una base que alguien indujo como foránea —un `Package` con una vista por tabla, cada una el
`SELECT` de todas las columnas de una `Table` de la fuente— pasa a ser un `Package` de v1alpha27
con `spec.foreign` cuyo `include` nombra esas tablas, **sin** esas vistas. Si la vista vivía en
el schema del objeto y con su nombre, quien la leía sigue leyéndola por el mismo
(`<base>.<schema>.<objeto>`); si no —una vista sin schema, o renombrada—, el nombre cambia, y quien
migra lo dice. Las vistas que alguien escribió y no son la identidad se quedan.
