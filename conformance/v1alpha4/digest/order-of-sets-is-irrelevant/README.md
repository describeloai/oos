# v1alpha4 / digest / order-of-sets-is-irrelevant

**Regla:** [`03-interface.md` §3.2](../../../../spec/v1alpha4/03-interface.md#32) · **Nivel:** L0

---

Los tres campos que v1alpha4 anade son conjuntos, y en `b` estan los tres escritos al reves:

| | `a` | `b` |
|---|---|---|
| `Interface.requires` | `[personalEmail, legalName]` | `[legalName, personalEmail]` |
| `Entity.implements` | `[Party, Contactable]` | `[Contactable, Party]` |
| `Property.requiresGovernance` | `[authorization, constraint]` | `[constraint, authorization]` |

Mismo digest. **Antes de este caso daban dos distintos**, y no por poco: el bundle entero
cambiaba.

## Por que hacia falta escribirlo

`03-interface` §3.2 dice, y decia antes de que fuera verdad:

> *«Es un conjunto: el orden no significa nada y la forma canonica lo ordena. Dos interfaces
> que exigen lo mismo en otro orden tienen el mismo digest.»*

Eso es **G1** —*el mismo commit produce el mismo digest*—, que es la primera de las cinco
garantias, y estaba rota en el plano nuevo mientras la especificacion afirmaba lo contrario.

Es la **tercera vez** que pasa lo mismo. `CONJUNTOS` no crecio con v1alpha2, no crecio con
v1alpha3, y no crecio con v1alpha4: cada plano nuevo llego con G1 rota, y las tres veces se
descubrio comparando dos digests a mano en vez de leyendo. Una lista que hay que acordarse de
actualizar es una lista de la que nadie se acuerda.

## Y lo que NO esta en esa lista

`enum` es una **secuencia**: retirar un valor o reordenarlos es un cambio observable, igual
que `Resolution.strategies`, donde la primera que casa gana. La misma regla trata los dos
casos distinto **porque los dos casos son distintos**, y que la lista discrimine es lo que la
hace una decision y no un descuido.
