# digest / description-is-content

**Regla:** [`90-canonical-form.md` §N7](../../../spec/v1alpha1/90-canonical-form.md) · **Afirmación:** digest **distinto**

---

Las dos variantes difieren en una palabra de `description`: *«vigente»* frente a *«vigente
o pasada»*.

Es el par exacto de [`formatting-irrelevant`](../formatting-irrelevant/), y juntos trazan la
frontera:

| | ¿Entra en el digest? |
|---|---|
| Un comentario `# ...` | **no** — es formato |
| Un campo `description:` | **sí** — es contenido |

La distinción no es formal: **`description` es lo que lee un agente por la superficie de
contexto.** Cambiar «vigente» por «vigente o pasada» cambia qué preguntas responde
correctamente el modelo, y por tanto es un cambio real del artefacto — aunque ninguna
propiedad, ningún tipo y ninguna etiqueta se hayan tocado.

Un sistema que tratase la documentación como decoración desplegaría un contexto distinto
bajo el mismo digest, y la respuesta a *«¿qué sabía el agente el martes?»* dejaría de ser
exacta.
