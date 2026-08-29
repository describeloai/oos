# invalid / reserved-name-reused

**Regla:** [`02-entity.md` §8](../../../spec/v1alpha1/02-entity.md) · **Código:** `OOS2006` · **Nivel:** L0

---

`comp` significaba compensación total. Alguien lo reutiliza para el código de la filial.

Sin `reserved`, esto compila, se despliega y **funciona**. Un cuadro de mando de tres años
atrás que pide `comp` sigue devolviendo un valor — ahora un código de empresa donde antes
había euros. Nadie recibe un error. La cifra es correcta para la pregunta equivocada.

Es el fallo más silencioso y más caro de una ontología viva, y Protobuf lo resolvió hace
quince años reservando números de campo. Aquí se reservan nombres.
