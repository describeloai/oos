# v1alpha4 / invalid / declares-neither-type-nor-concept

**Regla:** [`02-property.md` §1](../../../../spec/v1alpha4/02-property.md#1-naturaleza) · **Codigo:** `OOS1004` · **Nivel:** L0

---

> Una propiedad **declara localmente o referencia un concepto**. Este caso es la mitad que
> faltaba: **ninguna de las dos.**

`redeclares-the-inherited-type` fija que no pueden ser las dos. Las dos mitades salen del
mismo `oneOf` y solo una tenia caso, asi que la otra se podia incumplir sin que nada lo
dijera — y el esquema la exigia desde v1alpha1, donde la propiedad llevaba `required: [type]`
a secas.

## Por que importa mas de lo que parece

Un campo sin tipo no es un campo a medias: **es un campo que el emisor tiene que inventar.**
Un SDL de GraphQL obliga a escribir un tipo concreto para cada campo y no tiene donde poner
*«ninguno»*, asi que lo rellena — y el contrato sale afirmando un tipo que el dato no tiene.

> Un contrato al que le falta un campo se nota al leerlo. Uno que **miente sobre el tipo** de
> un campo se descubre en el consumidor.

La propiedad de este caso lleva `description`, y esta puesta a proposito: un bloque con algo
escrito dentro no se lee como un hueco. Es lo que hace que este defecto sobreviva a una
revision humana del fichero.
