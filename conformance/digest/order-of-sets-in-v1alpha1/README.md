# digest / order-of-sets-in-v1alpha1

**Regla:** [`90-canonical-form.md` §N4](../../../spec/v1alpha1/90-canonical-form.md#n4--conjuntos-ordenados-secuencias-preservadas) · **Nivel:** L0

---

Cuatro campos, los cuatro conjuntos, los cuatro escritos al revés en `b`:

| | `a` | `b` |
|---|---|---|
| `derivedFrom` | `[baseSalary, bonus]` | `[bonus, baseSalary]` |
| `reserved` | `[alfa, beta]` | `[beta, alfa]` |
| `uniqueKeys` | `[[email], [taxId]]` | `[[taxId], [email]]` |
| `support` | `[email, slack]` | `[slack, email]` |

Mismo digest. **Daban cuatro distintos, y esto es v1alpha1** — la versión cerrada, la de los
73 casos en verde, la que se venía usando como prueba de que ese número significa algo.

## El que más pesa es `derivedFrom`

Es lo que **propaga las etiquetas**, y el `join` es conmutativo: `join(critical, low)` y
`join(low, critical)` son lo mismo por definición. Que el orden en que un autor escribe dos
orígenes cambiara el digest de la entidad era `G1` rota **en el corazón del régimen de
flujo**, y llevaba ahí desde el primer día.

## Y lo que este caso NO afirma

`uniqueKeys` es un **conjunto de claves**, y cada clave es una **secuencia**: `[a, b]` y
`[b, a]` son claves compuestas distintas y **deben** dar digests distintos. Ordenar las de
dentro habría convertido una clave en otra.

Por eso una lista dentro de una lista no hereda la clasificación de la de fuera. Es el único
sitio del árbol donde eso pasa, y sin mirarlo el arreglo de este caso habría introducido un
fallo peor que el que arregla: uno que **cambia lo que un documento significa** en vez de solo
su digest.

## Cómo se encontró

No leyendo, otra vez. Las cuatro roturas de `G1` de este proyecto se han descubierto
comparando dos digests a mano, y esta salió de preguntar si las estaciones de la cadena
estaban **realmente** todas en verde.

La consecuencia está en [`90-canonical-form`](../../../spec/v1alpha1/90-canonical-form.md)
§N4.1: la exigencia de clasificar cada lista era normativa desde v1alpha1 y no la cumplía
nadie — ni los esquemas la declaraban, ni la implementación de referencia podía comprobarla.
Ahora un campo lista sin clasificar rompe un test.
