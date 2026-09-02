# v1alpha7 / invalid / entity-inherits-through-the-chain

**Regla:** [`01-view.md` §5.1](../../../../spec/v1alpha7/01-view.md#51) · **Código:** `OOS4002` · **Nivel:** L0

---

La herencia atraviesa la cadena. `erp` está etiquetado `low`; `iberia` sale de `empleados`, que sale
de `erp`, y `iberia` se materializa en un conducto que admite `none`. Ningún documento entre medias
escribe una etiqueta, y la copia lleva `low` igual: la ubicación física es un hecho del mundo y se
computa desde la raíz, no desde el primer eslabón.
