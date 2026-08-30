# v1alpha4 / invalid / mapping-cannot-lower

**Regla:** [`04-flow.md` §3](../../../../spec/v1alpha1/04-flow.md#3) · **Codigo:** `OOS4012` · **Nivel:** L0

---

`gdpr.personalEmail` dice `high`. La entidad dice `low`, y no compila.

**Este caso no estrena nada, y ese es su contenido.** `OOS4012` se escribio en v1alpha1 para
una propiedad que hereda de su entidad; aqui gobierna una propiedad que hereda de un
concepto, y **no hizo falta cambiar una letra** — ni de la regla, ni del codigo, ni del
mensaje. La herencia desde el concepto se enchufo como tercera fuente en la propagacion que
ya existia, al lado de la entidad y del `datasource`.

Que la version mas ambiciosa reutilice el codigo de la primera sin tocarlo es la mejor
prueba de que el mecanismo estaba bien puesto. **Lo unico nuevo de v1alpha4 es el nivel al
que se aplica lo que ya estaba.**

Y la direccion importa: rebajar es lo unico prohibido. Un concepto compartido fija un
**suelo** de clasificacion, no un valor — si no, importar vocabulario obligaria a aceptar
tambien su laxitud.
