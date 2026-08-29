# invalid / examples-not-synthetic

**Regla:** [`02-entity.md` §4.2](../../../spec/v1alpha1/02-entity.md) · **Código:** `OOS4014` · **Nivel:** L0

---

`68400.00` y `91250.00` son **salarios reales de alguien**, escritos en un fichero que se
revisa en un pull request, se publica en un registry y alcanza la superficie de contexto
de cualquier agente que consulte el modelo.

Nadie piensa en esto. ODCS admite `examples` por propiedad y no dice nada al respecto, y es
razonable que no lo diga: sin etiquetas ni conductos no hay nada contra lo que comprobarlo.

Aquí lo atrapa el análisis de flujo **sin ninguna regla especial**: `examples` es texto que
alcanza `contextSurface` como cualquier otro. Basta con que las propiedades tengan etiqueta.

La propiedad `grade` declara ejemplos y pasa, porque no está etiquetada. La salida no es
prohibir los ejemplos: es **declarar `synthetic: true`**, que convierte un descuido
silencioso en una afirmación consciente.
