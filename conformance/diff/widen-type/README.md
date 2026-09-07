# `diff/widen-type`

**Regla:** [`91-versioning.md` §5.1](../../../spec/v1alpha1/91-versioning.md) · **Eje:** ninguno · **Código:** ninguno

`OOS5002` dice **«tipo estrechado o valor retirado de un `enum`»**, y se disparaba sobre
cualquier cambio de tipo: `Integer → Decimal` salía como estrechamiento y forzaba un `major`.
El veredicto no siempre era falso —cambiar un tipo publicado tiene coste— pero **la atribución
sí**, y un código que dice algo que no pasó es peor que ninguno.

La dirección ya estaba decidida en el gemelo de este caso, [`narrow-enum`](../narrow-enum): se
cobra **retirar** valores, y añadirlos *«no rompe a quien lee»*. Esto es la misma frase sobre el
escalar.

`Integer → Decimal` es el **único** par que ensancha sobre los diez escalares del conjunto
cerrado, y lo que importa es lo que queda fuera: `→ Float` pierde exactitud, `Date → DateTime`
inventa la hora, `→ String` cambia el contrato de lectura entero y `→ Opaque` retira el
gobierno. Está escrito, par a par, en `types::ensancha`.
