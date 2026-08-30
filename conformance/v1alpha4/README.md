# Suite de conformidad — v1alpha4

**Borrador — 26/26.** Certifica el régimen de significado de
[`spec/v1alpha4/`](../../spec/v1alpha4/), cuyo alcance sigue **abierto** y que **no es
normativo**.

---

## Por qué vive en su propio árbol

Por lo mismo que los de v1alpha2 y v1alpha3. `73/73` significa algo preciso —*una
implementación de referencia pasa la especificación completa*— y mezclar casos de un borrador
no daría un número falso: daría **un número que ya no se sabe qué mide**.

Cuatro árboles, cuatro marcadores.

## Qué afirma

| Caso | Código | Qué certifica |
|---|---|---|
| `valid/mapped-property-inherits-classification` | — | **la etiqueta heredada de un concepto es indistinguible de una escrita** |
| `valid/shape-satisfied-across-vocabularies` | — | dos entidades sin un nombre en común satisfacen la misma forma |
| `valid/target-by-shape` | — | el tercer eje de objetivo, y que **no** alcanza lo que la interfaz no nombra |
| `valid/vocabulary-package-has-no-entities` | — | publicar vocabulario es un paquete sin entidades |
| `valid/draft-carries-confidence` | — | lo que un inductor escribe **compila** |
| `valid/mapping-may-raise` | — | elevar la clasificación heredada es legítimo |
| `valid/derived-mapping-keeps-its-floor` | — | y una **derivada** también hereda: el concepto entra en el `join` |
| `invalid/implements-not-satisfied` | `OOS9001` | una forma declarada que no se cumple |
| `invalid/confidence-outside-draft` | `OOS9003` | una conjetura fuera de `DRAFT` |
| `invalid/coined-concept-outside-draft` | `OOS9003` | y acuñar cae bajo la misma regla que mapear |
| `invalid/unspoken-concept` | `OOS9004` | una palabra que nadie habla |
| `invalid/redeclares-the-inherited-type` | `OOS1004` | el guardarraíl, **sin código propio** |
| `invalid/mapping-cannot-lower` | `OOS4012` | rebajar la del concepto, con el código de v1alpha1 **intacto** |
| `valid/concept-demand-satisfied` | — | la exigencia **categórica** del concepto, descargada por una política |
| `valid/shape-target-reaches-the-subsumed` | — | una regla sobre `Party` alcanza a quien solo declaró `Employee` |
| `invalid/concept-demands-governance` | `OOS8001` | el concepto exige y el retículo no: **el nivel no basta** |
| `invalid/subsumption-does-not-run-upward` | `OOS8002` | y al revés no: la inclusión de conjuntos no es simétrica |
| `invalid/unknown-governance-nature` | `OOS1004` | una naturaleza mal escrita **no exigía nada, en silencio** |
| `diff/concept-drops-its-demand` | `OOS5024` | un concepto publicado retira una obligación |
| `digest/order-of-sets-is-irrelevant` | — | **G1**: los tres campos nuevos son conjuntos, y ahora lo son de verdad |
| `diff/concept-lowers-its-classification` | `OOS5011` | **`OOS4012` entre versiones** — lo que no se puede hacer dentro de un paquete |
| `diff/concept-removed` | `OOS5007` | lo que otros nombran deja de existir |
| `diff/shape-requires-more` | `OOS5025` | una forma exige más: quien la implementaba **no compila** |
| `diff/shape-requires-less-is-safe` | — | y encogerla **no rompe**: la asimetría es un teorema |
| `emit/mapped-property-emits-what-it-means` | — | lo que hereda **llega al contrato**: tipo, clasificación y `enum` |
| `emit/mapped-property-roundtrip` | — | y la vuelta es la identidad, que es **por lo que se emite `x-oos-is`** |

Veintiséis casos y **cuatro códigos nuevos**. La proporción es la señal: veintidós de los
veintiséis se certifican con maquinaria que ya existía — y de los cuatro cambios que la fase
2 mete en el `diff`, **tres reutilizan códigos de v1alpha1 sin tocarlos**, porque un concepto
declara lo mismo que una propiedad y sus cambios son los mismos cambios.

