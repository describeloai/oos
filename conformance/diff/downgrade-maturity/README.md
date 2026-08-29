# diff / downgrade-maturity

**Regla:** [`91-versioning.md` §5.1](../../../spec/v1alpha1/91-versioning.md) · **Eje:** `CONSUMER` · **Código:** `OOS5008`

---

Una entidad `STABLE` vuelve a `DRAFT`.

No cambia ni una propiedad, y aun así rompe: `DRAFT` es **invisible para los consumidores
de producción**. La entidad no se ha modificado; ha desaparecido de la superficie servida.

Es la prueba de que el estado de madurez tiene consecuencias ejecutables y no es una
etiqueta documental. Lo mismo que permite tener miles de entidades en borrador sin
contaminar producción hace que devolver una a borrador sea un cambio rompedor.

La salida correcta es `DEPRECATED` con fecha de retirada, no `DRAFT`: una retira ordenando
la salida, la otra apaga la luz.
