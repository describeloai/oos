# `oos.dev/types/iso`

**Los códigos de un registro internacional, publicados como conceptos.** Tres conceptos, cero
etiquetas, cero entidades.

`0.1.0` · `status: draft` · Apache-2.0

---

## Qué resuelve, y en qué se diferencia del regulatorio

Los dos son vocabulario y publican `kind: Concept`. Lo que traen **no es lo mismo**, y esa
diferencia es la que decide en cuál va cada concepto:

| | `regulatory/gdpr` | `types/iso` |
|---|---|---|
| Qué aporta | **cuánto pesa** y qué gobierno exige | **qué es** y qué forma tiene |
| `labels` | sí — el suelo de clasificación | **ninguna, a propósito** |
| Autoridad | un reglamento | un registro internacional |
| Qué pasa si te lo saltas | un dato sensible sin gobernar | dos sistemas que creen hablar de lo mismo |

Un código de país **no es dato personal**, así que este paquete no clasifica nada y no trae
retículo. Lo que sí hace es fijar tres cosas que se equivocan a diario: que el código *es* el
dato —no una entidad `Pais` a medio modelar—, que es `String` y no `Integer`, y **cuál de las
codificaciones del registro es**.

> `ESP` y `ES` son el mismo país en dos codificaciones del mismo registro. Unir por ellas
> produce un join que funciona para casi todo y falla para nada en particular.

## Qué hay dentro

| Concepto | Registro | Tipo |
|---|---|:---:|
| `iso.countryCode` | ISO 3166-1 alfa-2 | `String` |
| `iso.currencyCode` | ISO 4217 | `String` |
| `iso.languageTag` | BCP 47 | `String` |

Son **exactamente los tres** que el `ontology.lock` del ejemplo de referencia declara que este
paquete provee. La lista no la elegí yo: ya estaba escrita, esperando a que alguien la
escribiera de verdad.

`languageTag` es BCP 47 y no «ISO 639» porque BCP 47 **compone** tres registros —ISO 639 para
la lengua, ISO 15924 para la escritura, ISO 3166-1 para la región— y esa composición es lo que
impide partirlo en tres columnas sin perder cuál va con cuál.

## Qué NO hay dentro, y las tres son decisiones

**No hay `enum`.** Es lo primero que se espera de un paquete de tipos, y `02-property` §2 usa
justo estos códigos para explicar por qué un `enum` cabe en un concepto. Falta porque un
`enum` aquí tiene que ser **la lista del registro, completa y al día**, y una aproximación
escrita a mano sería una lista que *parece* autoritativa y no lo es. Retirar un valor de un
`enum` además es un cambio observable —la forma canónica lo dice—, así que publicarlo mal se
paga dos veces. Sale de la fuente o no sale.

**No hay zonas horarias ni tipos MIME.** Son la misma clase de cosa —un registro que todos
comparten— y **no son ISO**. En un paquete que se llama `iso` serían una promesa que el nombre
no sostiene. Su sitio es otro paquete, y no cuesta nada tenerlo.

**No hay IBAN, BIC ni LEI**, que sí son ISO —13616, 9362, 17442—. Se quedaron fuera por una
razón que conviene ver: el IBAN **de una persona física es dato personal**, y una propiedad
solo puede declarar **un** `is`. Publicarlo aquí, sin etiquetas, invitaría a mapear una cuenta
bancaria a un concepto que no clasifica nada y dar el trabajo por hecho. Un concepto que se
puede usar para creer que has gobernado algo es peor que no tenerlo.

> Lo que es dato personal se publica donde se publica la clasificación. Este paquete existe
> para lo que **nunca** lo es.

## Cómo se consume

```yaml
dependencies:
  - { package: oos.dev/types/iso, version: "^0.1" }
```

Se copia como un miembro más del workspace y `ore lock` lo resuelve por su nombre, que **es**
esa coordenada.

```yaml
properties:
  moneda: { is: iso.currencyCode }
  pais:   { is: iso.countryCode }
```

Se hereda `type`, `enum`, `aiContext` y `description` —`02-property` §5— y no hay `labels` que
heredar. Una propiedad que además sea sensible **declara su clasificación localmente**: el
concepto pone un suelo, y aquí el suelo es ninguno.

## Y cuando haya `enum`, ya hay dónde llegan

Escribir este paquete destapó que la emisión a GraphQL **no emitía enums en absoluto** — ni
los heredados de un concepto ni los declarados en una propiedad—: todos salían `String`, y el
contrato pasaba a admitir cualquier cadena donde el dato admite tres valores. Está arreglado
(`01-emision-graphql` §2.10), y con las dos salidas que hacían falta:

- `iso.currencyCode`, cuando tenga sus valores, saldrá como `enum Iso_currencyCode { EUR … }`.
- `iso.languageTag` **no puede**: `es-ES` no es un identificador de GraphQL. Saldrá como
  `scalar Iso_languageTag`, que es la salida que §3.1 ya había elegido para `Money<EUR, 2>` y
  por lo mismo — lo que no cabe en la traducción se **nombra**, no se tira.

Que los dos casos estén resueltos antes de publicar un solo valor no es adelantarse: es la
única forma de saber que la lista, cuando llegue, tiene dónde aterrizar.
