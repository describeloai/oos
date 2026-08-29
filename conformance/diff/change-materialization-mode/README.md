# diff / change-materialization-mode

**Regla:** [`91-versioning.md` §5.3](../../../spec/v1alpha1/91-versioning.md) · **Eje:** `INDEX` · **Código:** `OOS5020`

---

De `index` a `passthrough`. En dirección **restrictiva**: se deja de copiar.

En el eje `POLICY` esto es intachable — se materializa menos. En `CONSUMER` tampoco rompe
nada: las mismas consultas devuelven las mismas respuestas.

Y sin embargo hay que anunciarlo, porque **una travesía del grafo que era local pasa a ser
una consulta federada por salto**. Nada falla; todo tarda otro orden de magnitud, y el
consumidor que dependía de esa latencia no tiene forma de enterarse salvo que el diff se lo
diga.

Es el recordatorio de que el eje `INDEX` existe para lo que no es ni corrección ni
gobernanza: **la operación**.
