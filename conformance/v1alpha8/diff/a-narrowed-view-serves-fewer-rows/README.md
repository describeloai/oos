# v1alpha8 / diff / a-narrowed-view-serves-fewer-rows

**Regla:** [`91-versioning.md` §5.1](../../../../spec/v1alpha1/91-versioning.md#51--rompedor-en-consumer) ·
**Código:** `OOS5028` · **Nivel:** L0

---

**El gemelo de [`a-widened-view-serves-rows-the-contract-excluded`](../a-widened-view-serves-rows-the-contract-excluded/),
y difieren en un valor.** Aquí el recorte pierde `PT`; allí gana `FR`.

```yaml
# before                      # after
where: { pais: [ES, PT] }     where: { pais: [ES] }
```

## Por qué es rompedor, y en qué eje

Quien consultaba `hr.iberia` recibía portugueses y deja de recibirlos. **La consulta sigue siendo
válida y ha dejado de significar lo mismo** — que es literalmente la pregunta del eje `CONSUMER`.

## Lo que hay que mirar en el sujeto

```json
{ "subject": "hr.iberia.country", "from": "ES,PT", "to": "ES" }
```

**`country`, no `pais`.** El recorte se compara **acumulado por la cadena y en columnas físicas de
la raíz**, que es lo que hace que un renombre en un eslabón intermedio no invente un cambio, y que
un recorte de la vista de abajo salga en todas las de arriba — que es a quienes les pasa.

## Y por qué necesita código propio

Porque **el análisis de flujo no puede verlo, por construcción**. `flow` clasifica **columnas**: el
`where` sobre `pais` deja una arista `INDIRECT` sobre esa columna y ahí se acaba. Cambiar `[ES, PT]`
por `[ES]` mueve **filas**, y no mueve una sola etiqueta. Es el único cambio del modelo del que
ninguna otra máquina se entera.
