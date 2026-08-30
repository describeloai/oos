# v1alpha4 / emit / mapped-property-emits-what-it-means

**Regla:** [`00-scope.md` §8](../../../../spec/v1alpha4/00-scope.md#8) · **Nivel:** L0

---

`crm.Customer.email` declara **una sola cosa**: `is: acme.personalEmail`. El contrato ODCS
que produce lleva el tipo, la clasificacion, el `enum` y la descripcion del concepto.

Antes de este caso salia asi:

```json
{"name": "email"}
```

Sin tipo y sin clasificacion — mientras que `id`, escrita a mano, salia completa. **El
contrato que producia una propiedad mapeada era peor que el de una escrita a mano**, que es
lo contrario exacto de lo que `is` promete.

## La invariante que gobierna esta estacion

> **Emitir una propiedad mapeada y emitir la misma propiedad con lo heredado escrito a mano
> dan lo mismo.**

Se cumple al caracter, con una unica diferencia: la mapeada lleva ademas `x-oos-is`. Y esa
clave no esta ahi para documentar — esta ahi porque es **lo que permite deshacer la fusion**
al importar, que es lo que certifica el caso gemelo `mapped-property-roundtrip`.

## Donde se resuelve, y por que ahi

En el emisor, **no en la forma canonica**. La distincion importa:

| | |
|---|---|
| la forma canonica | **conserva lo escrito** — la identidad de un documento es lo que dice |
| la emision | **traduce lo que significa** — el consumidor de un contrato no habla OOS |

Resolverlo en `normalize` habria metido el significado dentro del digest, y entonces cambiar
un concepto cambiaria el digest de quince entidades que no se han tocado.

Y se resuelve contra los conceptos **del propio bundle**, no del paquete fuente. Eso es lo
que hace que **un bundle se baste a si mismo para emitir**: quien recibe el artefacto firmado
produce el contrato sin tener delante ni un fichero YAML.