Los seis últimos son las dos decisiones que quedaban abiertas, ya construidas: **la exigencia
categórica de un concepto** y **la subsunción entre formas**. Ninguna de las dos añadió un
código, y la segunda no añadió tampoco un campo: `I ⊑ J` se computa de la inclusión entre sus
`requires`, así que no hay nada que declarar ni, por tanto, nada que escribir mal.

## Los dos casos que hay que leer juntos

`valid/mapped-property-inherits-classification` e `invalid/mapping-cannot-lower` son el mismo
caso con una línea de diferencia, y entre los dos está toda la versión.

En el primero, la propiedad declara **solo** `is: gdpr.personalEmail` — ni tipo, ni etiqueta,
ni una mención en ningún `Ruleset`— y aun así queda cubierta, porque el objetivo por
predicado la selecciona. En el segundo, la misma propiedad intenta rebajar lo que hereda y
falla con `OOS4012` **sin que ese código se haya tocado desde v1alpha1**.

Que la regla más antigua gobierne el mecanismo más nuevo sin una letra de cambio es la
prueba de que `is` no abrió un plano de análisis: se enchufó como **tercera fuente de
herencia** en la propagación que ya estaba, al lado de la entidad y del `datasource`.

## Lo que estos casos encontraron

Los cuatro defectos siguientes **no se ven leyendo la especificación**. Aparecieron al
escribir los casos y al medir una decisión abierta en vez de razonarla, que es el método:

| Qué decía la spec | Qué pasó | Dónde está escrito |
|---|---|---|
| una propiedad con `is` no declara `type` **ni `labels`**… y puede elevar la clasificación | **se contradecía**: elevar exige escribir | `01-significado` §4.2 |
| `entity` y `event` pasan a ser interfaces incorporadas | `requires` nombra conceptos, y `primaryKey` no lo es | `01-significado` §5 |
| `confidence` es un `number` desde v1alpha1 | un decimal sin comillas no tiene forma canónica: `OOS6003` | `type/basic.schema.json` |
| `derivedFrom` junto a `is` «habrá que comprobar que no lo enturbie» | **borraba la clasificación del concepto en silencio** | `00-scope` §6 · cerrada |
| el vocabulario de naturalezas de `requiresGovernance` estaba cerrado **y nadie lo validaba** | una naturaleza mal escrita se descartaba: la exigencia no exigía nada | `02-property` §3.3 |
| `CONJUNTOS` mira la clave inmediata, y en un retículo las naturalezas cuelgan del nivel | el mismo campo, **ordenado en un concepto y sin ordenar en un retículo** | `00-scope` §8.5 |
| el importador de ODCS sellaba **siempre** `v1alpha1` | la vuelta producía un documento que declara una versión **donde `is` no existe** | `00-scope` §8.5 |

El tercero llevaba **cuatro versiones** en el árbol y era invisible porque **ningún documento
referenciaba el campo**. Darle su primer usuario lo destapó en el primer caso que lo usó.

El cuarto es el peor, porque **compilaba**: añadir `derivedFrom` a una propiedad mapeada le
quitaba la etiqueta que heredaba del concepto, y con ella toda la exigencia de gobierno. Sin
`derivedFrom` el mismo paquete rompe con `OOS8001`. Lo destapó medir una decisión abierta en
vez de razonarla — `valid/derived-mapping-keeps-its-floor`.

El quinto **no es de v1alpha4**: es de v1alpha3, y lleva ahí desde que existe
`requiresGovernance`. El cálculo de cobertura filtra las naturalezas contra una lista cerrada,
así que una que no reconoce se descarta y la exigencia **no exige nada, en silencio**. Nadie
lo validaba. Lo destapó añadir el mismo campo un nivel más arriba: si solo se hubiera validado
el nuevo, el viejo habría quedado peor por comparación con algo escrito el mismo día —
`invalid/unknown-governance-nature`.

Cuarta vez que aparece la misma ley, y ya conviene numerarla: **`OOS8002`, `OOS9004`,
`OOS9001` y ahora esto. Lo que no gobierna tiene el mismo aspecto que lo que gobierna.**
