# OOS v1alpha30 — alcance

**Estado:** borrador de alcance, **alpha**: sin garantías de compatibilidad. Sus obligaciones son
**de ejecución**, de quien sirve los datos, y valen para **todo** árbol, declare la `apiVersion`
que declare ([`01`](01-la-salud.md) §8).

| | |
|---|---|
| `00-scope` | **este documento** — qué entra, qué no, y por qué |
| [`01-la-salud`](01-la-salud.md) | **la salud de un activo**: de cuándo es lo que se sirve, los cuatro estados, lo que se le debe a quien lee, las tres capas y el bloque de salud |

Esta versión **no añade un `kind`, ni una clave, ni un código de documento**. No cambia lo que
compila. Lo que cambia es **qué debe decir quien sirve un activo sobre ese activo**.

---

## 1. Lo medido

v1alpha1 ya obligaba a algo ([`03-binding`](../v1alpha1/03-binding.md) §3.2): superado el umbral
de frescura sin refresco, una implementación **DEBE** declarar el estado degradado al consumidor, y
**NO DEBE** servir datos obsoletos como si fueran frescos. v1alpha12 lo heredó en
`Dataset.freshness`, como el *target lag*.

Lo que faltaba es **con qué se mide** y **qué se le dice a quien lee**. Sin eso, la obligación no se
cumple, o se cumple a medias. Medido en la plataforma que implementa OOS (ORE 0063, M1–M8,
2026-10-13), sobre orígenes de prueba propios y sobre una celda real:

- **La hora que se enseña no es la de los datos.** La ficha de un dataset decía que era de hoy, y
  sus datos se habían leído del origen once días antes. Lo que se guardaba era la hora de su
  publicación, no la de su lectura.
- **«Al día» sin haber mirado.** Una copia sin testigo decía «al-dia» en cada pasada **sin
  preguntar al origen**. La decía con los datos del origen cambiados, con una columna renombrada y
  con el origen apagado.
- **Una pasada fallida dejaba a oscuras al consumidor.** La copia anterior, buena, seguía en el
  almacén, y nadie la podía leer: SQL y Python decían «la copia no está hecha».
- **Un origen vaciado se publicaba con 0 filas**, sin un aviso.
- **Una lectura en vivo sobre un origen que cambió de esquema** decía «Not found», y la tabla
  existía.
- **El testigo de v1alpha8 no dice si un activo cambió.** El modo `log` se mueve con cualquier
  confirmación del servidor; el modo `field` no ve actualizaciones, borrados ni llegadas tardías.
  Sirve para lo que se diseñó, que es retomar una lectura sin perder ni repetir, no para esto.

## 2. Lo que entra

1. **De cuándo es lo que se sirve** ([`01`](01-la-salud.md) §1). Son tres horas: **los datos**
   (cuándo se leyó el origen), **la comprobación** (cuándo se vio por última vez que el origen no
   había cambiado) y **el cambio del origen** (cuándo se supo que cambió). Con ellas, el
   **retraso** y la **edad**, que no son lo mismo.
2. **Los cuatro estados**: `healthy`, `warning`, `degraded` y `unknown` ([`01`](01-la-salud.md)
   §2). Gana el peor, y baja por el linaje. `degraded` es el estado degradado de v1alpha1, con
   nombre.
3. **Lo que se le debe a quien lee** ([`01`](01-la-salud.md) §3):
   - nunca fresco sin haberlo comprobado;
   - `unknown` nunca cuenta como `healthy`;
   - la hora que se enseña es la de los datos;
   - una pasada fallida o retenida no apaga lo último bueno;
   - el estado viaja con el dato.
4. **La versión vigente y la última buena** ([`01`](01-la-salud.md) §4).
5. **Las tres capas** ([`01`](01-la-salud.md) §5). La **0**, lo que se sabe al refrescar,
   obligatoria y sin interruptor. La **1**, vigilar entre refrescos, y la **2**, perfilar y
   comprobar con consultas, que son opcionales y se encienden por ámbito.
6. **El bloque de salud** ([`01`](01-la-salud.md) §6) y su esquema
   ([`health.schema.json`](../../schemas/v1alpha30/health.schema.json)). Es la forma en que todo
   esto llega a quien lee: una persona, un programa o un agente.

## 3. Lo que no entra

- **La gramática de las promesas** más allá de `freshness`: esquema, volumen, validez, y su
  severidad `Blocking` o `Warning`. Su casa es el `Ruleset`, que tendrá que poder nombrar activos;
  es otra versión. Aquí, la única promesa es `freshness`, la que ya existe.
- **El documento que enciende las capas 1 y 2** por base, schema o activo. Aquí sólo se dice que
  existen, que vienen apagadas y que su ausencia se enseña.
- **Las incidencias**: su ciclo, a quién se avisa y cómo se agrupan. Son del producto, no de la
  spec.
- **Cómo se pregunta a un origen si cambió.** Es del contrato de los conectores de cada
  implementación. La spec sólo exige que lo que se afirme esté respaldado por una medida (§3).
- **Umbrales aprendidos** y anomalías.

## 4. Lo que se acepta a cambio

- **Más que decir en cada lectura.** Una respuesta lleva su bloque de salud. Es poco, pero es en
  todas.
- **Un estado `unknown` visible** donde antes había un verde. Habrá menos verde en el catálogo de
  lo que había, y eso es lo correcto: el verde de antes no estaba respaldado.
- **Guardar lo último bueno** cuesta almacén mientras un refresco no se resuelve. Es el precio de no
  apagar al consumidor.
