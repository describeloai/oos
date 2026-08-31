# invalid / tokey-is-not-a-declared-key

**Regla:** [`02-entity.md` §6](../../../spec/v1alpha1/02-entity.md) · **Código:** `OOS3006` · **Nivel:** L0

---

`toKey: [id, nif]`. Las dos propiedades existen —`OOS2005` no tiene nada que decir— y juntas
no son ninguna de las claves que `Cliente` declara: ni `[id]` ni `[nif]`.

Un `toKey` cualquiera convertiría el campo en un `sql_on` con otro nombre: enlazar contra un
conjunto de columnas que no identifica una instancia devuelve **más de una fila por
instancia**, y eso no se ve en el documento. La restricción —*como conjunto, exactamente una
clave declarada*— es lo que mantiene `toKey` dentro del modelo en vez de convertirlo en una
condición de join arbitraria.
