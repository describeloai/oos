# v1alpha8 / diff / a-source-that-stops-retracting

**Regla:** [`91-versioning.md` §5.3](../../../../spec/v1alpha1/91-versioning.md#53--rompedor-en-index) ·
**Código:** `OOS5032` · **Nivel:** L0

---

`changes.mode` pasa de `retract` a `append`. Lo que se obtiene copiando un `append` **no es el
estado presente**: es el histórico de lo que llegó, con las filas viejas dentro.

## Un código propio, y lo decide el remedio

`OOS5031` se arregla replanificando. **Aquí no hay plan que valga**: hay que rehacer la copia
entera, o cambiar el testigo. Dos remedios, dos códigos — el criterio de `OOS2024`/`OOS2025`.

## Los empates, que son la mitad de la regla

El orden es de **mantenibilidad**, no de nombres:

```text
none  ⊏  append  ⊏  upsert = retract        y para el testigo:
none  ⊏  field   ⊏  snapshot = log
```

`upsert` y `retract` **empatan** —las dos retractan, solo codifican distinto— y `snapshot` con
`log` también, porque los dos son una posición de confirmación. **Pasar de una a otra no degrada
nada y no se reporta.** Una escala por orden alfabético o por posición se lo habría inventado.

## Lo que NO dice

Que esto sea siempre legal. Si la vista está materializada y respalda una `nature: entity`, el
`after` **no compila** — es `OOS2021`, y lo dice `validate` sobre una sola versión. `diff` contesta
otra pregunta: qué le pasa a quien ya dependía.
