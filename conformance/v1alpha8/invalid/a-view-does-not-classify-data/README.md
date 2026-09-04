# v1alpha8 / invalid / a-view-does-not-classify-data

**Regla:** [`02-view.md` §4.1](../../../../spec/v1alpha8/02-view.md#41--oosmaturity-y-solo-oosmaturity) ·
**Código:** `OOS1005` · **Nivel:** L0

---

**El gemelo de [`valid/a-draft-view-says-so`](../../valid/a-draft-view-says-so/), y difieren en una
clave.** Allí la vista declara `oos.maturity`; aquí declara `gdpr.sensitivity`.

## Por qué esto no compila

```yaml
kind: View
metadata:
  name: empleados
  namespace: hr
  labels: { gdpr.sensitivity: high }     # ← OOS1005
```

`gdpr.sensitivity` clasifica **el dato**, y qué significa una columna lo dice la entidad. Si la
vista pudiera decirlo también, habría dos sitios diciéndolo y el día que discrepen ninguno diría
cuál manda.

La vista admite exactamente una clave —`oos.maturity`, que es el estado de **este documento**— y
cualquier otra es una clave desconocida. **El código es el mismo con el que se hacía cumplir la
prohibición entera** antes de admitirla: lo que cambió es el conjunto admitido, de vacío a uno, no
la clase de error.

## Lo que NO dice

Que la clasificación no atraviese la vista. La atraviesa, y es lo que hace posible que
`materialization.payload` selle una copia con la etiqueta que una entidad puso tres eslabones más
arriba — `OOS4001`, `OOS4002`. **Lo que la vista no puede es ser una FUENTE de esa clasificación.**
Está sujeta al significado sin ser origen de él.
