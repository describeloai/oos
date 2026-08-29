# invalid / generated-artifact-out-of-sync

**Regla:** [`00-overview.md` §5](../../../spec/v1alpha1/00-overview.md) — principio **P2** · **Código:** `OOS2013` · **Nivel:** L0

---

El retículo declara `critical`. El esquema Cedar comprometido se generó cuando solo había
`[none, low, high]`. Alguien añadió el nivel y no regeneró.

## El hueco que este caso destapa

`OOS2013` **no existía**. Salió de diseñar `emit/`: hay dos artefactos derivados que sí se
comprometen a Git —el esquema Cedar y `ontology.lock`—, ambos marcados NO EDITAR, y de los
dos se afirmaba que *«`ore validate` falla si está desincronizado»*… **sin ningún código con
el que fallar.**

Una regla sin código no es comprobable por la suite, y una regla que la suite no puede
comprobar no es normativa. Un código, dos usos.

## Por qué comprometerlos y no ignorarlos

Ambos son derivados, y P2 dice que lo derivable no se declara. Pero **no se declaran: se
generan**, y se comprometen por una razón concreta —que el tooling de Cedar y el resolutor
funcionen sin compilar— exactamente igual que un `package-lock.json`.

El precio de esa comodidad es que pueden quedar obsoletos, y `OOS2013` es lo que lo cobra.

Fallar aquí importa más de lo que parece: un esquema Cedar sin `critical` haría que
`resource in Label::"gdpr.sensitivity:critical"` **no case con nada**. La política no daría
error — simplemente dejaría de aplicarse, y el dato más sensible del paquete quedaría sin
gobernar en silencio.
