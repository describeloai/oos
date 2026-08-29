# canonical / n7-comments-and-formatting

**Regla:** [`90-canonical-form.md` §N7](../../../spec/v1alpha1/90-canonical-form.md) · **Afirmación:** convergen

---

El mismo documento escrito de dos maneras: `a/` compacto en estilo flow, `b/` con cabecera
de comentarios, estilo block, listas expandidas y líneas en blanco.

Es el caso más importante de esta tanda desde el punto de vista de **producto**, no de
especificación. Si el formato afectara al digest:

- reordenar un comentario aparecería como cambio en `ore diff`
- pasar el repositorio por un formateador rompería la reproducibilidad
- **la gente dejaría de comentar sus ontologías** para no ensuciar el historial

Y eso es exactamente lo contrario de lo que se busca. Los comentarios son la mitad del valor
de un artefacto que se revisa en un pull request — el ejemplo `acme-retail` es tan
explicativo como declarativo — y este caso es lo que garantiza que ponerlos sale gratis.
