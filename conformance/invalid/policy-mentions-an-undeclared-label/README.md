# invalid / policy-mentions-an-undeclared-label

**Regla:** [`04-flow.md` §3](../../../spec/v1alpha1/04-flow.md) · **Código:** `OOS2005` · **Nivel:** L0

---

`Label::"gdpr.sensitivity:higth"`. El retículo declara `high`.

Una política así **no falla**: deja de casar con nada, y la propiedad que iba a proteger queda
sin gobernar sin que salte nada.

> **Una política que no gobierna tiene exactamente el mismo aspecto que una que gobierna.**

Lo afilado es que **el razonamiento ya estaba escrito, y se aplicaba a una sola dirección**.
`OOS2013` vigila que el esquema Cedar comprometido conozca cada nivel del retículo, y su ayuda
dice literalmente que *«una política que los mencione no fallará: dejará de casar con nada, y
el dato quedará sin gobernar en silencio»*. La dirección contraria —que la política mencione
solo lo declarado— no la vigilaba nadie.

No hace falta evaluador ni código nuevo: `cedar.rs` ya lee las etiquetas que una política
menciona, y comprobarlas es comparar dos conjuntos de cadenas. Una etiqueta es una referencia
a un nivel de un retículo, y **una referencia que no resuelve ya tiene código**.

## Lo que NO es un error, y está en el mismo módulo

Una política que menciona una etiqueta **declarada** y que hoy no lleva ninguna propiedad no
es un defecto: es la característica. `Property in [Label, EntityType]` existe para que una
entidad nueva quede gobernada **el día que se etiqueta**, sin tocar la política. Eso se
informa —`ore validate` dice qué alcanza cada una— y no se diagnostica.
