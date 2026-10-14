# OOS v1alpha31 — alcance

**Estado:** borrador de alcance, **alpha**: sin garantías de compatibilidad. La gramática es **del
documento** que declara v1alpha31; lo que se comprueba al refrescar es **de ejecución**, de quien
mantiene la copia ([`01`](01-las-promesas.md) §6).

| | |
|---|---|
| `00-scope` | **este documento** — qué entra, qué no, y por qué |
| [`01-las-promesas`](01-las-promesas.md) | **las promesas de un activo**: dónde se escriben, la biblioteca por familia, cuándo se comprueban y qué pasa cuando una falla |

Esta versión **añade una clave**, `spec.promises`, a `Dataset` y a `MediaCollection`, y **dos
códigos**: `OOS2052` y `OOS2053`.

---

## 1. Lo medido

v1alpha30 dio al consumidor la verdad sobre **cuándo**: de cuándo son los datos, si se comprobó el
origen y si el último refresco se publicó. No dio la verdad sobre **qué**. Medido en la plataforma
que implementa OOS (ORE 0063, M5–M8 y la vara de S0, 2026-10-13):

- **Un origen vaciado se publicaba con 0 filas.** La primera guarda (v1alpha30 §4) lo retiene, pero
  es una sola, fija, y nadie la ve ni la elige.
- **El dueño no tiene dónde decir lo que espera.** «Al menos 900 filas», «`cliente` nunca vacío»,
  «solo imágenes» no se pueden escribir en ningún documento que algo compruebe. La única promesa
  que se juzga es `freshness`.
- **El `Ruleset` (v1alpha3) tiene la forma, pero no el sitio.** Sus aserciones siguen el perfil de
  ODCS, y apuntan a **propiedades** de una entidad por su clasificación. Sirven para el gobierno
  (que cada propiedad sensible tenga quien responda), no para que el dueño de una copia diga qué
  promete de ella, y ninguna implementación las evalúa contra datos.

## 2. Lo que entra

1. **Las promesas viven en el documento del activo** ([`01`](01-las-promesas.md) §1): `promises`
   en el `spec` de un `Dataset` o de una `MediaCollection`, junto a `freshness`. Es lo que escribe
   su dueño, con el activo, por la misma propuesta. Así lo hacen dbt (los tests en el YAML del
   modelo), Databricks (las *expectations* de la tabla), Foundry (las de la salida del transform) y
   Snowflake (las funciones de métrica sobre la tabla).
2. **La forma es la aserción del `Ruleset`**, de tipo `library`, con lo que le faltaba: la
   columna, los argumentos y la biblioteca de objetos ([`01`](01-las-promesas.md) §2). Los nombres
   de ODCS se toman tal cual, para que un contrato pueda nombrar las mismas promesas.
3. **Una biblioteca por familia de activo** ([`01`](01-las-promesas.md) §3): **tabular** para un
   `Dataset`, **objetos** para una `MediaCollection`. Una métrica de otra familia no compila.
4. **Solo lo que sale del refresco** ([`01`](01-las-promesas.md) §4): toda métrica de esta versión
   se puede medir sobre lo que el refresco ya lee o ya escribe, sin otra lectura.
5. **Una promesa de serie, `notEmptied`** ([`01`](01-las-promesas.md) §5): la guarda de v1alpha30
   §4, con nombre. Se puede ablandar, no quitar.
6. **Qué pasa al comprobarlas** ([`01`](01-las-promesas.md) §6): una `error` (*Blocking*) que falla
   **retiene** el refresco; una `warning` lo publica y lo anota; lo que no se pudo medir es
   `unknown`, nunca un aprobado.

## 3. Lo que no entra

- **Las aserciones `sql`** y lo que cruza activos (que todo `pedidos.cliente` exista en
  `clientes`): cuestan su consulta. Son de la capa 2 de v1alpha30 §5.
- **Las promesas de lo que se lee en vivo**: una `View` sin copia, una `Table` o un `ObjectTable`
  de una base foránea. Sin refresco no hay dónde comprobarlas sin leer el origen; es la capa 1.
- **La unicidad compuesta** (`duplicateValues` de varias columnas) y **`invalidValues` con
  `pattern`**: vendrán en otra versión.
- **Las promesas que alguien exige desde fuera** del activo: siguen siendo del `Ruleset`, que tendrá
  que poder nombrar activos. Es otra versión.
- **Cuándo se refresca, y a quién se avisa**: no hay planificador en la spec (v1alpha3 §5).

## 4. Lo que se acepta a cambio

- **Subir la versión del documento para escribir una promesa.** La puerta es del documento, como en
  v1alpha29: un `Dataset` de v1alpha12 sigue igual hasta que su dueño escriba `promises`. Subirlo
  es neutro: entre v1alpha12 y v1alpha31 nada cambia el significado de un `Dataset`, y en una
  `MediaCollection` solo se amplía `media` (v1alpha29).
- **Una promesa `error` puede retener un refresco que antes se publicaba.** Es lo que se promete.
  Quien mantiene la copia **DEBE** ofrecer publicarlo de todos modos (v1alpha30 §4).
