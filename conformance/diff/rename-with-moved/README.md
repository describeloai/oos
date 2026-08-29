# diff / rename-with-moved

**Regla:** [`91-versioning.md` §5.4](../../../spec/v1alpha1/91-versioning.md) · **Veredicto:** compatible en los cuatro ejes

---

`salary` pasa a llamarse `baseSalary`, con `moved` declarándolo.

Es el contraste directo de
[`remove-property-without-moved`](../remove-property-without-moved/): **la misma
desaparición de una propiedad**, y aquí el diff sale vacío.

La diferencia no es cuánto cambia el modelo — cambia igual. Es que el consumidor tiene un
camino para seguirlo: el motor resuelve el nombre antiguo durante la ventana de deprecación
en lugar de romper.

## Y por qué este caso es necesario

Un diferenciador que clasificase **todo** como rompedor pasaría los quince casos anteriores
y sería completamente inútil. Este es, junto con
[`add-optional-property`](../add-optional-property/), el que impide esa lectura.
