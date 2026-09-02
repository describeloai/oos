# Suite de conformidad — v1alpha8

**Borrador.** Certifica la tabla y la vista adelgazada de [`spec/v1alpha8/`](../../spec/v1alpha8/),
cuyo alcance sigue **abierto** y que **no es normativo**.

---

## Por qué vive en su propio árbol

Por lo mismo que los demás borradores: un marcador significa *una implementación de referencia
pasa esto*, y mezclar casos de un borrador con los de v1alpha1 daría un número que ya no se sabe
qué mide.

**Los árboles anteriores no se tocan.** `conformance/v1alpha7/` se queda entero, con sus trece
casos y sus vistas con `from.datasource`: es la suite de una versión que existió y cuyos
documentos siguen compilando. La afirmación que esta versión tiene que sostener es que **no
cambia un solo resultado de v1alpha1 a v1alpha7**.

## Qué cubre

Siete casos que aceptan y nueve que rechazan. Se agrupan en cuatro cosas que afirmar:

| | Casos |
|---|---|
| **la tabla se sostiene sola** | `table-compiles` · `table-datasource-undeclared` · `upsert-key-not-a-column` · `witness-field-not-a-column` |
| **la vista compone encima, y ahora contra columnas reales** | `view-over-table` · `entity-backed-by-view-over-table` · `field-not-a-column` · `from-table-does-not-exist` |
| **las dos caras deciden qué compila** | `stream-table-materialized` · `virtual-over-materialized-over-stream` · `append-changes-back-an-event` · **`stream-view-not-materialized`** · **`append-changes-back-a-mutable-entity`** |
| **el binding se retira sin romper nada** | `mixed-versions` · `binding-in-v1alpha8` · `materialized-view-leaks-entity-label` |

## Los códigos

Nuevos son **dos**, y son los que valen dinero:

- **`OOS2020`** — *lo que no se puede leer se debe materializar.* Una vista cuya raíz de lectura
  declara `reads: none` promete un sitio donde preguntar que no existe. Databricks lo descubre
  cuando `readStream` no existe sobre una *foreign table*; aquí no compila.
- **`OOS2021`** — *sin retractación no se mantiene lo mutable.* Copiar un flujo que solo anexa no
  da el estado presente: da el histórico, con las filas viejas dentro. **Es el peor modo de fallo
  del motor, porque no produce ningún síntoma.** Foundry lo documenta como limitación.

Todos los demás **se reutilizan**: `OOS1003`, `OOS2004`, `OOS2018` y `OOS4002`. Que
`materialized-view-leaks-entity-label` falle con el mismo código, por la misma razón, con una
tabla debajo, es la afirmación de esta versión: **la tabla movió el puntero de sitio, no la regla
de flujo.**

Y uno cambia de alcance sin cambiar de código: `OOS2018` **llega hasta el suelo**. Hasta aquí
comprobaba el eslabón vista→vista y creía el último tramo, porque ningún documento decía qué
columnas tenía la tabla. `field-not-a-column` es el caso que mide ese peldaño, y en v1alpha7 no
se podía escribir.

## Lo que la primera medición corrigió

Los tres casos válidos que **copian** —`stream-table-materialized`,
`virtual-over-materialized-over-stream` y `append-changes-back-an-event`— se escribieron sin
`ConduitPolicy`, y el compilador los rechazó con `OOS4011`. Tenía razón: una vista con
`materialized` instancia el conducto `materialization.payload`, y **omitir un conducto no es
dejarlo abierto, es cerrarlo**. Los tres declaran el suyo.

El cuarto que copia y no lo declaraba era `invalid/append-changes-back-a-mutable-entity`, que
pasaba igual porque `OOS2021` sale antes. También lo declara ahora: un caso que pasa por un
código distinto del que afirma es un caso que un día cambia de significado sin que nadie lo vea.

## Una desviación del plan, y por qué

El plan de trabajo llamaba a un caso `upsert-without-key`, esperando `OOS2018`. Al escribir el
esquema resultó que `changes.key` es **obligatorio** con `mode: upsert` por construcción, así que
un documento sin clave falla antes con `OOS1004`. Un caso que afirmara `OOS2018` sobre eso
violaría la regla de precedencia de la suite —*no fallar antes con otro código*—, así que el caso
mide lo que un esquema **no puede** mirar: que la clave sea una columna que existe.
Es `upsert-key-not-a-column`.

## Lo que no está aquí, y dónde está

La migración del árbol —`acme-retail`, los paquetes publicados, los gemelos v1alpha8 de los trece
casos de v1alpha7— no son casos de conformidad: son trabajo de migración, y su criterio de listo
es un recuento (cero `from.datasource`, cero `kind: Binding` fuera de las suites anteriores), no
una afirmación de la especificación.

Que `discover` emita tablas y ningún binding tampoco es un caso: se mide en una prueba de fuego
de la implementación, no aquí.
