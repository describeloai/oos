# Suite de conformidad — v1alpha7

**Borrador.** Certifica la vista de [`spec/v1alpha7/`](../../spec/v1alpha7/), cuyo alcance
sigue **abierto** y que **no es normativo**.

---

## Por qué vive en su propio árbol

Por lo mismo que los demás borradores: un marcador significa *una implementación de
referencia pasa esto*, y mezclar casos de un borrador con los de v1alpha1 daría un número que
ya no se sabe qué mide.

## Qué cubre

El primer peldaño de [`01-view` §9](../../spec/v1alpha7/01-view.md#9-listo--tres-peldaños):
**la cadena compila y se niega.**

| | Casos |
|---|---|
| `valid/` | una vista sola · la entidad que la nombra · una vista sobre otra · la copia que cabe en su conducto |
| `invalid/` | la vista de abajo que no existe · el ciclo · el campo que la de abajo no expone · la clave que la vista no da · la fuente sin declarar · el testigo que nombra lo que no hay · la copia sin conducto · **la copia que filtra la etiqueta de una entidad dos eslabones arriba** · la herencia del datasource raíz |

Los códigos nuevos son dos —`OOS2018`, `OOS2019`— y **todos los demás se reutilizan**:
`OOS2004`, `OOS2011`, `OOS4002`, `OOS4011`. Que una vista materializada falle con el mismo
código que un binding con `payload` es la afirmación de que la vista no cambia la regla,
cambia el camino — y esta suite es donde eso se comprueba en vez de decirse.

## Lo que no está aquí, y dónde está

Los otros dos peldaños —que `discover` proponga vistas, y que `Binding` se retire— no son
casos: son la migración. El segundo se verá aquí el día que llegue, como casos de `03-binding`
traducidos a vistas.
