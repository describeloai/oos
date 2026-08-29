# invalid / temporal-without-valid-time

**Regla:** [`02-entity.md` §7](../../../spec/v1alpha1/02-entity.md) · **Código:** `OOS3003` · **Nivel:** L0

---

La entidad declara `transactionTime` y no `validTime`. El caso está construido así a
propósito: **es el eje equivocado el que sobra.**

- `validTime` — cuándo fue cierto **en el mundo**. Obligatorio: sin él, un salario es un
  número en lugar de una función del tiempo, y la pregunta del auditor —*«¿qué era cierto
  en tal fecha?»*— no tiene respuesta.
- `transactionTime` — cuándo lo supo **el sistema de origen**. Opcional, porque la pregunta
  *«¿qué sabía el agente el martes?»* la responden el commit del bundle y la marca de agua
  del índice, que son otros dos ejes distintos.

Declarar solo el opcional deja la entidad sin ninguna garantía temporal útil mientras
aparenta tenerlas.
