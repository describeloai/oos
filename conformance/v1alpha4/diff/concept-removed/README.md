# v1alpha4 / diff / concept-removed

**Regla:** [`00-scope.md` §8](../../../../spec/v1alpha4/00-scope.md#8) · **Codigo:** `OOS5007` · **Nivel:** L0

---

El paquete retira `acme.legalName`. Quince ontologias lo mapean con `is` y **ninguna se
entera hasta que actualiza**.

`OOS5007` es *«entidad o relacion eliminada»*, de v1alpha1. Se reutiliza porque el sintoma es
el mismo y este registro emite **un codigo por sintoma, no por causa**: algo con nombre
propio, del que otros dependen, ha dejado de existir. Que sea una entidad, una relacion o un
concepto cambia quien lo sufre, no que lo sufra.

Y conviene ver el contraste con la propiedad de una entidad, que tiene codigo propio
—`OOS5001`— y una salida que aqui no existe: `moved` y `reserved` permiten que un nombre
desaparezca **con instrucciones**. Un concepto no las tiene todavia, y eso es una pregunta
abierta legitima, no un descuido de este caso.
