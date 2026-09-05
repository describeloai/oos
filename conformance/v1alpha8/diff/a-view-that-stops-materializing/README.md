# v1alpha8 / diff / a-view-that-stops-materializing

**Regla:** [`91-versioning.md` §5.3](../../../../spec/v1alpha1/91-versioning.md#53--rompedor-en-index) ·
**Código:** `OOS5020` · **Nivel:** L0

---

`hr.empleados` deja de declarar `materialized`. Sigue compilando —su raíz se deja leer— y las filas
pasan a salir del origen.

## Esto no es un código nuevo: es un sujeto devuelto

`OOS5020` —*«cambiar el modo de materialización»*— es **normativo desde v1alpha1**, y su comentario
en el motor decía por qué: *«callarlo dejaría un índice fantasma sirviendo lecturas»*.

Se calculaba sobre el `Binding`, que llevaba dentro `source` y `materialization`. v1alpha8 partió el
binding en `Table` + `View` y **el eje `INDEX` se quedó sin sujeto**: el código siguió vivo en el
paradigma anterior y ciego en este. Aquí se le devuelve.

## Por qué salen dos cambios

```json
{ "subject": "hr.empleados", "from": "lago·cache.hr_employees", "to": "erp·public.employees" }
{ "subject": "hr.iberia",    "from": "lago·cache.hr_employees", "to": "erp·public.employees" }
```

Porque lo que se compara no es lo que la vista **declara** sino de dónde salen **de verdad** sus
filas — la *raíz de lectura*. `iberia` no tocó una línea y su respuesta cambió de sitio igual. Es el
mismo criterio con el que `diff` compara el gobierno: **el efecto, no la sintaxis**.
