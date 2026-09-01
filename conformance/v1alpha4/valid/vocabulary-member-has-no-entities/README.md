# v1alpha4 / valid / vocabulary-member-has-no-entities

**Regla:** [`02-property.md` §6.1](../../../../spec/v1alpha4/02-property.md#61--la-excepcion-que-es-la-regla-dicha-entera) · **Nivel:** L0

---

`vocabulary-package-has-no-entities` fija la excepción con **un solo paquete**. Este la fija
donde de verdad se usa: un workspace con **dos miembros**, uno que publica vocabulario y otro
que lo habla.

```
packages/gdpr/   personalEmail · nationalId      ← ninguna entidad
packages/hr/     Employee.email: is: gdpr.personalEmail
```

`gdpr.nationalId` **no lo habla nadie**, y el paquete acepta. Ese es el caso entero.

## Por qué hacía falta un segundo caso

Porque la regla y la excepción se evalúan sobre unidades distintas, y con un solo paquete no
se nota:

| | Unidad |
|---|---|
| **quién habla** un concepto | el **workspace** — es lo que se compila (`02-ruleset` §2.5), y quien lo habla no tiene por qué estar en el paquete que lo publica |
| **a quién se le exige** que lo hablen | el **paquete** — §6.1 dice *«no se aplica a un paquete sin entidades»* |

Con las dos preguntas resueltas sobre el árbol entero, el resultado es correcto mientras haya
un solo paquete y **falso en cuanto hay dos**: el workspace tiene entidades, luego la
excepción no se aplica a nada, luego cada concepto sin hablar es `OOS9004`.

## Lo que estaba en juego

Salió midiendo con un vocabulario real de quince conceptos vendorizado junto a un paquete que
hablaba dos: **trece `OOS9004`**, y la ayuda del diagnóstico recomendaba *«publícalo en un
paquete SIN ENTIDADES»* — que es exactamente lo que ya se había hecho.

> Un diagnóstico cuya ayuda describe lo que ya hiciste no es un aviso: es un callejón.

Y el efecto práctico era peor que un error de más: mientras no hubiera resolutor de
dependencias, **la única forma de consumir un vocabulario era vendorizarlo**, y vendorizarlo
no compilaba. La forma de publicar vocabulario que §6.1 define quedaba disponible solo para
quien no la necesitaba todavía.
