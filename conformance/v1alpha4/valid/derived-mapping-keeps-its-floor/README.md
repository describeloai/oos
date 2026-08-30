# v1alpha4 / valid / derived-mapping-keeps-its-floor

**Regla:** [`02-property.md` §5](../../../../spec/v1alpha4/02-property.md#5) · **Nivel:** L0

---

`crm.Customer.fullEmail` es dos cosas a la vez: **derivada** de `localPart` y `domain`, y
**mapeada** a `gdpr.personalEmail`. Sus dos orígenes están clasificados `low`; el concepto
dice `high`.

Gana `high`, y el `Ruleset` que apunta a `atLeast: { gdpr.sensitivity: high }` la selecciona.

## Qué discrimina este caso

**Este era un agujero, y compilaba.** La propagación tiene dos pasadas: la primera hereda
—de la entidad, del `datasource` y, desde v1alpha4, del concepto— y la segunda computa el
`join` de una derivada empezando de cero. La segunda **pisaba** lo que la primera había
heredado del concepto.

La consecuencia era exactamente del tipo que este proyecto persigue:

> Añadir `derivedFrom` a una propiedad mapeada **le borraba la clasificación en silencio**.

Sin `derivedFrom`, la misma declaración rompe con `OOS8001` — está en
`mapped-property-inherits-classification`. Con `derivedFrom`, el paquete entero compilaba sin
una sola regla de gobierno. Nadie lo habría visto: no hay línea mal escrita que señalar, y la
propiedad sigue leyéndose igual de bien.

Y el caso lo detecta por los dos lados. Si el concepto no entrase en el `join`,
`fullEmail` no tendría etiqueta, el objetivo del `Ruleset` **no casaría con nada** y el
paquete fallaría con `OOS8002` — *un objetivo que no gobierna nada tiene el mismo aspecto que
uno que funciona*, salvo aquí, donde lo dice.

## La dirección, que es lo que lo hace correcto

El concepto entra **como un origen más** y con la misma regla que todos: solo puede subir.
Eso es coherente con lo que un concepto compartido es:

> **Un suelo de clasificación, no un valor.**

Si fijara un valor, importar vocabulario ajeno obligaría a aceptar también su laxitud, y
nadie con una obligación más estricta podría usarlo. Aquí el suelo lo pone el concepto y la
derivación puede elevarlo, nunca al revés.
