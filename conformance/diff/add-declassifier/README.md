# diff / add-declassifier

**Regla:** [`91-versioning.md` §5.2](../../../spec/v1alpha1/91-versioning.md) · **Eje:** `POLICY` · **Código:** `OOS5017`

---

Se añade `@obligation("redact")` a una política que no tenía ninguna.

Es el caso **contraintuitivo** de la familia: redactar sirve *menos* dato del que se servía
antes. Parece endurecer, y sin embargo es rompedor en el eje `POLICY`.

La razón es que un desclasificador no es una restricción sobre lo que se muestra: **es una
autorización para bajar una etiqueta**, y bajar una etiqueta abre conductos que antes
estaban cerrados. El flujo hacia `contextSurface` o hacia una caché que la regla de flujo
rechazaba pasa a ser legal.

Endurecer la salida y relajar el flujo son cosas distintas, y solo la segunda importa aquí.
