# OOS v1alpha13 — alcance

**Estado:** borrador de alcance. Gobierna los documentos que declaran su `apiVersion`, y es
**alpha**: sin garantías de compatibilidad.

| | |
|---|---|
| `00-scope` | **este documento** — qué entra, qué no, y por qué un nombre tiene tres niveles |
| [`01-el-schema`](01-el-schema.md) | el schema: el `kind` que lo hace existir, la clave que lo declara, dónde vive, cómo se nombra y se refiere, y lo que cambia en la forma canónica |

Esta versión **añade un `kind`** —`Schema`—, **añade una clave** a los documentos de contenido
gobernado —`metadata.schema`— y **alarga el nombre cualificado** de esos documentos a tres
niveles: `<paquete>.<schema>.<nombre>`. Añade dos códigos de error, `OOS2036` y `OOS2037`.

---

## 1. La tesis

| versión | verbo | la regla |
|---|---|---|
| v1alpha7 | **preguntar** | la vista es la pregunta y compone |
| v1alpha8 | **apuntar** | lo físico se registra una vez, con dos caras |
| v1alpha9 | **razonar** | un modelo que se usa es un documento del árbol, y nombra un perfil medido |
| v1alpha10 | **actuar** | lo que una función toca se lee en su documento, en los dos sentidos |
| v1alpha11 | **publicar** | lo que el código produce y no es una tabla entra en el árbol como un documento que nombra sus bytes |
| v1alpha12 | **tener** | lo que un inquilino tiene es un documento de su paquete, y uno solo, se llene como se llene |
| **v1alpha13** | **ordenar** | **lo que se tiene se ordena en schemas, y el schema es parte del nombre** |

Hasta aquí un nombre tenía dos niveles —`ventas.pedidos`— y lo que había entre el paquete y el
fichero era una carpeta: ordenaba el árbol, pero no el nombre. Dos `pedidos` en
`ventas/espana/` y `ventas/francia/` eran **el mismo documento declarado dos veces**
(`OOS2035`), y un catálogo que los enseñara en dos schemas enseñaba algo que el lenguaje no
tenía.

Los catálogos de datos lo resolvieron igual. Unity Catalog nombra todo lo que registra
`catálogo.schema.objeto` —la identidad de una tabla **es** su nombre completo— y cada catálogo
nace con un schema `default`; el estándar SQL llama a los tres niveles *catalog*, *schema* y
*object*; Snowflake, *database.schema.object*. Aquí el primer nivel ya existía y tiene nombre:
**el paquete**. Esta versión añade el segundo.

## 2. Por qué se declara, y no sale de la carpeta

Porque la identidad de un documento **nunca** es su ruta ([`90-canonical-form` §5.2](../v1alpha1/90-canonical-form.md)):
un documento importado de un `.oob` no tiene carpeta, y un paquete que se mueve de sitio no
cambia de nombre. La carpeta y el nombre **se atan**, no se confunden: exactamente como
`OOS2030` ata el `namespace` al paquete que contiene al documento
([`01-package` §3.5](../v1alpha1/01-package.md)), `OOS2036` ata `metadata.schema` a la carpeta
del schema que lo contiene. El nombre lo dice el documento; la carpeta tiene que estar de
acuerdo.

## 3. Por qué un `kind`, y no sólo la clave

Porque un schema **existe antes que lo que contiene**, y tiene dueño. Crear un schema vacío es
lo primero que se hace en un catálogo —para escribir en él—, y una carpeta vacía no existe en un
árbol de ficheros bajo control de versiones: git no la guarda. Sin un documento que lo haga
existir, un schema sería lo que queda cuando alguien deja un fichero dentro, y desaparecería
con el último. Unity lo registra como un objeto con dueño y comentario; aquí es
**`kind: Schema`**, con `owner` y `description`. [`01-el-schema` §2](01-el-schema.md).

## 4. Qué entra

