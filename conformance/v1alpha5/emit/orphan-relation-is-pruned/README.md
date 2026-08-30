# v1alpha5 / emit / orphan-relation-is-pruned

**Regla:** [`01-emision-graphql.md` §4](../../../../spec/v1alpha5/01-emision-graphql.md#4-lo-que-la-emisión-ejecuta-antes-de-escribir) · **Nivel:** L0

---

`Diagnosis` tiene todas sus propiedades en `critical` y el techo es `medium`: se queda sin
campos y **no se emite**. `Order` sobrevive — pero su relación `patient` apunta a un tipo que
ya no existe.

El cuarto paso de §4 la poda. **Y no es limpieza.**

## Por qué es una fuga, y de las peores

`DESIGN` §4.1 lo dice sin rodeos:

> *«Saber que el paciente X está enlazado con la clínica oncológica Y **es el diagnóstico**,
> aunque no se haya copiado ningún campo clínico.»*

Un campo `patient: Diagnosis` en el contrato revela **que existe un tipo `Diagnosis`** y **que
un pedido se relaciona con uno**. Ninguna de las dos cosas debía salir, y ninguna es un dato:
son la topología. Es el peldaño de metadatos que `DESIGN` §4.1 llama *el más delicado y el que
nadie discute*.

## Lo que sí queda

`patientId` **sí sale**: es un `String` sin clasificar, y por sí solo no dice a qué apunta.
Que el dato sobreviva y la arista no es exactamente la distinción de v1alpha1 haciendo su
trabajo — **una clave opaca no es una relación.**
