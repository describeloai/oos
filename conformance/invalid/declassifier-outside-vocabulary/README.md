# invalid / declassifier-outside-vocabulary

**Regla:** [`04-flow.md` §5](../../../spec/v1alpha1/04-flow.md) · **Código:** `OOS4006` · **Nivel:** L0

---

La política invoca `obfuscate:LIGHT`. El vocabulario de desclasificadores es **cerrado**:
`mask` · `tokenize` · `redact` · `aggregate` · `promote`.

Este caso es la justificación operativa de por qué se cerró. Con un conjunto abierto,
`obfuscate:LIGHT` sería una anotación válida cuyo efecto sobre la etiqueta **nadie podría
computar** — y el compilador tendría que elegir entre suponer que desclasifica (inseguro)
o suponer que no (haría inútil la extensibilidad que supuestamente ganaba).

Cerrarlo tiene tres consecuencias, y las tres se ven aquí: es **analizable** —se puede
demostrar que ningún dato etiquetado llega sin transformar a un conducto—, es **auditable**
—un regulador lee la lista completa— y es **coherente con P3**, porque si la obligación
fuera programable la política volvería a ser la salida de un programa.
