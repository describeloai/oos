# v1alpha8 / valid / a-draft-view-says-so

**Regla:** [`02-view.md` §4.1](../../../../spec/v1alpha8/02-view.md#41--oosmaturity-y-solo-oosmaturity) ·
**Nivel:** L0

---

**El gemelo de [`invalid/a-view-does-not-classify-data`](../../invalid/a-view-does-not-classify-data/),
y difieren en una clave.** Aquí la vista declara `oos.maturity`; allí declara `gdpr.sensitivity`.
Nada más. Que los dos casos se distingan en una palabra es el punto: **la regla no es «la vista
lleva etiquetas» ni «no las lleva», es de qué habla la etiqueta.**

## Por qué esto compila

`oos.maturity` clasifica **este documento**, no el dato. Dice si la pregunta está acordada, y eso
la vista sí lo sabe de sí misma:

```yaml
kind: View
metadata:
  name: empleados
  namespace: hr
  labels: { oos.maturity: DRAFT }
```

La vista sigue sin llevar significado. `DRAFT` no dice nada de `national_id` —qué significa esa
columna lo dice la entidad, y sigue siendo el único sitio donde se dice—; dice que **esta
proyección la propuso alguien y todavía no la ha acordado nadie**.

## Por qué hacía falta

`ore discover` propone vistas mirando un catálogo, y hasta esta versión no podía marcarlas. Una
vista adivinada por una máquina y una que una organización acordó preguntarse eran el mismo
documento — mientras la ayuda del comando afirmaba que las proponía en `DRAFT`.

Es el mismo camino por el que `Concept` recuperó sus etiquetas: **lo acuñado por inferencia tiene
que poder decir que todavía no es verdad.**

## Lo que NO dice

Que la vista deba declararlo. Una vista que no escribe `labels` es exactamente lo que era, y por
eso la migración no roza: en el corpus, 55 de 56 vistas no escriben una línea.

Y no dice que la etiqueta **fluya**. Que `oos.maturity: DRAFT` sobre una vista clasifique lo que
sale de ella —como ya hace la de una entidad— es otra pregunta, y esta versión no la contesta.