- `kind: Schema` — un schema de un paquete, con su dueño. [`01-el-schema` §2](01-el-schema.md).
- `metadata.schema` en el contenido gobernado —`Entity`, `View`, `Table`, `Dataset`,
  `Function`, `Action`, `TrainedModel`—, con `default` cuando falta. §3.
- El nombre cualificado de ese contenido pasa a `<paquete>.<schema>.<nombre>`, y las
  referencias a él se leen en una, dos o tres partes. §4, §5.
- `OOS2036` (la carpeta no es la del schema) y `OOS2037` (el schema no existe). §7.
- **Y un esquema que faltaba**: v1alpha12 cambió `View` en prosa —`from: { dataset }`, sin
  `materialized` ni `freshness`— y su último esquema publicado seguía siendo el de v1alpha8, que
  aceptaba lo retirado y negaba lo nuevo. `schemas/v1alpha13/view.schema.json` es el primero que
  dice lo que la vista es desde v1alpha12, más `metadata.schema`.

## 5. Qué no entra, y por qué

- **El vocabulario compartido.** `Lattice`, `Ruleset`, `Concept`, `Interface` y las políticas
  se nombran por su vocabulario, que tiene que ser el mismo desde todos los paquetes (§3.5 de
  `01-package`). No se ordena en schemas: no es algo que se tenga, es algo que se dice.
- **Schemas anidados.** Un nivel, como en Unity y en SQL. Lo que hay más abajo de la carpeta
  del schema son carpetas que ordenan ficheros (las del `kind`, las de un repositorio), no
  nombres.
- **Permisos por schema.** Quién puede leer o escribir en un schema es del plano de control,
  como lo es por paquete. Que el schema sea un nombre es lo que lo hace posible; decidirlo no
  es de esta gramática.
- **El nombre en SQL.** Cómo se escribe `<paquete>.<schema>.<nombre>` en una consulta —y qué
  motor resuelve qué— es de quien ejecuta SQL. Esta versión sólo fija que ése es el nombre.
- **Mover entre schemas.** Mover un documento de schema **es** renombrarlo —cambia su
  identidad—, y los que lo nombran en tres partes tienen que cambiar con él. El verbo que mueve
  (y reescribe las referencias) es de las herramientas, como lo es mover entre paquetes.

## 6. Compatibilidad y migración

Ningún documento de v1alpha1 a v1alpha12 cambia de resultado. `kind: Schema` en una versión
anterior es `OOS1003`; `metadata.schema` en una versión anterior es `OOS1005`.

Un documento de contenido gobernado de una versión anterior **está en el schema `default`** de
su paquete: no puede decir otra cosa. Su forma canónica y su digest **no cambian** —no lleva
la clave, y su `docId` sigue siendo el de dos partes (§6 de `01-el-schema`)—, y dónde esté su
fichero sigue sin significar nada, como hasta ahora. Donde se compara identidad —dos
documentos que dicen ser el mismo, `OOS2035`; una referencia que lo nombra— cuenta como
`<paquete>.default.<nombre>`.

La migración de un árbol es **nada**, si todo sigue en `default`: los documentos siguen
compilando y siguen llamándose lo mismo —`ventas.pedidos` se lee `ventas.default.pedidos`—.
Para ordenar en schemas:

| antes | después |
|---|---|
| `packages/ventas/espana/datasets/pedidos.yaml` (v1alpha12, la carpeta sólo ordenaba) | `packages/ventas/espana/schema.yaml` con `kind: Schema`, `name: espana` **más** el documento en v1alpha13 con `metadata.schema: espana`. Su nombre pasa de `ventas.pedidos` a `ventas.espana.pedidos` |
| una referencia de otro documento a `ventas.pedidos` | `ventas.espana.pedidos` (o `pedidos` si quien la hace está en el mismo schema) |
| dos `pedidos` que no podían convivir (`OOS2035`) | dos documentos, `ventas.espana.pedidos` y `ventas.francia.pedidos` |
