# v1alpha8 / diff / a-regrouped-view-answers-another-question

**Regla:** [`91-versioning.md` §5.1](../../../../spec/v1alpha1/91-versioning.md) ·
**Codigo:** `OOS5033` · **Nivel:** L0

---

Este caso existe porque se midio **antes** de escribir el codigo, y el resultado fue el
equivocado: anadir `deleted` a `groupBy` salia `CONSUMER compatible · patch`.

No lo es. Refinar la agrupacion parte cada grupo, asi que un `count()` que valia 400 pasa a valer
250 y 150. **Ningun campo aparece ni desaparece** —`borrado` se anade, que es aditivo— y aun asi
todo consumidor que leyera `n` recibe otra respuesta a la misma pregunta.

Y por eso `OOS5033` no se parte en «estrecha» y «ensancha» como el recorte —`OOS5028` y
`OOS5029`—: alli las dos direcciones tienen consecuencias distintas, una rompe al lector y la otra
a la politica. Aqui las dos rompen lo mismo, porque lo que cambia no es que filas salen sino que
PREGUNTA se contesta.
