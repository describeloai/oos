# diff / add-optional-property

**Regla:** [`91-versioning.md` §5.4](../../../spec/v1alpha1/91-versioning.md) · **Veredicto:** compatible en los cuatro ejes

---

Se añade `workEmail`, opcional y sin etiqueta.

El caso mínimo de compatibilidad, y sirve para comprobar dos cosas a la vez: que el diff
sale vacío **y** que `requiredBump` es `minor` y no `major`. Un diferenciador que acertase
la clasificación y errase el salto seguiría siendo inservible.

Obsérvese que la propiedad se añade **sin etiqueta**. Añadirla con una etiqueta también
sería compatible en `CONSUMER` —nadie la leía antes— pero abriría la pregunta de si su
etiqueta cabe en los conductos ya declarados, que es un asunto de `OOS4002` y no de `diff`.
